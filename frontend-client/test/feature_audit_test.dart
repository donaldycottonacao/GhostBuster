// Feature & UX audit: tests for caller selection, ringtone wiring, setup
// persistence across calls, keep-screen-on, audio readiness, language choice,
// and the active-call script toggle.

import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_client/main.dart';
import 'package:frontend_client/models/call_state.dart';
import 'package:frontend_client/providers/call_provider.dart';
import 'package:frontend_client/services/device_services.dart';

import 'helpers/audio_fakes.dart';

class FakeScreenWake implements ScreenWakeController {
  final List<bool> calls = [];

  @override
  Future<void> setKeepScreenOn(bool keepOn) async => calls.add(keepOn);
}

final _landlord = CallerPersona.defaultPersonas[1];
final _office = CallerPersona.defaultPersonas[2];

Future<bool> _allPresent(String _) async => true;

void main() {
  group('Keep screen on during a simulation', () {
    test('on for countdown/ringing/active, off otherwise, no redundant calls',
        () {
      fakeAsync((async) {
        final wake = FakeScreenWake();
        final provider = CallProvider(
          audioService: RecordingAudioService(),
          screenWake: wake,
          assetProbe: _allPresent,
        );

        provider.startCountdown(delaySeconds: 10);
        async.elapse(const Duration(seconds: 10)); // ringing
        provider.answerCall();
        async.elapse(const Duration(seconds: 3)); // duration ticks
        expect(wake.calls, [true], reason: 'one call while staying active');

        provider.endCall();
        expect(wake.calls, [true, false]);

        provider.returnToSetup();
        provider.startCountdown(delaySeconds: 10);
        provider.cancelCountdown();
        expect(wake.calls, [true, false, true, false]);

        provider.startCountdown(delaySeconds: 10);
        provider.dispose();
        async.flushMicrotasks();
        expect(wake.calls.last, isFalse, reason: 'released on dispose');
        expect(provider.isScreenKeptOn, isFalse);
      });
    });

    test('lifecycle interruption releases the screen', () {
      fakeAsync((async) {
        final wake = FakeScreenWake();
        final provider = CallProvider(
          audioService: RecordingAudioService(),
          screenWake: wake,
          assetProbe: _allPresent,
        );
        provider.triggerRinging();
        provider.handleAppLifecycle(AppLifecycleState.paused);
        expect(wake.calls, [true, false]);
        provider.dispose();
      });
    });

    test('a failing platform channel never breaks the call flow', () {
      fakeAsync((async) {
        final provider = CallProvider(audioService: RecordingAudioService());
        expect(
            () => provider.startCountdown(delaySeconds: 10), returnsNormally);
        async.elapse(const Duration(seconds: 10));
        expect(provider.state, CallLifecycleState.ringing);
        provider.dispose();
        async.flushMicrotasks();
      });
    });
  });

  group('Ringtone selection', () {
    test('selected ringtone asset is what rings', () {
      fakeAsync((async) {
        final audio = RecordingAudioService();
        final provider =
            CallProvider(audioService: audio, assetProbe: _allPresent);

        provider.triggerRinging();
        expect(audio.lastRingtoneAsset, 'assets/audio/hangouts_call.mp3');
        provider.declineCall();
        provider.returnToSetup();

        provider.setRingtone('living');
        provider.triggerRinging();
        expect(audio.lastRingtoneAsset, 'assets/audio/living_tune.mp3');
        provider.dispose();
      });
    });

    test('unknown ids and changes during a simulation are ignored', () {
      fakeAsync((async) {
        final provider = CallProvider(
            audioService: RecordingAudioService(), assetProbe: _allPresent);
        provider.setRingtone('does_not_exist');
        expect(provider.ringtoneId, RingtoneOption.defaultId);

        provider.startCountdown(delaySeconds: 10);
        provider.setRingtone('tskk');
        expect(provider.ringtoneId, RingtoneOption.defaultId);
        provider.dispose();
      });
    });
  });

  group('Audio readiness check', () {
    test('reports missing ringtone and voice without blocking', () async {
      final provider = CallProvider(
        audioService: RecordingAudioService(),
        // Treat the ringtone asset as missing, voice assets as present.
        assetProbe: (path) async => !path.contains('hangouts'),
      );
      await provider.refreshAudioReadiness();
      expect(provider.ringtoneMissing, isTrue);
      expect(provider.voiceMissing, isFalse);

      provider.setPersona(_office); // no voice track at all
      await pumpEventQueue();
      expect(provider.voiceMissing, isTrue);
      expect(provider.startCountdown(delaySeconds: 10), isTrue);
      provider.dispose();
    });

    test('a superseded check cannot overwrite the newer result', () async {
      final firstGate = Completer<bool>();
      var call = 0;
      final provider = CallProvider(
        audioService: RecordingAudioService(),
        // Check #1 (slow) will say "missing"; check #2 answers "present".
        assetProbe: (path) =>
            ++call == 1 ? firstGate.future : Future.value(true),
      );
      final slow = provider.refreshAudioReadiness();
      await provider.refreshAudioReadiness();
      expect(provider.ringtoneMissing, isFalse);

      firstGate.complete(false);
      await slow;
      expect(provider.ringtoneMissing, isFalse, reason: 'stale result dropped');
      provider.dispose();
    });

    test('a probe that throws is contained', () async {
      final provider = CallProvider(
        audioService: RecordingAudioService(),
        assetProbe: (_) => throw StateError('bundle unavailable'),
      );
      await expectLater(provider.refreshAudioReadiness(), completes);
      expect(provider.ringtoneMissing, isFalse);
      provider.dispose();
    });
  });

  group('Configuration survives a finished or interrupted call', () {
    void configure(CallProvider p) {
      p
        ..setPersona(_landlord)
        ..setRingtone('tskk')
        ..setScriptLanguage('tl')
        ..setVoiceScriptText('Custom script')
        ..setSituationText('Dinner');
    }

    void expectConfigured(CallProvider p) {
      expect(p.persona.id, 'landlord');
      expect(p.ringtoneId, 'tskk');
      expect(p.languageCode, 'tl');
      expect(p.voiceScriptText, 'Custom script');
      expect(p.situationText, 'Dinner');
      expect(p.delaySeconds, 60);
    }

    test('after hang-up and return to setup', () {
      fakeAsync((async) {
        final audio = RecordingAudioService();
        final p = CallProvider(audioService: audio, assetProbe: _allPresent);
        configure(p);
        p.startCountdown(delaySeconds: 60);
        async.elapse(const Duration(seconds: 60));
        p.answerCall();
        async.elapse(const Duration(seconds: 4));
        p.endCall();
        p.returnToSetup();

        expect(p.state, CallLifecycleState.configuration);
        expectConfigured(p);
        expect(p.activeDurationSeconds, 0);
        expect(audio.log.last, 'stopAll');
        p.dispose();
      });
    });

    test('after backgrounding during an active call', () {
      fakeAsync((async) {
        final p = CallProvider(
            audioService: RecordingAudioService(), assetProbe: _allPresent);
        configure(p);
        p.startCountdown(delaySeconds: 60);
        async.elapse(const Duration(seconds: 60));
        p.answerCall();
        p.handleAppLifecycle(AppLifecycleState.paused);

        expect(p.state, CallLifecycleState.configuration);
        expectConfigured(p);
        p.dispose();
      });
    });

    test('reset() still restores factory defaults (error recovery)', () {
      final p = CallProvider(
          audioService: RecordingAudioService(), assetProbe: _allPresent);
      configure(p);
      p.reset();
      expect(p.persona, CallerPersona.defaultPersona);
      expect(p.ringtoneId, RingtoneOption.defaultId);
      p.dispose();
    });
  });

  group('App language', () {
    test('follows the device by default; override and clear', () {
      final p = CallProvider(
          audioService: RecordingAudioService(), assetProbe: _allPresent);
      expect(p.localeOverride, isNull);
      p.setLocale(const Locale('ceb'));
      expect(p.localeOverride, const Locale('ceb'));
      p.useSystemLocale();
      expect(p.localeOverride, isNull);
      expect(p.currentLocale.languageCode, 'en');
      p.dispose();
    });
  });

  group('Setup, call and ended screens (widgets)', () {
    late RecordingAudioService audio;
    late CallProvider provider;

    Future<void> pumpApp(
      WidgetTester tester, {
      AssetProbe probe = _allPresent,
    }) async {
      audio = RecordingAudioService();
      provider = CallProvider(
        audioService: audio,
        screenWake: FakeScreenWake(),
        assetProbe: probe,
      );
      await tester.pumpWidget(GhostBusterApp(provider: provider));
      await tester.pumpAndSettle();
    }

    Future<void> tapText(WidgetTester tester, String text) async {
      final finder = find.text(text);
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    testWidgets('caller picker changes the caller everywhere', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpApp(tester);
      final card = find.bySemanticsLabel(RegExp('^Choose caller'));
      expect(card, findsOneWidget, reason: 'caller card is a labelled button');
      await tester.ensureVisible(card);
      await tester.tap(card);
      await tester.pumpAndSettle();

      expect(find.text('Choose caller'), findsWidgets);
      await tester.tap(find.text('Landlord (Maintenance)').last);
      await tester.pumpAndSettle();

      expect(provider.persona.id, 'landlord');
      expect(find.text('Landlord (Maintenance)'), findsOneWidget);
      expect(find.text('Property manager'), findsOneWidget);
      expect(find.text('VOICE: URGENT'), findsOneWidget);

      provider.triggerRinging();
      await tester.pump();
      expect(find.text('Landlord (Maintenance)'), findsOneWidget);
      expect(find.text('+1 (555) 876-5432'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('persona without a recording is labelled SCRIPT ONLY',
        (tester) async {
      await pumpApp(tester);
      provider.setPersona(_office);
      await tester.pumpAndSettle();
      expect(find.text('SCRIPT ONLY'), findsOneWidget);
    });

    testWidgets('ringtone menu and script language reach the provider',
        (tester) async {
      await pumpApp(tester);
      await tapText(tester, 'Hangouts');
      await tester.tap(find.text('Living Tune').last);
      await tester.pumpAndSettle();
      expect(provider.ringtoneId, 'living');

      await tapText(tester, 'Tagalog');
      expect(provider.languageCode, 'tl');
    });

    testWidgets('setup is restored after a full call', (tester) async {
      await pumpApp(tester);
      provider.setPersona(_landlord);
      await tester.pumpAndSettle();
      await tapText(tester, '1 min');
      await tester.enterText(find.byType(TextField).last, 'My own words');
      await tapText(tester, 'ARM STEALTH MODE');
      expect(find.text('01:00'), findsOneWidget);

      await tapText(tester, 'Preview incoming call screen');
      await tapText(tester, 'TAP TO ANSWER');
      final endCall = find.byIcon(Icons.call_end_rounded);
      await tester.ensureVisible(endCall);
      await tester.tap(endCall);
      await tester.pumpAndSettle();
      await tapText(tester, 'RETURN TO SETUP');

      expect(find.text('Set your exit'), findsOneWidget);
      expect(find.text('Landlord (Maintenance)'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField).last).controller!.text,
        'My own words',
      );
      await tapText(tester, 'ARM STEALTH MODE');
      expect(find.text('01:00'), findsOneWidget, reason: 'delay restored');
      await tapText(tester, 'CANCEL');
    });

    testWidgets('missing audio shows a warning; present audio does not',
        (tester) async {
      await pumpApp(tester, probe: (_) async => false);
      await tester.pumpAndSettle();
      expect(
        find.textContaining("Ringtone audio isn't installed"),
        findsOneWidget,
      );
      expect(find.textContaining('No voice recording'), findsOneWidget);
      // Still allowed to arm: the visual call works without audio.
      await tapText(tester, 'ARM STEALTH MODE');
      expect(provider.state, CallLifecycleState.countdown);
      await tapText(tester, 'CANCEL');
    });

    testWidgets('no warning when all audio is bundled', (tester) async {
      await pumpApp(tester);
      await tester.pumpAndSettle();
      expect(find.textContaining("Ringtone audio isn't"), findsNothing);
    });

    testWidgets('language button switches the UI and back to device',
        (tester) async {
      await pumpApp(tester);
      await tester.tap(find.byTooltip('Language'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tagalog').last);
      await tester.pumpAndSettle();
      expect(find.text('Ihanda ang pag-alis mo'), findsOneWidget);

      await tester.tap(find.byTooltip('Wika'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Wika ng device'));
      await tester.pumpAndSettle();
      expect(find.text('Set your exit'), findsOneWidget);
    });

    testWidgets('honest copy on setup and countdown', (tester) async {
      await pumpApp(tester);
      expect(find.textContaining('Preview only'), findsNothing);
      expect(find.textContaining('Simulated call only'), findsOneWidget);
      await tapText(tester, 'ARM STEALTH MODE');
      expect(find.text('Static countdown preview'), findsNothing);
      expect(
        find.text('Keep GhostBuster open. Leaving the app cancels the call.'),
        findsOneWidget,
      );
      await tapText(tester, 'CANCEL');
    });

    testWidgets('Script button hides and shows the script card',
        (tester) async {
      await pumpApp(tester);
      provider.triggerRinging();
      provider.answerCall();
      await tester.pump();
      expect(find.text('EMERGENCY SCRIPT'), findsOneWidget);

      final scriptButton = find.text('Script');
      await tester.ensureVisible(scriptButton);
      await tester.tap(scriptButton);
      await tester.pump();
      expect(find.text('EMERGENCY SCRIPT'), findsNothing);
      expect(find.text('Connected'), findsOneWidget);

      await tester.ensureVisible(scriptButton);
      await tester.tap(scriptButton);
      await tester.pump();
      expect(find.text('EMERGENCY SCRIPT'), findsOneWidget);
      provider.endCall();
      await tester.pump();
    });
  });
}
