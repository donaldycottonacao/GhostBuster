// Phase 9: the real AudioService driven through fake AudioPlayer instances.
//
// Verifies player-level call ordering, failure isolation and stale-operation
// guards without platform channels or speakers.

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_client/providers/call_provider.dart';
import 'package:frontend_client/services/audio_service.dart';

import 'helpers/audio_fakes.dart';

void main() {
  late List<String> log;
  late FakeAudioPlayer ringtone;
  late FakeAudioPlayer voice;
  late AudioService service;

  setUp(() {
    log = [];
    ringtone = FakeAudioPlayer('ringtone', log);
    voice = FakeAudioPlayer('voice', log);
    service = AudioService.custom(ringtonePlayer: ringtone, voicePlayer: voice);
  });

  tearDown(() async {
    ringtone.stopGate = null;
    ringtone.releaseModeGate = null;
    await service.dispose();
  });

  group('Successful sequence', () {
    test('ringtone -> answer -> hang-up runs in the required order', () async {
      await service.playRingtone();
      expect(service.isRingtonePlaying, isTrue);

      await service.playPeerAudio('assets/audio/peer_mom.mp3');
      expect(service.isRingtonePlaying, isFalse);
      expect(service.isVoicePlaying, isTrue);

      await service.stopAll();
      expect(service.isPlaying, isFalse);
      expect(service.currentAsset, isNull);

      expect(log, [
        'ringtone.setReleaseMode:loop',
        'ringtone.play:audio/ringtone_ios.mp3',
        'ringtone.stop', // ringtone stopped before the voice is touched
        'voice.setReleaseMode:stop',
        'voice.play:audio/peer_mom.mp3',
        'ringtone.stop',
        'voice.stop',
      ]);
      expect(ringtone.isPlayingNow, isFalse);
      expect(voice.isPlayingNow, isFalse);
    });

    test('ringtone loops; voice plays once', () async {
      await service.playRingtone();
      await service.playPeerAudio('assets/audio/peer_landlord.mp3');
      expect(ringtone.lastReleaseMode, ReleaseMode.loop);
      expect(voice.lastReleaseMode, ReleaseMode.stop);
      expect(voice.lastAssetPath, 'audio/peer_landlord.mp3');
    });

    test('repeated ringtone requests reuse one player (no overlap)', () async {
      await service.playRingtone();
      await service.playRingtone(
          assetPath: 'assets/audio/ringtone_android.mp3');

      expect(log.where((e) => e.startsWith('voice.')), isEmpty);
      expect(log.where((e) => e.startsWith('ringtone.play')).length, 2);
      expect(ringtone.lastAssetPath, 'audio/ringtone_android.mp3');
      expect(service.currentAsset, 'assets/audio/ringtone_android.mp3');
    });

    test('playScenarioVoice delegates to the same ordered path', () async {
      await service.playRingtone();
      log.clear();
      await service.playScenarioVoice('assets/audio/peer_mom.mp3');
      expect(log.first, 'ringtone.stop');
      expect(log.last, 'voice.play:audio/peer_mom.mp3');
    });
  });

  group('Cleanup', () {
    test('stopAll still stops the voice when the ringtone stop throws',
        () async {
      await service.playPeerAudio('assets/audio/peer_mom.mp3');
      ringtone.stopError = StateError('platform stop failed');
      log.clear();

      await expectLater(service.stopAll(), completes);
      expect(log, ['ringtone.stop', 'voice.stop']);
      expect(service.isPlaying, isFalse);
      expect(voice.isPlayingNow, isFalse);
    });

    test('stopAll still clears state when the voice stop throws', () async {
      await service.playPeerAudio('assets/audio/peer_mom.mp3');
      voice.stopError = StateError('platform stop failed');
      await expectLater(service.stopAll(), completes);
      expect(service.isPlaying, isFalse);
    });

    test('repeated stopAll is safe', () async {
      await service.playRingtone();
      for (var i = 0; i < 3; i++) {
        await expectLater(service.stopAll(), completes);
      }
      expect(service.isPlaying, isFalse);
    });

    test('dispose releases both players and blocks later playback', () async {
      await service.playRingtone();
      await service.dispose();
      expect(ringtone.isDisposed, isTrue);
      expect(voice.isDisposed, isTrue);

      log.clear();
      await service.playRingtone();
      await service.playPeerAudio('assets/audio/peer_mom.mp3');
      expect(log, isEmpty);
      expect(service.isPlaying, isFalse);
    });
  });

  group('Failures', () {
    test('missing ringtone asset (play throws) is contained', () async {
      ringtone.playError = Exception('Unable to load asset');
      await expectLater(service.playRingtone(), completes);
      await expectLater(service.stopAll(), completes);
      expect(service.isPlaying, isFalse);
    });

    test('missing voice asset (play throws) is contained', () async {
      voice.playError = Exception('Unable to load asset');
      await expectLater(
        service.playPeerAudio('assets/audio/missing_voice.mp3'),
        completes,
      );
      await service.stopAll();
      expect(service.isPlaying, isFalse);
    });

    test('voice does not start if the ringtone could not be stopped', () async {
      await service.playRingtone();
      ringtone.stopError = StateError('platform stop failed');

      await expectLater(
        service.playPeerAudio('assets/audio/peer_mom.mp3'),
        completes,
      );
      expect(log.where((e) => e.startsWith('voice.play')), isEmpty);
      expect(service.isVoicePlaying, isFalse);
    });

    test('a valid voice plays after a previous failure', () async {
      voice.playError = Exception('Unable to load asset');
      await service.playPeerAudio('assets/audio/missing_voice.mp3');
      await service.stopAll();

      voice.playError = null;
      await service.playPeerAudio('assets/audio/peer_mom.mp3');
      expect(voice.isPlayingNow, isTrue);
      expect(voice.lastAssetPath, 'audio/peer_mom.mp3');
    });
  });

  group('CallProvider + real AudioService', () {
    test('ring -> answer -> hang-up drives the players in order', () async {
      final provider = CallProvider(audioService: service);
      provider.triggerRinging();
      await pumpEventQueue();
      provider.answerCall();
      await pumpEventQueue();

      expect(voice.isPlayingNow, isTrue);
      expect(ringtone.isPlayingNow, isFalse);
      final ringtoneStops = <int>[
        for (var i = 0; i < log.length; i++)
          if (log[i] == 'ringtone.stop') i,
      ];
      expect(ringtoneStops, isNotEmpty);
      expect(ringtoneStops.first,
          lessThan(log.indexOf('voice.play:audio/peer_mom.mp3')));

      provider.endCall();
      await pumpEventQueue();
      expect(voice.isPlayingNow, isFalse);
      expect(ringtone.isPlayingNow, isFalse);
      expect(service.isPlaying, isFalse);
      provider.dispose();
    });

    test('hang-up immediately after answer leaves both players silent',
        () async {
      final provider = CallProvider(audioService: service);
      provider.triggerRinging();
      await pumpEventQueue();
      ringtone.stopGate = Completer<void>();

      provider.answerCall();
      provider.endCall();
      ringtone.stopGate!.complete();
      await pumpEventQueue();

      expect(log.where((e) => e.startsWith('voice.play')), isEmpty);
      expect(service.isPlaying, isFalse);
      provider.dispose();
    });
  });

  group('Stale operations', () {
    test('hang-up during an in-flight voice start leaves nothing playing',
        () async {
      await service.playRingtone();
      ringtone.stopGate = Completer<void>();

      final answer = service.playPeerAudio('assets/audio/peer_mom.mp3');
      final hangUp = service.stopAll();
      ringtone.stopGate!.complete();
      await Future.wait([answer, hangUp]);

      expect(log.where((e) => e.startsWith('voice.play')), isEmpty);
      expect(service.isVoicePlaying, isFalse);
      expect(service.isPlaying, isFalse);
      expect(service.currentAsset, isNull);
    });

    test('dispose during an in-flight voice start leaves nothing playing',
        () async {
      await service.playRingtone();
      ringtone.stopGate = Completer<void>();

      final answer = service.playPeerAudio('assets/audio/peer_mom.mp3');
      final dispose = service.dispose();
      ringtone.stopGate!.complete();
      await Future.wait([answer, dispose]);

      expect(log.where((e) => e.startsWith('voice.play')), isEmpty);
      expect(service.isPlaying, isFalse);
    });

    test('stopAll during an in-flight ringtone start prevents playback',
        () async {
      ringtone.releaseModeGate = Completer<void>();
      final ring = service.playRingtone();
      final stop = service.stopAll();
      ringtone.releaseModeGate!.complete();
      await Future.wait([ring, stop]);

      expect(log.where((e) => e.startsWith('ringtone.play')), isEmpty);
      expect(service.isRingtonePlaying, isFalse);
    });
  });
}
