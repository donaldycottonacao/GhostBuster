import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Abstract contract for audio playback during simulated calls.
abstract class AudioServiceBase {
  /// Initialize audio session / background handling.
  Future<void> initialize();

  /// Play simulated ringtone track (loops during ringing state).
  Future<void> playRingtone({String? assetPath});

  /// Explicitly stop only the ringtone player.
  Future<void> stopRingtone();

  /// Play simulated peer dialogue speech track.
  Future<void> playPeerAudio(String assetPath);

  /// Alias for playPeerAudio matching scenario playback specifications.
  Future<void> playScenarioVoice(String assetPath);

  /// Explicitly stop only the voice player.
  Future<void> stopVoice();

  /// Stop all active audio streams and reset player state.
  Future<void> stopAll();

  /// Release and dispose all audio resources.
  Future<void> dispose();

  /// Whether any audio stream is currently actively playing.
  bool get isPlaying;

  /// Whether the ringtone is actively playing/looping.
  bool get isRingtonePlaying;

  /// Whether the voice dialogue track is actively playing.
  bool get isVoicePlaying;

  /// Current audio asset path in use.
  String? get currentAsset;
}

/// Centralized audio service for the GhostBuster simulated call lifecycle.
///
/// Owns dedicated AudioPlayer resources for ringtone looping and peer voice playback.
/// Features graceful exception handling and safe fallback simulation when binary
/// audio assets are not present on disk, ensuring zero runtime crashes.
class AudioService implements AudioServiceBase {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;

  AudioPlayer? _ringtonePlayer;
  AudioPlayer? _voicePlayer;
  final bool _enableHardware;

  bool _isRingtonePlaying = false;
  bool _isVoicePlaying = false;
  String? _currentAsset;
  bool _isDisposed = false;
  int _operationGeneration = 0;

  AudioService._internal({bool enableHardware = true})
      : _enableHardware = enableHardware {
    _initPlayers();
  }

  /// Visible for testing to inject mock/isolated players.
  @visibleForTesting
  AudioService.custom({
    AudioPlayer? ringtonePlayer,
    AudioPlayer? voicePlayer,
    bool enableHardware = true,
  })  : _ringtonePlayer = ringtonePlayer,
        _voicePlayer = voicePlayer,
        _enableHardware = enableHardware {
    if (_enableHardware && _ringtonePlayer == null && _voicePlayer == null) {
      _initPlayers();
    }
  }

  void _initPlayers() {
    if (!_enableHardware) return;
    try {
      _ringtonePlayer ??= AudioPlayer();
      _voicePlayer ??= AudioPlayer();
    } catch (e) {
      debugPrint('[AudioService] AudioPlayer hardware init warning: $e');
    }
  }

  @override
  bool get isPlaying => _isRingtonePlaying || _isVoicePlaying;

  @override
  bool get isRingtonePlaying => _isRingtonePlaying;

  @override
  bool get isVoicePlaying => _isVoicePlaying;

  @override
  String? get currentAsset => _currentAsset;

  String _cleanAssetPath(String rawPath) {
    if (rawPath.startsWith('assets/')) {
      return rawPath.substring(7);
    }
    return rawPath;
  }

  @override
  Future<void> initialize() async {
    if (_isDisposed) return;
    debugPrint('[AudioService] Audio service initialized');
  }

  @override
  Future<void> playRingtone({String? assetPath}) async {
    if (_isDisposed) return;
    final generation = ++_operationGeneration;
    final path = assetPath ?? 'assets/audio/ringtone_ios.mp3';

    _currentAsset = path;
    _isRingtonePlaying = true;
    debugPrint('[AudioService] Ringtone triggered: $path');

    if (!_enableHardware || _ringtonePlayer == null) return;

    try {
      await _ringtonePlayer?.setReleaseMode(ReleaseMode.loop);
      if (generation != _operationGeneration || !_isRingtonePlaying) return;
      await _ringtonePlayer?.play(AssetSource(_cleanAssetPath(path)));
    } catch (e) {
      debugPrint('[AudioService] Hardware ringtone playback fallback: $e');
    }
  }

  @override
  Future<void> stopRingtone() async {
    await _stopRingtonePlayer();
    debugPrint('[AudioService] Ringtone stopped');
  }

  /// Stops the ringtone player. Returns `false` if the platform stop threw,
  /// meaning the ringtone may still be audible.
  Future<bool> _stopRingtonePlayer() async {
    _isRingtonePlaying = false;
    if (_ringtonePlayer == null) return true;
    try {
      await _ringtonePlayer?.stop();
      return true;
    } catch (e) {
      debugPrint('[AudioService] Error stopping ringtone player: $e');
      return false;
    }
  }

  @override
  Future<void> playPeerAudio(String assetPath) async {
    if (_isDisposed) return;
    final generation = ++_operationGeneration;

    // Invariant: Ringtone must be stopped before voice audio begins
    final ringtoneStopped = await _stopRingtonePlayer();

    // A hang-up, reset or dispose may have happened while the stop was in
    // flight; do not mark a superseded voice request as playing.
    if (_isDisposed || generation != _operationGeneration) return;
    if (!ringtoneStopped) {
      debugPrint(
          '[AudioService] Voice not started: ringtone stop failed (avoids overlap)');
      return;
    }

    _currentAsset = assetPath;
    _isVoicePlaying = true;
    debugPrint('[AudioService] Peer voice triggered: $assetPath');

    if (!_enableHardware || _voicePlayer == null) return;

    try {
      await _voicePlayer?.setReleaseMode(ReleaseMode.stop);
      if (generation != _operationGeneration || !_isVoicePlaying) return;
      await _voicePlayer?.play(AssetSource(_cleanAssetPath(assetPath)));
    } catch (e) {
      debugPrint('[AudioService] Hardware voice playback fallback: $e');
    }
  }

  @override
  Future<void> playScenarioVoice(String assetPath) => playPeerAudio(assetPath);

  @override
  Future<void> stopVoice() async {
    _isVoicePlaying = false;
    if (_voicePlayer != null) {
      try {
        await _voicePlayer?.stop();
      } catch (e) {
        debugPrint('[AudioService] Error stopping voice player: $e');
      }
    }
    debugPrint('[AudioService] Peer voice stopped');
  }

  @override
  Future<void> stopAll() async {
    _operationGeneration++;
    _isRingtonePlaying = false;
    _isVoicePlaying = false;
    _currentAsset = null;

    // Independent stops ensure failure of one player does not block the other
    if (_ringtonePlayer != null) {
      try {
        await _ringtonePlayer?.stop();
      } catch (e) {
        debugPrint('[AudioService] Error stopping ringtone during stopAll: $e');
      }
    }

    if (_voicePlayer != null) {
      try {
        await _voicePlayer?.stop();
      } catch (e) {
        debugPrint('[AudioService] Error stopping voice during stopAll: $e');
      }
    }

    debugPrint('[AudioService] All audio tracks stopped');
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await stopAll();

    try {
      await _ringtonePlayer?.dispose();
    } catch (e) {
      debugPrint('[AudioService] Error disposing ringtone player: $e');
    } finally {
      _ringtonePlayer = null;
    }

    try {
      await _voicePlayer?.dispose();
    } catch (e) {
      debugPrint('[AudioService] Error disposing voice player: $e');
    } finally {
      _voicePlayer = null;
    }

    debugPrint('[AudioService] AudioService disposed');
  }
}
