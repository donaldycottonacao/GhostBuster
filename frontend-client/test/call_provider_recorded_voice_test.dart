import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_client/models/call_state.dart';
import 'package:frontend_client/providers/call_provider.dart';

import 'helpers/audio_fakes.dart';

/// AssetProbe that reports every asset present.
Future<bool> _allPresent(String _) async => true;

void main() {
  group('Recorded voice selection', () {
    test('selecting a recording plays the file on answer, not the asset', () {
      fakeAsync((async) {
        final audio = RecordingAudioService();
        final provider =
            CallProvider(audioService: audio, assetProbe: _allPresent);

        provider.selectRecordedVoice(
          scenarioId: 's1',
          filePath: '/tmp/voice/s1.m4a',
        );
        expect(provider.usesRecordedVoice, isTrue);
        expect(provider.selectedVoiceScenarioId, 's1');

        provider.startCountdown(delaySeconds: 10);
        async.elapse(const Duration(seconds: 10));
        expect(provider.state, CallLifecycleState.ringing);

        provider.answerCall();
        async.flushMicrotasks();

        // Sequence preserved: ringtone played, stopped, then the FILE plays.
        expect(audio.log, [
          'playRingtone',
          'stopAll',
          'playVoiceFile:/tmp/voice/s1.m4a',
        ]);
        provider.dispose();
      });
    });

    test('clearing selection falls back to the persona bundled asset', () {
      fakeAsync((async) {
        final audio = RecordingAudioService();
        final provider =
            CallProvider(audioService: audio, assetProbe: _allPresent);

        provider.selectRecordedVoice(
            scenarioId: 's1', filePath: '/tmp/voice/s1.m4a');
        provider.clearRecordedVoice();
        expect(provider.usesRecordedVoice, isFalse);

        provider.startCountdown(delaySeconds: 10);
        async.elapse(const Duration(seconds: 10));
        provider.answerCall();
        async.flushMicrotasks();

        // Default persona (Riley/Mom) uses the bundled peer asset.
        expect(
          audio.log,
          [
            'playRingtone',
            'stopAll',
            'playPeerAudio:assets/audio/peer_mom.mp3'
          ],
        );
        provider.dispose();
      });
    });

    test('selection is ignored mid-simulation', () {
      fakeAsync((async) {
        final audio = RecordingAudioService();
        final provider =
            CallProvider(audioService: audio, assetProbe: _allPresent);
        provider.startCountdown(delaySeconds: 10);
        provider.selectRecordedVoice(
            scenarioId: 's1', filePath: '/tmp/voice/s1.m4a');
        expect(provider.usesRecordedVoice, isFalse);
        provider.dispose();
      });
    });

    test('isCallAudioActive blocks recording during ringing/active', () {
      fakeAsync((async) {
        final audio = RecordingAudioService();
        final provider =
            CallProvider(audioService: audio, assetProbe: _allPresent);
        expect(provider.isCallAudioActive, isFalse);
        provider.startCountdown(delaySeconds: 10);
        async.elapse(const Duration(seconds: 10));
        expect(provider.isCallAudioActive, isTrue);
        provider.answerCall();
        expect(provider.isCallAudioActive, isTrue);
        provider.endCall();
        expect(provider.isCallAudioActive, isFalse);
        provider.dispose();
      });
    });
  });
}
