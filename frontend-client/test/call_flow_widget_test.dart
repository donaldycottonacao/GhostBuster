// Phase 9: widget tests for the real screens wired through ScreenPreviewHost.
//
// testWidgets runs on a fake clock, so `tester.pump(Duration)` advances the
// provider's real Timer.periodic deterministically. Audio is a recording fake.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_client/main.dart';
import 'package:frontend_client/models/call_state.dart';
import 'package:frontend_client/providers/call_provider.dart';
import 'package:frontend_client/widgets/slide_button.dart';

import 'helpers/audio_fakes.dart';
import 'helpers/real_fonts.dart';

const _setupTitle = 'ARM STEALTH MODE';
const _incomingTitle = 'Incoming call...';

/// Counts startCountdown invocations so duplicate triggers are visible.
class CountingCallProvider extends CallProvider {
  CountingCallProvider({super.audioService});

  int startCalls = 0;

  @override
  bool startCountdown({
    int? delaySeconds,
    CallerPersona? persona,
    VoidCallback? onTriggered,
  }) {
    startCalls++;
    return super.startCountdown(
      delaySeconds: delaySeconds,
      persona: persona,
      onTriggered: onTriggered,
    );
  }
}

late RecordingAudioService audio;
late CountingCallProvider provider;

Future<void> pumpApp(WidgetTester tester) async {
  audio = RecordingAudioService();
  provider = CountingCallProvider(audioService: audio);
  // GhostBusterApp's ChangeNotifierProvider owns and disposes the provider.
  await tester.pumpWidget(GhostBusterApp(provider: provider));
  await tester.pump();
}

Future<void> tapText(WidgetTester tester, String text) async {
  final finder = find.text(text);
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pump();
}

/// Selects a delay chip and arms stealth mode without advancing the clock.
Future<void> arm(WidgetTester tester, {String delayLabel = '10 sec'}) async {
  await tapText(tester, delayLabel);
  await tapText(tester, 'ARM STEALTH MODE');
}

Future<void> slide(WidgetTester tester, {double fraction = 1.0}) async {
  final slider = find.byType(SlideButton);
  await tester.ensureVisible(slider);
  final rect = tester.getRect(slider);
  await tester.dragFrom(
    Offset(rect.left + 35, rect.center.dy),
    Offset(rect.width * fraction, 0),
  );
  await tester.pump();
}

Future<void> tapIcon(WidgetTester tester, IconData icon) async {
  final finder = find.byIcon(icon);
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pump();
}

/// Countdown -> ringing through the real timer.
Future<void> ringViaCountdown(WidgetTester tester) async {
  await arm(tester);
  await tester.pump(const Duration(seconds: 10));
  expect(find.text(_incomingTitle), findsOneWidget);
}

