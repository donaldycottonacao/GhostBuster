import 'dart:async';
import 'package:flutter/foundation.dart';

/// Abstract contract for audio playback during simulated calls.
abstract class AudioServiceBase {
  /// Initialize audio session / background handling.
  Future<void> initialize();

  /// Play simulated ringtone track (e.g. assets/audio/ringtone_ios.mp3).
  Future<void> playRingtone({String? assetPath});

  /// Play simulated peer dialogue speech track.
  Future<void> playPeerAudio(String assetPath);

  /// Stop all active audio streams.
  Future<void> stopAll();

  /// Whether audio is currently actively playing.
  bool get isPlaying;
}

/// Safe audio service implementation and placeholder.
///
/// Designed to gracefully handle missing optional audio files without throwing
/// unhandled runtime exceptions. In production, this service can wrap
/// audio packages such as `audioplayers` or `just_audio`.
class AudioService implements AudioServiceBase {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  bool _isPlaying = false;
  String? _currentAsset;

  @override
  bool get isPlaying => _isPlaying;

  String? get currentAsset => _currentAsset;

  @override
  Future<void> initialize() async {
    debugPrint('[AudioService] Audio service initialized (Safe Mode)');
  }

  @override
  Future<void> playRingtone({String? assetPath}) async {
    final path = assetPath ?? 'assets/audio/ringtone_ios.mp3';
    _currentAsset = path;
    _isPlaying = true;
    debugPrint('[AudioService] Ringtone triggered: $path (Simulated Safe Playback)');
  }

  @override
  Future<void> playPeerAudio(String assetPath) async {
    _currentAsset = assetPath;
    _isPlaying = true;
    debugPrint('[AudioService] Peer audio triggered: $assetPath (Simulated Safe Playback)');
  }

  @override
  Future<void> stopAll() async {
    _isPlaying = false;
    _currentAsset = null;
    debugPrint('[AudioService] All audio tracks stopped');
  }
}
