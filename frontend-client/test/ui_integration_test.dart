import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_client/main.dart';
import 'package:frontend_client/models/call_state.dart';
import 'package:frontend_client/providers/call_provider.dart';
import 'package:frontend_client/services/audio_service.dart';
import 'package:frontend_client/widgets/slide_button.dart';

class MockAudioService implements AudioServiceBase {
  int ringtonePlayCount = 0;
  int peerAudioPlayCount = 0;
  int stopRingtoneCount = 0;
  int stopVoiceCount = 0;
  int stopAllCount = 0;
  bool _isPlaying = false;
  bool _isRingtonePlaying = false;
  bool _isVoicePlaying = false;
  String? _currentAsset;

  @override
  bool get isPlaying => _isPlaying;

  @override
  bool get isRingtonePlaying => _isRingtonePlaying;

  @override
  bool get isVoicePlaying => _isVoicePlaying;

  @override
  String? get currentAsset => _currentAsset;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> playRingtone({String? assetPath}) async {
    ringtonePlayCount++;
    _isPlaying = true;
    _isRingtonePlaying = true;
    _currentAsset = assetPath ?? 'assets/audio/ringtone_ios.mp3';
  }

  @override
  Future<void> stopRingtone() async {
    stopRingtoneCount++;
    _isRingtonePlaying = false;
    _isPlaying = _isVoicePlaying;
  }

  @override
  Future<void> playPeerAudio(String assetPath) async {
    peerAudioPlayCount++;
    _isPlaying = true;
    _isVoicePlaying = true;
    _currentAsset = assetPath;
  }

  @override
  Future<void> playScenarioVoice(String assetPath) => playPeerAudio(assetPath);

  @override
  Future<void> stopVoice() async {
    stopVoiceCount++;
    _isVoicePlaying = false;
    _isPlaying = _isRingtonePlaying;
  }

  @override
  Future<void> stopAll() async {
    stopAllCount++;
    _isPlaying = false;
    _isRingtonePlaying = false;
    _isVoicePlaying = false;
    _currentAsset = null;
  }

  @override
  Future<void> dispose() async {
    await stopAll();
  }
}

