import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/voice_scenario.dart';
import '../services/audio_service.dart';
import '../services/voice_recorder.dart';
import '../services/voice_scenario_store.dart';

/// High-level phases of the Voice Script Manager.
enum ManagerPhase {
  /// Loading the persisted scenario list.
  loading,

  /// Showing the saved scenario list (possibly empty).
  list,

  /// Actively recording or paused.
  recording,

  /// Recording captured; awaiting preview / save / retake decision.
  review,
}

/// Recording error categories surfaced to the UI for localized messaging.
enum RecordingError {
  none,
  permissionDenied,
  permissionPermanentlyDenied,
  startFailed,
  saveFailed,
  emptyRecording,
}

/// Orchestrates recording, previewing, and persistence for voice scenarios.
///
/// UI-framework agnostic (no BuildContext) so it can be unit tested with fake
/// recorder/store/audio collaborators. All external operations are guarded
/// against stale async callbacks via [_generation].
class VoiceScriptManagerController extends ChangeNotifier {
  final VoiceRecorderBase _recorder;
  final VoiceScenarioStore _store;
  final AudioServiceBase _audio;
  final String Function() _idFactory;
  final DateTime Function() _clock;

  VoiceScriptManagerController({
    required VoiceRecorderBase recorder,
    required VoiceScenarioStore store,
    required AudioServiceBase audio,
    String Function()? idFactory,
    DateTime Function()? clock,
  })  : _recorder = recorder,
        _store = store,
        _audio = audio,
        _idFactory = idFactory ??
            (() => DateTime.now().microsecondsSinceEpoch.toString()),
        _clock = clock ?? DateTime.now;

  ManagerPhase _phase = ManagerPhase.loading;
  List<VoiceScenario> _scenarios = const [];
  RecordingError _error = RecordingError.none;

  bool _isPaused = false;
  Duration _elapsed = Duration.zero;
  double _level = 0;
  Timer? _ticker;
  StreamSubscription<double>? _ampSub;

  String? _pendingFilePath;
  int _pendingDurationMs = 0;
  String? _previewingId;
  bool _isDisposed = false;
  int _generation = 0;

  ManagerPhase get phase => _phase;
  List<VoiceScenario> get scenarios => List.unmodifiable(_scenarios);
  bool get isEmpty => _scenarios.isEmpty;
  RecordingError get error => _error;
  bool get isPaused => _isPaused;
  Duration get elapsed => _elapsed;
  double get level => _level;

  /// Id of the scenario currently previewing, or null.
  String? get previewingId => _previewingId;

