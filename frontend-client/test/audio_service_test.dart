import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_client/services/audio_service.dart';

void main() {
  group('AudioService - Ringtone Lifecycle & Looping', () {
    late AudioService audioService;

    setUp(() {
      // Initialize with hardware disabled for deterministic unit testing
      audioService = AudioService.custom(enableHardware: false);
    });

    tearDown(() async {
      await audioService.dispose();
    });

    test('initializes with no active playback', () {
      expect(audioService.isPlaying, isFalse);
      expect(audioService.isRingtonePlaying, isFalse);
      expect(audioService.isVoicePlaying, isFalse);
      expect(audioService.currentAsset, isNull);
    });

    test('playRingtone activates ringtone playback with default asset',
        () async {
      await audioService.playRingtone();
      expect(audioService.isPlaying, isTrue);
      expect(audioService.isRingtonePlaying, isTrue);
      expect(audioService.isVoicePlaying, isFalse);
      expect(audioService.currentAsset, 'assets/audio/ringtone_telephone.mp3');
    });

    test('playRingtone supports custom asset path', () async {
      await audioService.playRingtone(
          assetPath: 'assets/audio/ringtone_android.mp3');
      expect(audioService.isRingtonePlaying, isTrue);
      expect(audioService.currentAsset, 'assets/audio/ringtone_android.mp3');
    });

    test('stopRingtone halts ringtone without affecting voice state', () async {
      await audioService.playRingtone();
      expect(audioService.isRingtonePlaying, isTrue);

      await audioService.stopRingtone();
      expect(audioService.isRingtonePlaying, isFalse);
      expect(audioService.isPlaying, isFalse);
    });

    test('stopRingtone is idempotent when already stopped', () async {
      await audioService.stopRingtone();
      await audioService.stopRingtone();
      expect(audioService.isRingtonePlaying, isFalse);
    });
  });

  group('AudioService - Peer Voice Playback & Sequencing', () {
    late AudioService audioService;

    setUp(() {
      audioService = AudioService.custom(enableHardware: false);
    });

    tearDown(() async {
      await audioService.dispose();
    });

    test(
        'playPeerAudio automatically stops ringtone before starting voice audio',
        () async {
      await audioService.playRingtone();
      expect(audioService.isRingtonePlaying, isTrue);

      await audioService.playPeerAudio('assets/audio/peer_mom.mp3');
      // Invariant: Ringtone must be stopped once peer dialogue begins
      expect(audioService.isRingtonePlaying, isFalse);
      expect(audioService.isVoicePlaying, isTrue);
      expect(audioService.currentAsset, 'assets/audio/peer_mom.mp3');
    });

    test('playScenarioVoice delegates to playPeerAudio', () async {
      await audioService.playScenarioVoice('assets/audio/peer_landlord.mp3');
      expect(audioService.isVoicePlaying, isTrue);
      expect(audioService.currentAsset, 'assets/audio/peer_landlord.mp3');
    });

    test('stopVoice halts voice audio cleanly', () async {
      await audioService.playPeerAudio('assets/audio/peer_mom.mp3');
      expect(audioService.isVoicePlaying, isTrue);

      await audioService.stopVoice();
      expect(audioService.isVoicePlaying, isFalse);
      expect(audioService.isPlaying, isFalse);
    });

    test('stopVoice is idempotent when already stopped', () async {
      await audioService.stopVoice();
      expect(audioService.isVoicePlaying, isFalse);
    });
  });

  group('AudioService - Cleanup, Reset & Disposal', () {
    late AudioService audioService;

    setUp(() {
      audioService = AudioService.custom(enableHardware: false);
    });

    tearDown(() async {
      await audioService.dispose();
    });

    test('stopAll stops both ringtone and voice and clears current asset',
        () async {
      await audioService.playRingtone();
      expect(audioService.isPlaying, isTrue);

      await audioService.stopAll();
      expect(audioService.isPlaying, isFalse);
      expect(audioService.isRingtonePlaying, isFalse);
      expect(audioService.isVoicePlaying, isFalse);
      expect(audioService.currentAsset, isNull);
    });

    test('repeated stopAll calls remain safe and idempotent', () async {
      await audioService.stopAll();
      await audioService.stopAll();
      await audioService.stopAll();
      expect(audioService.isPlaying, isFalse);
    });

    test('dispose halts active streams and rejects subsequent play operations',
        () async {
      await audioService.playRingtone();
      expect(audioService.isPlaying, isTrue);

      await audioService.dispose();
      expect(audioService.isPlaying, isFalse);

      // Subsequent play requests ignored after disposal
      await audioService.playRingtone();
      expect(audioService.isPlaying, isFalse);
    });

    test('double disposal is safe and does not throw', () async {
      await audioService.dispose();
      await audioService.dispose();
    });
  });
}