void main() {
  group('UI Integration - Full User Journey & State Binding', () {
    late MockAudioService mockAudio;
    late CallProvider callProvider;

    setUp(() {
      mockAudio = MockAudioService();
      callProvider = CallProvider(audioService: mockAudio);
    });

    tearDown(() {
      callProvider.dispose();
    });

    testWidgets(
      'complete call flow: trigger -> countdown -> answer -> active -> hang-up -> reset',
      (tester) async {
        await tester.pumpWidget(GhostBusterApp(provider: callProvider));
        await tester.pumpAndSettle();

        // 1. Initial configuration screen
        expect(find.text('Set your exit'), findsOneWidget);
        expect(callProvider.state, CallLifecycleState.configuration);

        // 2. Select 30s delay and arm stealth mode
        final armButton = find.text('ARM STEALTH MODE');
        await tester.ensureVisible(armButton);
        await tester.tap(armButton);
        await tester.pumpAndSettle();

        // 3. Silent countdown screen appears
        expect(callProvider.state, CallLifecycleState.countdown);
        expect(find.text('SILENT COUNTDOWN'), findsOneWidget);
        expect(find.text('00:30'), findsOneWidget);
        expect(mockAudio.ringtonePlayCount, 0);

        // 4. Trigger incoming call via preview trigger hook
        final previewButton = find.text('Preview incoming call screen');
        await tester.ensureVisible(previewButton);
        await tester.tap(previewButton);
        await tester.pumpAndSettle();

        // 5. Incoming call screen active and ringtone playing
        expect(callProvider.state, CallLifecycleState.ringing);
        expect(find.text('Incoming call...'), findsOneWidget);
        expect(find.text('Riley Morgan'), findsOneWidget);
        expect(mockAudio.ringtonePlayCount, 1);

        // 6. Answer call via SlideButton
        final slideButton = find.byType(SlideButton);
        await tester.ensureVisible(slideButton);
        final sliderRect = tester.getRect(slideButton);
        await tester.dragFrom(
          Offset(sliderRect.left + 35, sliderRect.center.dy),
          Offset(sliderRect.width, 0),
        );
        await tester.pumpAndSettle();

        // 7. Active call screen active, ringtone stopped, peer audio playing
        expect(callProvider.state, CallLifecycleState.active);
        expect(find.text('Connected'), findsOneWidget);
        expect(mockAudio.stopAllCount, greaterThanOrEqualTo(1));
        expect(mockAudio.peerAudioPlayCount, 1);

        // 8. Hang up via END CALL button
        final endCallButton = find.byIcon(Icons.call_end_rounded);
        await tester.ensureVisible(endCallButton);
        await tester.tap(endCallButton);
        await tester.pumpAndSettle();

        // 9. Call ended screen appears
        expect(callProvider.state, CallLifecycleState.ended);
        expect(find.text('Call ended'), findsOneWidget);
        expect(find.text('Your call has ended.'), findsOneWidget);

        // 10. Return to setup returns cleanly to configuration
        final returnButton = find.text('RETURN TO SETUP');
        await tester.ensureVisible(returnButton);
        await tester.tap(returnButton);
        await tester.pumpAndSettle();

        expect(callProvider.state, CallLifecycleState.configuration);
        expect(find.text('Set your exit'), findsOneWidget);
      },
    );

    testWidgets(
      'countdown cancellation returns immediately to setup without ringing',
      (tester) async {
        await tester.pumpWidget(GhostBusterApp(provider: callProvider));
        await tester.pumpAndSettle();

        final armButton = find.text('ARM STEALTH MODE');
        await tester.ensureVisible(armButton);
        await tester.tap(armButton);
        await tester.pumpAndSettle();

        expect(callProvider.state, CallLifecycleState.countdown);
        expect(find.text('SILENT COUNTDOWN'), findsOneWidget);

        final cancelButton = find.text('CANCEL');
        await tester.ensureVisible(cancelButton);
        await tester.tap(cancelButton);
        await tester.pumpAndSettle();

        expect(callProvider.state, CallLifecycleState.configuration);
        expect(find.text('Set your exit'), findsOneWidget);
        expect(mockAudio.ringtonePlayCount, 0);
      },
    );

    testWidgets(
      'incoming call decline stops ringtone and transitions to ended screen',
      (tester) async {
        await tester.pumpWidget(GhostBusterApp(provider: callProvider));
        await tester.pumpAndSettle();

        callProvider.triggerRinging();
        await tester.pumpAndSettle();

        expect(callProvider.state, CallLifecycleState.ringing);
        expect(mockAudio.ringtonePlayCount, 1);

        final declineButton = find.byIcon(Icons.call_end_rounded);
        await tester.ensureVisible(declineButton);
        await tester.tap(declineButton);
        await tester.pumpAndSettle();

        expect(callProvider.state, CallLifecycleState.ended);
        expect(find.text('Call ended'), findsOneWidget);
        expect(mockAudio.stopAllCount, greaterThanOrEqualTo(1));
      },
    );

    testWidgets(
      'accessible tap-to-answer alternative answers call successfully',
      (tester) async {
        await tester.pumpWidget(GhostBusterApp(provider: callProvider));
        await tester.pumpAndSettle();

        callProvider.triggerRinging();
        await tester.pumpAndSettle();

        expect(callProvider.state, CallLifecycleState.ringing);

        // Tap the accessible alternative button
        final tapAnswerButton = find.text('TAP TO ANSWER');
        await tester.ensureVisible(tapAnswerButton);
        await tester.tap(tapAnswerButton);
        await tester.pumpAndSettle();

        expect(callProvider.state, CallLifecycleState.active);
        expect(find.text('Connected'), findsOneWidget);
        expect(mockAudio.peerAudioPlayCount, 1);
      },
    );

    testWidgets(
      'in-call mute and speaker controls toggle provider state',
      (tester) async {
        await tester.pumpWidget(GhostBusterApp(provider: callProvider));
        await tester.pumpAndSettle();

        callProvider.triggerRinging();
        callProvider.answerCall();
        await tester.pumpAndSettle();

        expect(callProvider.state, CallLifecycleState.active);
        expect(callProvider.isMuted, isFalse);

        // Toggle mute
        final muteButton = find.text('Mute');
        await tester.ensureVisible(muteButton);
        await tester.tap(muteButton);
        await tester.pump();

        expect(callProvider.isMuted, isTrue);
        expect(find.text('Unmute'), findsOneWidget);

        // Toggle speaker
        final speakerButton = find.text('Speaker');
        await tester.ensureVisible(speakerButton);
        await tester.tap(speakerButton);
        await tester.pump();

        expect(callProvider.isSpeakerOn, isTrue);
      },
    );

    testWidgets(
      'responsive layout: renders cleanly on compact 320x568 screen without overflow',
      (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(GhostBusterApp(provider: callProvider));
        await tester.pumpAndSettle();

        expect(find.text('Set your exit'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
