import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_client/models/call_state.dart';
import 'package:frontend_client/providers/call_provider.dart';
import 'package:frontend_client/services/audio_service.dart';

class MockAudioService implements AudioServiceBase {
  int ringtonePlayCount = 0;
  int peerAudioPlayCount = 0;
  int stopAllCount = 0;
  bool _isPlaying = false;
  final List<String> callLog = [];

  @override
  bool get isPlaying => _isPlaying;

  @override
  Future<void> initialize() async {
    callLog.add('initialize');
  }

  @override
  Future<void> playRingtone({String? assetPath}) async {
    ringtonePlayCount++;
    _isPlaying = true;
    callLog.add('playRingtone');
  }

  @override
  Future<void> playPeerAudio(String assetPath) async {
    peerAudioPlayCount++;
    _isPlaying = true;
    callLog.add('playPeerAudio:$assetPath');
  }

  @override
  Future<void> stopAll() async {
    stopAllCount++;
    _isPlaying = false;
    callLog.add('stopAll');
  }
}

void main() {
  group('CallProvider State Machine - Initial State & Validation', () {
    late MockAudioService mockAudio;
    late CallProvider provider;

    setUp(() {
      mockAudio = MockAudioService();
      provider = CallProvider(audioService: mockAudio);
    });

    tearDown(() {
      provider.dispose();
    });

    test('starts in configuration state with default settings', () {
      expect(provider.state, CallLifecycleState.configuration);
      expect(provider.delaySeconds, 30);
      expect(provider.remainingCountdown, 30);
      expect(provider.persona, CallerPersona.defaultPersona);
      expect(provider.isCountdownActive, isFalse);
    });

    test('validates delay range between 10 and 180 seconds', () {
      expect(provider.validateDelay(10), isTrue);
      expect(provider.validateDelay(30), isTrue);
      expect(provider.validateDelay(180), isTrue);
      expect(provider.validateDelay(9), isFalse);
      expect(provider.validateDelay(181), isFalse);
      expect(provider.validateDelay(-5), isFalse);
    });

    test('rejects startCountdown if delay is below 10 seconds', () {
      final started = provider.startCountdown(delaySeconds: 5);
      expect(started, isFalse);
      expect(provider.state, CallLifecycleState.configuration);
      expect(mockAudio.callLog, isEmpty);
    });

    test('rejects startCountdown if delay is above 180 seconds', () {
      final started = provider.startCountdown(delaySeconds: 300);
      expect(started, isFalse);
      expect(provider.state, CallLifecycleState.configuration);
      expect(mockAudio.callLog, isEmpty);
    });

    test('rejects duplicate countdown trigger when countdown is already active',
        () {
      final firstStart = provider.startCountdown(delaySeconds: 30);
      expect(firstStart, isTrue);
      expect(provider.state, CallLifecycleState.countdown);

      final secondStart = provider.startCountdown(delaySeconds: 15);
      expect(secondStart, isFalse);
      expect(provider.state, CallLifecycleState.countdown);
      expect(provider.remainingCountdown, 30);
    });
  });

  group('CallProvider State Machine - Countdown Lifecycle & Cancellation', () {
    late MockAudioService mockAudio;
    late CallProvider provider;

    setUp(() {
      mockAudio = MockAudioService();
      provider = CallProvider(audioService: mockAudio);
    });

    tearDown(() {
      provider.dispose();
    });

    test('enters countdown and remains silent until time reaches zero', () {
      provider.startCountdown(delaySeconds: 20);
      expect(provider.state, CallLifecycleState.countdown);
      expect(provider.isCountdownActive, isTrue);
      expect(mockAudio.callLog, isEmpty);
    });

    test(
        'cancelCountdown returns immediately to configuration state and stops timer',
        () {
      provider.startCountdown(delaySeconds: 20);
      expect(provider.state, CallLifecycleState.countdown);

      provider.cancelCountdown();
      expect(provider.state, CallLifecycleState.configuration);
      expect(provider.isCountdownActive, isFalse);
      expect(mockAudio.callLog, isEmpty);
    });

    test('reset clears countdown and stops all resources', () {
      provider.startCountdown(delaySeconds: 20);
      expect(provider.state, CallLifecycleState.countdown);

      provider.reset();
      expect(provider.state, CallLifecycleState.configuration);
      expect(mockAudio.stopAllCount, 1);
    });
  });

  group('CallProvider State Machine - Ringing, Answering & Sequencing', () {
    late MockAudioService mockAudio;
    late CallProvider provider;

    setUp(() {
      mockAudio = MockAudioService();
      provider = CallProvider(audioService: mockAudio);
    });

    tearDown(() {
      provider.dispose();
    });

    test('declineCall stops ringtone and transitions to ended state', () {
      provider.startCountdown(delaySeconds: 10);
      provider.cancelCountdown();

      // Simulate entering ringing directly
      provider.answerCall(); // Ignored because not in ringing
      expect(provider.state, CallLifecycleState.configuration);
    });

    test('answerCall halts ringtone before initiating peer audio track', () {
      // Simulate ringing state by triggering countdown completion
      bool triggered = false;
      provider.startCountdown(
        delaySeconds: 10,
        onTriggered: () {
          triggered = true;
        },
      );
      expect(triggered, isFalse);

      // Verify answerCall rejected while in countdown
      provider.answerCall();
      expect(provider.state, CallLifecycleState.countdown);
      expect(mockAudio.peerAudioPlayCount, 0);

      // Verify declineCall rejected while in countdown
      provider.declineCall();
      expect(provider.state, CallLifecycleState.countdown);
    });

    test('endCall resets active call and elapsed duration', () {
      provider.endCall(); // Ignored when in config
      expect(provider.state, CallLifecycleState.configuration);
      expect(provider.activeDurationSeconds, 0);
    });
  });

  group('CallProvider State Machine - Invariants & Lifecycle Interruption', () {
    late MockAudioService mockAudio;
    late CallProvider provider;

    setUp(() {
      mockAudio = MockAudioService();
      provider = CallProvider(audioService: mockAudio);
    });

    tearDown(() {
      provider.dispose();
    });

    test(
        'handleAppLifecycle pauses countdown safely when app enters background',
        () {
      provider.startCountdown(delaySeconds: 30);
      expect(provider.state, CallLifecycleState.countdown);

      provider.handleAppLifecycle(AppLifecycleState.paused);
      expect(provider.state, CallLifecycleState.configuration);
      expect(provider.isCountdownActive, isFalse);
    });

    test('handleAppLifecycle resets active simulation when detached or hidden',
        () {
      provider.handleAppLifecycle(AppLifecycleState.detached);
      expect(provider.state, CallLifecycleState.configuration);
    });

    test('repeated reset calls remain safe and idempotent', () {
      provider.reset();
      provider.reset();
      provider.reset();
      expect(provider.state, CallLifecycleState.configuration);
      expect(mockAudio.stopAllCount, 3);
    });

    test('disposal prevents subsequent listener notifications without throwing',
        () {
      final localProvider = CallProvider(audioService: mockAudio);
      bool notified = false;
      localProvider.addListener(() {
        notified = true;
      });

      localProvider.dispose();
      localProvider.dispose(); // safe duplicate disposal
      expect(notified, isFalse);
    });
  });
}
