import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_client/services/audio_service.dart';

/// Records every [AudioServiceBase] call in order and can simulate failures.
///
/// Used by controller and widget tests so they never touch real audio hardware.
class RecordingAudioService implements AudioServiceBase {
  /// Ordered call log, e.g. `playRingtone`, `stopAll`, `playPeerAudio:<path>`.
  final List<String> log = [];

  /// Operation names (e.g. `playRingtone`, `playPeerAudio`, `stopAll`) that fail.
  final Set<String> failingOps = {};

  /// When true, failures throw synchronously instead of returning a failed future.
  bool throwSynchronously = false;

  bool _ringtone = false;
  bool _voice = false;
  bool _preview = false;
  String? _asset;

  /// Number of calls to [operation] (matches `op` and `op:<argument>` entries).
  int count(String operation) => log
      .where((entry) => entry == operation || entry.startsWith('$operation:'))
      .length;

  Future<void> _record(String entry, String operation, void Function() effect) {
    log.add(entry);
    if (failingOps.contains(operation)) {
      final error = StateError('simulated $operation failure');
      if (throwSynchronously) throw error;
      return Future<void>.error(error);
    }
    effect();
    return Future<void>.value();
  }

  @override
  bool get isPlaying => _ringtone || _voice;

  @override
  bool get isRingtonePlaying => _ringtone;

  @override
  bool get isVoicePlaying => _voice;

  @override
  bool get isPreviewPlaying => _preview;

  @override
  String? get currentAsset => _asset;

  @override
  Future<void> initialize() => _record('initialize', 'initialize', () {});

  /// Asset passed to the most recent [playRingtone] call.
  String? lastRingtoneAsset;

  @override
  Future<void> playRingtone({String? assetPath}) =>
      _record('playRingtone', 'playRingtone', () {
        lastRingtoneAsset = assetPath;
        _ringtone = true;
        _asset = assetPath ?? 'assets/audio/ringtone_ios.mp3';
      });

  @override
  Future<void> stopRingtone() =>
      _record('stopRingtone', 'stopRingtone', () => _ringtone = false);

  @override
  Future<void> playPeerAudio(String assetPath) =>
      _record('playPeerAudio:$assetPath', 'playPeerAudio', () {
        _ringtone = false;
        _voice = true;
        _asset = assetPath;
      });

  @override
  Future<void> playScenarioVoice(String assetPath) => playPeerAudio(assetPath);

  @override
  Future<void> playVoiceFile(String filePath) =>
      _record('playVoiceFile:$filePath', 'playVoiceFile', () {
        _ringtone = false;
        _voice = true;
        _asset = filePath;
      });

  @override
  Future<void> playPreviewFile(String filePath) =>
      _record('playPreviewFile:$filePath', 'playPreviewFile', () {
        _preview = true;
      });

  @override
  Future<void> stopPreview() =>
      _record('stopPreview', 'stopPreview', () => _preview = false);

  @override
  Future<void> stopVoice() =>
      _record('stopVoice', 'stopVoice', () => _voice = false);

  @override
  Future<void> stopAll() => _record('stopAll', 'stopAll', () {
        _ringtone = false;
        _voice = false;
        _asset = null;
      });

  @override
  Future<void> dispose() => _record('dispose', 'dispose', () {
        _ringtone = false;
        _voice = false;
      });
}

/// Minimal stand-in for `package:audioplayers` [AudioPlayer].
///
/// Only the members [AudioService] actually uses are implemented; any other
/// member throws via [Fake]. Calls are appended to a shared [log] so ordering
/// across the ringtone and voice players can be asserted.
class FakeAudioPlayer extends Fake implements AudioPlayer {
  FakeAudioPlayer(this.name, this.log);

  final String name;
  final List<String> log;

  ReleaseMode? lastReleaseMode;
  String? lastAssetPath;
  bool isPlayingNow = false;
  bool isDisposed = false;

  Object? playError;
  Object? stopError;

  /// When set, [stop] waits on this gate (simulates slow platform calls).
  Completer<void>? stopGate;

  /// When set, [setReleaseMode] waits on this gate.
  Completer<void>? releaseModeGate;

  @override
  Future<void> setReleaseMode(ReleaseMode mode) async {
    log.add('$name.setReleaseMode:${mode.name}');
    lastReleaseMode = mode;
    final gate = releaseModeGate;
    if (gate != null) await gate.future;
  }

  @override
  Future<void> play(
    Source source, {
    double? volume,
    double? balance,
    AudioContext? ctx,
    Duration? position,
    PlayerMode? mode,
  }) async {
    final path = source is AssetSource ? source.path : source.toString();
    log.add('$name.play:$path');
    if (playError != null) throw playError!;
    lastAssetPath = path;
    isPlayingNow = true;
  }

  @override
  Future<void> stop() async {
    log.add('$name.stop');
    final gate = stopGate;
    if (gate != null) await gate.future;
    if (stopError != null) throw stopError!;
    isPlayingNow = false;
  }

  @override
  Future<void> dispose() async {
    log.add('$name.dispose');
    isDisposed = true;
    isPlayingNow = false;
  }
}