  /// Formatted mm:ss elapsed recording time.
  String get formattedElapsed {
    final totalSeconds = _elapsed.inSeconds;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _safeNotify() {
    if (!_isDisposed) notifyListeners();
  }

  /// Loads persisted scenarios into the list phase.
  Future<void> load() async {
    _phase = ManagerPhase.loading;
    _safeNotify();
    final loaded = await _store.loadAll();
    if (_isDisposed) return;
    _scenarios = loaded;
    _phase = ManagerPhase.list;
    _safeNotify();
  }

  void clearError() {
    if (_error == RecordingError.none) return;
    _error = RecordingError.none;
    _safeNotify();
  }

  /// Begins a new recording after verifying microphone permission.
  Future<void> startRecording() async {
    _error = RecordingError.none;

    final status = await _recorder.ensurePermission();
    if (_isDisposed) return;
    if (status == MicPermissionStatus.permanentlyDenied) {
      _error = RecordingError.permissionPermanentlyDenied;
      _safeNotify();
      return;
    }
    if (status != MicPermissionStatus.granted) {
      _error = RecordingError.permissionDenied;
      _safeNotify();
      return;
    }

    final generation = ++_generation;
    final id = _idFactory();
    final dir = await _store.recordingsDirectory();
    if (_isDisposed || generation != _generation) return;
    final path = '$dir/scenario_$id.${VoiceRecorder.fileExtension}';

    try {
      await _recorder.start(path);
    } catch (error) {
      _error = RecordingError.startFailed;
      _safeNotify();
      return;
    }
    if (_isDisposed || generation != _generation) {
      // Superseded (e.g. cancelled) while starting: stop quietly.
      await _recorder.cancel();
      return;
    }

    _pendingFilePath = path;
    _pendingDurationMs = 0;
    _isPaused = false;
    _elapsed = Duration.zero;
    _level = 0;
    _phase = ManagerPhase.recording;
    _startTicker();
    _ampSub = _recorder.amplitudeStream().listen((value) {
      _level = value;
      _safeNotify();
    });
    _safeNotify();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isPaused) return;
      _elapsed += const Duration(seconds: 1);
      _safeNotify();
    });
  }

  Future<void> pauseRecording() async {
    if (_phase != ManagerPhase.recording || _isPaused) return;
    await _recorder.pause();
    _isPaused = true;
    _safeNotify();
  }

  Future<void> resumeRecording() async {
    if (_phase != ManagerPhase.recording || !_isPaused) return;
    await _recorder.resume();
    _isPaused = false;
    _safeNotify();
  }

  /// Stops recording and moves to the review phase.
  Future<void> stopRecording() async {
    if (_phase != ManagerPhase.recording) return;
    _ticker?.cancel();
    _ticker = null;
    await _ampSub?.cancel();
    _ampSub = null;

    RecordingResult result;
    try {
      result = await _recorder.stop();
    } catch (error) {
      _error = RecordingError.startFailed;
      _phase = ManagerPhase.list;
      _safeNotify();
      return;
    }
    if (_isDisposed) return;

    // A null/empty path from stop() means no usable file was produced; the
    // speculative start path is not trusted as a fallback here.
    final path =
        (result.path != null && result.path!.isNotEmpty) ? result.path! : null;
    if (path == null) {
      _error = RecordingError.emptyRecording;
      _phase = ManagerPhase.list;
      _pendingFilePath = null;
      _safeNotify();
      return;
    }
    _pendingFilePath = path;
    _pendingDurationMs = _elapsed.inMilliseconds;
    _isPaused = false;
    _phase = ManagerPhase.review;
    _safeNotify();
  }

  /// Cancels an in-progress recording and discards the partial file.
  Future<void> cancelRecording() async {
    _generation++;
    _ticker?.cancel();
    _ticker = null;
    await _ampSub?.cancel();
    _ampSub = null;
    await _recorder.cancel();
    await _audio.stopPreview();
    _pendingFilePath = null;
    _pendingDurationMs = 0;
    _isPaused = false;
    _elapsed = Duration.zero;
    _level = 0;
    _phase = ManagerPhase.list;
    _safeNotify();
  }

  /// Discards the just-captured recording and starts a fresh one.
  Future<void> retake() async {
    await _audio.stopPreview();
    _pendingFilePath = null;
    _pendingDurationMs = 0;
    _elapsed = Duration.zero;
    _level = 0;
    await startRecording();
  }

  /// Previews the pending (unsaved) recording.
  Future<void> previewPending() async {
    final path = _pendingFilePath;
    if (path == null) return;
    await _audio.playPreviewFile(path);
    _previewingId = '__pending__';
    _safeNotify();
  }

  /// Previews a saved scenario, guarding against a missing file.
  Future<bool> previewScenario(VoiceScenario scenario) async {
    final exists = await _store.audioExists(scenario);
    if (!exists) {
      _error = RecordingError.emptyRecording;
      _safeNotify();
      return false;
    }
    await _audio.playPreviewFile(scenario.filePath);
    _previewingId = scenario.id;
    _safeNotify();
    return true;
  }

  Future<void> stopPreview() async {
    await _audio.stopPreview();
    _previewingId = null;
    _safeNotify();
  }

  /// Saves the pending recording as a named scenario.
  Future<VoiceScenario?> save({
    required String name,
    String description = '',
  }) async {
    final path = _pendingFilePath;
    if (path == null || path.isEmpty) {
      _error = RecordingError.saveFailed;
      _safeNotify();
      return null;
    }
    final scenario = VoiceScenario(
      id: _idFactory(),
      name: name.trim().isEmpty ? 'Untitled' : name.trim(),
      description: description.trim(),
      filePath: path,
      durationMs: _pendingDurationMs,
      createdAt: _clock().toUtc(),
    );
    try {
      _scenarios = await _store.upsert(scenario);
    } catch (error) {
      _error = RecordingError.saveFailed;
      _safeNotify();
      return null;
    }
    _pendingFilePath = null;
    _pendingDurationMs = 0;
    _elapsed = Duration.zero;
    _phase = ManagerPhase.list;
    _safeNotify();
    return scenario;
  }

  /// Renames / re-describes an existing scenario.
  Future<void> rename(String id,
      {required String name, String description = ''}) async {
    _scenarios = await _store.rename(
      id,
      name: name.trim().isEmpty ? 'Untitled' : name.trim(),
      description: description.trim(),
    );
    _safeNotify();
  }

  /// Deletes a scenario and stops its preview if it is playing.
  Future<void> delete(String id) async {
    if (_previewingId == id) {
      await stopPreview();
    }
    _scenarios = await _store.delete(id);
    _safeNotify();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _generation++;
    _ticker?.cancel();
    _ampSub?.cancel();
    unawaited(_recorder.dispose());
    unawaited(_audio.stopPreview());
    super.dispose();
  }
}
