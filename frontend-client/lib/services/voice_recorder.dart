import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:record/record.dart';

/// Result of a completed recording.
class RecordingResult {
  /// Absolute path to the recorded audio file, or null if nothing was captured.
  final String? path;

  const RecordingResult(this.path);
}

/// Microphone permission outcome.
enum MicPermissionStatus { granted, denied, permanentlyDenied }

/// Abstract recorder contract so the UI and controller can be tested with a
/// fake that never touches real microphone hardware.
abstract class VoiceRecorderBase {
  /// Requests microphone permission, returning the resulting status.
  Future<MicPermissionStatus> ensurePermission();

  /// Begins recording to [filePath]. Throws on failure so callers can surface
  /// an error state.
  Future<void> start(String filePath);

  /// Pauses an in-progress recording where the platform supports it.
  Future<void> pause();

  /// Resumes a paused recording.
  Future<void> resume();

  /// Stops recording and returns the final file path.
  Future<RecordingResult> stop();

  /// Cancels recording and discards any partial file.
  Future<void> cancel();

  /// Whether a recording is currently active (recording or paused).
  Future<bool> isRecording();

  /// Whether the recording is currently paused.
  Future<bool> isPaused();

  /// Periodic amplitude readings for a waveform/level indicator.
  Stream<double> amplitudeStream();

  /// Releases native resources.
  Future<void> dispose();
}

/// Default recorder backed by `package:record`.
///
/// Records AAC in an `.m4a` container, which `package:audioplayers` can play
/// back from a device file path on Android and iOS.
class VoiceRecorder implements VoiceRecorderBase {
  VoiceRecorder({AudioRecorder? recorder})
      : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;

  static const RecordConfig _config = RecordConfig(
    encoder: AudioEncoder.aacLc,
    sampleRate: 44100,
    numChannels: 1,
  );

  /// File extension produced by [_config]; callers build paths with this.
  static const String fileExtension = 'm4a';

  @override
  Future<MicPermissionStatus> ensurePermission() async {
    try {
      final hasPermission = await _recorder.hasPermission();
      return hasPermission
          ? MicPermissionStatus.granted
          : MicPermissionStatus.denied;
    } catch (error) {
      debugPrint('[VoiceRecorder] Permission check failed');
      return MicPermissionStatus.denied;
    }
  }

  @override
  Future<void> start(String filePath) async {
    await _recorder.start(_config, path: filePath);
  }

  @override
  Future<void> pause() async {
    try {
      await _recorder.pause();
    } catch (error) {
      debugPrint('[VoiceRecorder] Pause unsupported or failed');
    }
  }

  @override
  Future<void> resume() async {
    try {
      await _recorder.resume();
    } catch (error) {
      debugPrint('[VoiceRecorder] Resume failed');
    }
  }

  @override
  Future<RecordingResult> stop() async {
    final path = await _recorder.stop();
    return RecordingResult(path);
  }

  @override
  Future<void> cancel() async {
    try {
      await _recorder.cancel();
    } catch (error) {
      debugPrint('[VoiceRecorder] Cancel failed');
    }
  }

  @override
  Future<bool> isRecording() async {
    try {
      return await _recorder.isRecording();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> isPaused() async {
    try {
      return await _recorder.isPaused();
    } catch (_) {
      return false;
    }
  }

  @override
  Stream<double> amplitudeStream() {
    try {
      return _recorder
          .onAmplitudeChanged(const Duration(milliseconds: 160))
          .map((amp) {
        // Normalize dBFS (roughly -45..0) to a 0..1 range for the UI.
        const minDb = -45.0;
        final current = amp.current.clamp(minDb, 0.0);
        return ((current - minDb) / -minDb).clamp(0.0, 1.0);
      });
    } catch (_) {
      return const Stream<double>.empty();
    }
  }

  @override
  Future<void> dispose() async {
    try {
      await _recorder.dispose();
    } catch (_) {
      // Best-effort cleanup.
    }
  }
}