Future<void> background(WidgetTester tester) async {
  for (final state in [
    AppLifecycleState.inactive,
    AppLifecycleState.hidden,
    AppLifecycleState.paused,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(state);
  }
  await tester.pump();
}

Future<void> foreground(WidgetTester tester) async {
  for (final state in [
    AppLifecycleState.hidden,
    AppLifecycleState.inactive,
    AppLifecycleState.resumed,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(state);
  }
  await tester.pump();
}

void main() {
  group('Configuration screen', () {
    testWidgets('renders controls and arms exactly one countdown',
        (tester) async {
      await pumpApp(tester);
      expect(find.text(_setupTitle), findsOneWidget);
      expect(find.text('10 sec'), findsOneWidget);
      expect(find.text('3 min'), findsOneWidget);

      await arm(tester, delayLabel: '30 sec');
      expect(provider.state, CallLifecycleState.countdown);
      expect(find.text('00:30'), findsOneWidget);
      expect(audio.log, isEmpty);
      // Regression (found on emulator): one press used to call it twice.
      expect(provider.startCalls, 1);
    });

    testWidgets('double-tapping ARM starts one simulation and warns',
        (tester) async {
      await pumpApp(tester);
      final armButton = find.text('ARM STEALTH MODE');
      await tester.ensureVisible(armButton);
      await tester.tap(armButton);
      await tester.tap(armButton); // second tap lands before the rebuild
      await tester.pump();

      expect(
        find.text(
          'A simulation is already active. Please wait or cancel the current call.',
        ),
        findsOneWidget,
      );
      expect(provider.remainingCountdown, 10);

      await tester.pump(const Duration(seconds: 10));
      expect(find.text(_incomingTitle), findsOneWidget);
      expect(audio.count('playRingtone'), 1);
    });
  });

  group('Countdown screen', () {
    testWidgets('shows provider time, stays silent, rings at zero',
        (tester) async {
      await pumpApp(tester);
      await arm(tester);
      expect(find.text('00:10'), findsOneWidget);
      expect(find.text('SILENT COUNTDOWN'), findsOneWidget);

      await tester.pump(const Duration(seconds: 9));
      expect(find.text('00:01'), findsOneWidget);
      expect(audio.log, isEmpty);

      await tester.pump(const Duration(seconds: 1));
      expect(find.text(_incomingTitle), findsOneWidget);
      expect(audio.log, ['playRingtone']);
    });

    testWidgets('cancel returns to setup and the old deadline never rings',
        (tester) async {
      await pumpApp(tester);
      await arm(tester);
      await tester.pump(const Duration(seconds: 9));
      await tapText(tester, 'CANCEL');

      expect(find.text(_setupTitle), findsOneWidget);
      await tester.pump(const Duration(minutes: 1));
      expect(find.text(_setupTitle), findsOneWidget);
      expect(find.text(_incomingTitle), findsNothing);
      expect(audio.log, isEmpty);
    });
  });

  group('Incoming call screen and answer gesture', () {
    testWidgets('full slide answers exactly once; ringtone stops first',
        (tester) async {
      await pumpApp(tester);
      await ringViaCountdown(tester);

      await slide(tester);
      expect(provider.state, CallLifecycleState.active);
      expect(find.text('Connected'), findsOneWidget);
      expect(find.text(_incomingTitle), findsNothing);
      expect(audio.log, [
        'playRingtone',
        'stopAll',
        'playPeerAudio:assets/audio/peer_mom.mp3',
      ]);
    });

    testWidgets('incomplete slide does not answer and the thumb resets',
        (tester) async {
      await pumpApp(tester);
      await ringViaCountdown(tester);
      await tester.ensureVisible(find.byType(SlideButton));
      await tester.pump();
      final thumbStart = tester.getTopLeft(find.byIcon(Icons.call));

      await slide(tester, fraction: 0.3);
      expect(provider.state, CallLifecycleState.ringing);
      expect(audio.count('playPeerAudio'), 0);
      expect(tester.getTopLeft(find.byIcon(Icons.call)), thumbStart);
    });

    testWidgets('slide plus tap before rebuild still starts one voice',
        (tester) async {
      await pumpApp(tester);
      await ringViaCountdown(tester);
      final tapAnswer = find.text('TAP TO ANSWER');
      await tester.ensureVisible(tapAnswer);

      final slider = tester.getRect(find.byType(SlideButton));
      await tester.dragFrom(
        Offset(slider.left + 35, slider.center.dy),
        Offset(slider.width, 0),
      );
      await tester.tap(tapAnswer);
      await tester.tap(tapAnswer);
      await tester.pump();

      expect(provider.state, CallLifecycleState.active);
      expect(audio.count('playPeerAudio'), 1);
      expect(audio.count('stopAll'), 1);
    });

    testWidgets('screen-reader tap on the slider answers once', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpApp(tester);
      await ringViaCountdown(tester);

      tester.semantics.tap(
        find.semantics.byLabel(RegExp('Double tap or slide across to answer')),
      );
      await tester.pump();

      expect(provider.state, CallLifecycleState.active);
      expect(audio.count('playPeerAudio'), 1);
      semantics.dispose();
    });

    testWidgets('call actions expose meaningful semantic labels',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpApp(tester);
      expect(find.bySemanticsLabel('Arm Stealth Mode'), findsOneWidget);

      await arm(tester);
      expect(find.bySemanticsLabel('Cancel countdown'), findsOneWidget);

      await tester.pump(const Duration(seconds: 10));
      expect(
        find.bySemanticsLabel(RegExp('slide to answer', caseSensitive: false)),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Tap to answer call'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Decline call')), findsOneWidget);

      await tapText(tester, 'TAP TO ANSWER');
      expect(find.bySemanticsLabel(RegExp('End Call')), findsOneWidget);

      await tapIcon(tester, Icons.call_end_rounded);
      expect(find.bySemanticsLabel(RegExp('Return to setup')), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('decline stops the ringtone and shows the ended screen',
        (tester) async {
      await pumpApp(tester);
      await ringViaCountdown(tester);
      await tapIcon(tester, Icons.call_end_rounded);

      expect(provider.state, CallLifecycleState.ended);
      expect(find.text('Call ended'), findsOneWidget);
      expect(audio.log, ['playRingtone', 'stopAll']);
      // A declined call has no duration (regression: used to show 00:18).
      expect(find.text('Riley Morgan  ·  00:00'), findsOneWidget);

      await tapText(tester, 'RETURN TO SETUP');
      expect(find.text(_setupTitle), findsOneWidget);
    });
  });

  group('Active call screen', () {
    testWidgets('duration follows the provider timer and hang-up cleans up',
        (tester) async {
      await pumpApp(tester);
      await ringViaCountdown(tester);
      await tapText(tester, 'TAP TO ANSWER');

      // Regression: a just-answered call used to show a placeholder 00:18.
      expect(find.text('00:00'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      expect(find.text('00:05'), findsOneWidget);

      await tapIcon(tester, Icons.call_end_rounded);
      expect(find.text('Call ended'), findsOneWidget);
      expect(find.text('Riley Morgan  ·  00:05'), findsOneWidget);
      expect(audio.log.last, 'stopAll');

      await tester.pump(const Duration(seconds: 10));
      expect(provider.activeDurationSeconds, 5);

      await tapText(tester, 'RETURN TO SETUP');
      expect(find.text(_setupTitle), findsOneWidget);
      expect(provider.activeDurationSeconds, 0);
    });
  });

  group('Lifecycle interruption (via WidgetsBindingObserver)', () {
    testWidgets('backgrounding during countdown cancels it for good',
        (tester) async {
      await pumpApp(tester);
      await arm(tester);
      await tester.pump(const Duration(seconds: 4));

      await background(tester);
      await foreground(tester);
      expect(find.text(_setupTitle), findsOneWidget);

      await tester.pump(const Duration(minutes: 1));
      expect(find.text(_incomingTitle), findsNothing);
      expect(audio.log, isEmpty);
    });

    testWidgets('backgrounding while ringing stops audio; resume shows setup',
        (tester) async {
      await pumpApp(tester);
      await ringViaCountdown(tester);

      await background(tester);
      expect(audio.log, ['playRingtone', 'stopAll']);
      await foreground(tester);
      expect(find.text(_setupTitle), findsOneWidget);
    });

    testWidgets('backgrounding during the active call ends it', (tester) async {
      await pumpApp(tester);
      await ringViaCountdown(tester);
      await tapText(tester, 'TAP TO ANSWER');
      await tester.pump(const Duration(seconds: 3));

      await background(tester);
      await foreground(tester);
      await tester.pump(const Duration(seconds: 10));

      expect(find.text(_setupTitle), findsOneWidget);
      expect(provider.activeDurationSeconds, 0);
      expect(audio.log.last, 'stopAll');
    });

    testWidgets('inactive alone (notification shade) keeps the countdown',
        (tester) async {
      await pumpApp(tester);
      await arm(tester);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump(const Duration(seconds: 10));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      expect(find.text(_incomingTitle), findsOneWidget);
    });
  });

  group('Repeated use', () {
    testWidgets('three answered calls and a cancel leave no stale state',
        (tester) async {
      await pumpApp(tester);

      for (var cycle = 0; cycle < 3; cycle++) {
        await ringViaCountdown(tester);
        await slide(tester);
        await tester.pump(const Duration(seconds: 2));
        await tapIcon(tester, Icons.call_end_rounded);
        await tapText(tester, 'RETURN TO SETUP');
        expect(find.text(_setupTitle), findsOneWidget);
        expect(audio.isPlaying, isFalse);
      }

      await arm(tester);
      await tapText(tester, 'CANCEL');
      await tester.pump(const Duration(minutes: 1));

      expect(audio.count('playRingtone'), 3);
      expect(audio.count('playPeerAudio'), 3);
      expect(find.text(_setupTitle), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Responsive layout and localization', () {
    // Measured with real Roboto metrics (see helpers/real_fonts.dart): the
    // default test font is much wider and reports overflows that do not occur
    // on devices. 1.5x is the largest scale at which every screen fits; 1.75x+
    // overflows setup/countdown/ended (documented as a known limitation).
    setUpAll(() async {
      expect(await loadSdkRoboto(), isTrue,
          reason: 'Roboto from the Flutter SDK is required for layout tests');
    });

    for (final locale in ['en', 'tl', 'ceb']) {
      testWidgets(
          'all five screens fit 320x568 at 1.5x text in $locale (no overflow)',
          (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
        tester.platformDispatcher.textScaleFactorTestValue = 1.5;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        await pumpApp(tester);
        provider.setLocale(Locale(locale));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'setup');

        provider.startCountdown(delaySeconds: 10);
        await tester.pump();
        expect(tester.takeException(), isNull, reason: 'countdown');

        await tester.pump(const Duration(seconds: 10));
        expect(tester.takeException(), isNull, reason: 'ringing');
        expect(find.byType(SlideButton), findsOneWidget);
        expect(find.byIcon(Icons.call_end_rounded), findsOneWidget);

        provider.answerCall();
        await tester.pump();
        expect(tester.takeException(), isNull, reason: 'active');
        expect(find.byIcon(Icons.call_end_rounded), findsOneWidget);

        provider.endCall();
        await tester.pump();
        expect(tester.takeException(), isNull, reason: 'ended');
      });
    }
  });
}
