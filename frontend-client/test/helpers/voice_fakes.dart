import 'dart:async';

import 'package:frontend_client/models/voice_scenario.dart';
import 'package:frontend_client/services/voice_recorder.dart';
import 'package:frontend_client/services/voice_scenario_store.dart';

/// In-memory metadata backend for store tests (no shared_preferences plugin).
class InMemoryMetadataBackend implements ScenarioMetadataBackend {
  final Map<String, String> store = {};

  @override
  Future<String?> read(String key) async => store[key];

  @override
  Future<void> write(String key, String value) async {
    store[key] = value;
  }
}

/// Fake file storage: tracks "existing" files in a set, no real disk I/O.
class FakeRecordingFileStorage implements RecordingFileStorage {
  FakeRecordingFileStorage({this.directory = '/tmp/voice'});

  final String directory;
  final Set<String> existing = {};
  final List<String> deleted = [];

  @override
  Future<String> recordingsDirectoryPath() async => directory;

  @override
  Future<void> deleteFile(String filePath) async {
    existing.remove(filePath);
    deleted.add(filePath);
  }

  @override
  Future<bool> fileExists(String filePath) async => existing.contains(filePath);
}

/// Scriptable fake recorder.
class FakeVoiceRecorder implements VoiceRecorderBase {
  MicPermissionStatus permission = MicPermissionStatus.granted;
  bool startThrows = false;

  /// When true, stop() returns null AND forgets the start path, simulating a
  /// recording session that produced no usable file.
  bool stopReturnsNull = false;

  final List<String> log = [];
  String? lastStartPath;
  bool recording = false;
  bool paused = false;
  bool disposed = false;

  final StreamController<double> _amp = StreamController<double>.broadcast();

  void emitAmplitude(double value) => _amp.add(value);

  @override
  Future<MicPermissionStatus> ensurePermission() async {
    log.add('ensurePermission');
    return permission;
  }

  @override
  Future<void> start(String filePath) async {
    log.add('start:$filePath');
    if (startThrows) throw StateError('start failed');
    lastStartPath = filePath;
    recording = true;
    paused = false;
  }

  @override
  Future<void> pause() async {
    log.add('pause');
    paused = true;
  }

  @override
  Future<void> resume() async {
    log.add('resume');
    paused = false;
  }

  @override
  Future<RecordingResult> stop() async {
    log.add('stop');
    recording = false;
    paused = false;
    return RecordingResult(stopReturnsNull ? null : lastStartPath);
  }

  @override
  Future<void> cancel() async {
    log.add('cancel');
    recording = false;
    paused = false;
  }

  @override
  Future<bool> isRecording() async => recording;

  @override
  Future<bool> isPaused() async => paused;

  @override
  Stream<double> amplitudeStream() => _amp.stream;

  @override
  Future<void> dispose() async {
    log.add('dispose');
    disposed = true;
    _amp.close();
  }
}

/// Builds a scenario quickly for list/store tests.
VoiceScenario makeScenario({
  required String id,
  String name = 'Test',
  String description = '',
  String? filePath,
  int durationMs = 1000,
  DateTime? createdAt,
}) {
  return VoiceScenario(
    id: id,
    name: name,
    description: description,
    filePath: filePath ?? '/tmp/voice/$id.m4a',
    durationMs: durationMs,
    createdAt: createdAt ?? DateTime.utc(2026, 1, 1),
  );
}
