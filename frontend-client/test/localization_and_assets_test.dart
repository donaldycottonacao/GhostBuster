import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_client/l10n/app_localizations.dart';
import 'package:frontend_client/main.dart';
import 'package:frontend_client/providers/call_provider.dart';
import 'package:frontend_client/screens/active_call_ui.dart';
import 'package:frontend_client/screens/call_ended_screen.dart';
import 'package:frontend_client/screens/countdown_screen.dart';
import 'package:frontend_client/screens/incoming_call_ui.dart';
import 'package:frontend_client/screens/stealth_trigger.dart';
import 'package:frontend_client/services/audio_service.dart';

class _MockAudioService implements AudioServiceBase {
  @override
  Future<void> initialize() async {}
  @override
  Future<void> playRingtone({String? assetPath}) async {}
  @override
  Future<void> stopRingtone() async {}
  @override
  Future<void> playPeerAudio(String assetPath) async {}
  @override
  Future<void> playScenarioVoice(String assetPath) async {}
  @override
  Future<void> playVoiceFile(String filePath) async {}
  @override
  Future<void> playPreviewFile(String filePath) async {}
  @override
  Future<void> stopPreview() async {}
  @override
  Future<void> stopVoice() async {}
  @override
  Future<void> stopAll() async {}
  @override
  Future<void> dispose() async {}
  @override
  bool get isPlaying => false;
  @override
  bool get isRingtonePlaying => false;
  @override
  bool get isVoicePlaying => false;
  @override
  bool get isPreviewPlaying => false;
  @override
  String? get currentAsset => null;
}

Widget _buildLocalizedScreen(Widget child, Locale locale) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      FallbackMaterialLocalizationsDelegate(),
      FallbackCupertinoLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: child,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 7 — ARB Syntax, Parity & Completeness', () {
    test('all ARB files parse as valid JSON', () {
      final enFile = File('lib/l10n/app_en.arb');
      final tlFile = File('lib/l10n/app_tl.arb');
      final cebFile = File('lib/l10n/app_ceb.arb');

      expect(enFile.existsSync(), isTrue, reason: 'app_en.arb must exist');
      expect(tlFile.existsSync(), isTrue, reason: 'app_tl.arb must exist');
      expect(cebFile.existsSync(), isTrue, reason: 'app_ceb.arb must exist');

      final enMap =
          jsonDecode(enFile.readAsStringSync()) as Map<String, dynamic>;
      final tlMap =
          jsonDecode(tlFile.readAsStringSync()) as Map<String, dynamic>;
      final cebMap =
          jsonDecode(cebFile.readAsStringSync()) as Map<String, dynamic>;

      expect(enMap['@@locale'], 'en');
      expect(tlMap['@@locale'], 'tl');
      expect(cebMap['@@locale'], 'ceb');
    });

    test('translation keys match 100% across English, Tagalog, and Cebuano',
        () {
      final enMap = jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync())
          as Map<String, dynamic>;
      final tlMap = jsonDecode(File('lib/l10n/app_tl.arb').readAsStringSync())
          as Map<String, dynamic>;
      final cebMap = jsonDecode(File('lib/l10n/app_ceb.arb').readAsStringSync())
          as Map<String, dynamic>;

      final enKeys = enMap.keys.where((k) => !k.startsWith('@')).toSet();
      final tlKeys = tlMap.keys.where((k) => !k.startsWith('@')).toSet();
      final cebKeys = cebMap.keys.where((k) => !k.startsWith('@')).toSet();

      expect(enKeys.length, greaterThanOrEqualTo(70));
      expect(tlKeys, equals(enKeys),
          reason: 'Tagalog keys must match English keys exactly');
      expect(cebKeys, equals(enKeys),
          reason: 'Cebuano keys must match English keys exactly');
    });

    test('placeholders are consistent across locales', () {
      final enMap = jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync())
          as Map<String, dynamic>;
      final tlMap = jsonDecode(File('lib/l10n/app_tl.arb').readAsStringSync())
          as Map<String, dynamic>;
      final cebMap = jsonDecode(File('lib/l10n/app_ceb.arb').readAsStringSync())
          as Map<String, dynamic>;

      final placeholderKeys = [
        'incomingCallTriggersIn',
        'armEscapeCall',
        'cancelCountdown'
      ];
      for (final key in placeholderKeys) {
        expect(enMap[key], contains('{seconds}'),
            reason: 'English $key must contain {seconds}');
        expect(tlMap[key], contains('{seconds}'),
            reason: 'Tagalog $key must contain {seconds}');
        expect(cebMap[key], contains('{seconds}'),
            reason: 'Cebuano $key must contain {seconds}');
      }
    });
  });

  group('Phase 7 — Locale Selection, Resolution & Fallback', () {
    test('supportedLocales contains ceb, en, and tl', () {
      final codes =
          AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet();
      expect(codes, containsAll(['ceb', 'en', 'tl']));
    });

    test('CallProvider handles valid and unsupported locales safely', () {
      final provider = CallProvider(audioService: _MockAudioService());
      expect(provider.currentLocale.languageCode, 'en');

      provider.setLocale(const Locale('tl'));
      expect(provider.currentLocale.languageCode, 'tl');

      provider.setLocale(const Locale('ceb'));
      expect(provider.currentLocale.languageCode, 'ceb');

      // Unsupported locale safely falls back to English
      provider.setLocale(const Locale('fr'));
      expect(provider.currentLocale.languageCode, 'en');

      provider.setLocale(const Locale('ja'));
      expect(provider.currentLocale.languageCode, 'en');

      provider.dispose();
    });

    testWidgets('unsupported device locale resolves to English fallback',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('fr', 'FR'),
          supportedLocales: AppLocalizations.supportedLocales,
          localeResolutionCallback: (deviceLocale, supportedLocales) {
            if (deviceLocale != null) {
              for (final supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == deviceLocale.languageCode) {
                  return supportedLocale;
                }
              }
            }
            return const Locale('en');
          },
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Text(l10n.setupTitle);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Set your exit'), findsOneWidget);
    });

    testWidgets('GhostBusterApp starts cleanly with default English locale',
        (tester) async {
      final provider = CallProvider(audioService: _MockAudioService());
      await tester.pumpWidget(GhostBusterApp(provider: provider));
      await tester.pumpAndSettle();

      // Setup screen marker (the "Set your exit" heading was removed from the UI).
      expect(find.text('ARM STEALTH MODE'), findsOneWidget);

      provider.dispose();
    });
  });

  group('Phase 7 — Multi-Locale Screen Rendering', () {
    for (final locale in [
      const Locale('en'),
      const Locale('tl'),
      const Locale('ceb')
    ]) {
      final code = locale.languageCode;

      testWidgets('StealthTriggerScreen renders in $code without layout errors',
          (tester) async {
        await tester.pumpWidget(
            _buildLocalizedScreen(const StealthTriggerScreen(), locale));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(StealthTriggerScreen), findsOneWidget);
      });

      testWidgets('CountdownScreen renders in $code without layout errors',
          (tester) async {
        await tester.pumpWidget(
          _buildLocalizedScreen(
            CountdownScreen(
              delaySeconds: 30,
              onCancel: () {},
              onPreviewIncoming: () {},
            ),
            locale,
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(CountdownScreen), findsOneWidget);
      });

      testWidgets('IncomingCallScreen renders in $code without layout errors',
          (tester) async {
        await tester.pumpWidget(
          _buildLocalizedScreen(
            IncomingCallScreen(
              onAnswer: () {},
              onDecline: () {},
            ),
            locale,
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(IncomingCallScreen), findsOneWidget);
      });

      testWidgets('ActiveCallScreen renders in $code without layout errors',
          (tester) async {
        await tester.pumpWidget(
          _buildLocalizedScreen(
            ActiveCallScreen(
              script: 'Test dialogue script',
              onEndCall: () {},
            ),
            locale,
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(ActiveCallScreen), findsOneWidget);
      });

      testWidgets('CallEndedScreen renders in $code without layout errors',
          (tester) async {
        await tester.pumpWidget(
          _buildLocalizedScreen(
            CallEndedScreen(onReturnToSetup: () {}),
            locale,
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(CallEndedScreen), findsOneWidget);
      });
    }

    testWidgets(
        'StealthTriggerScreen renders cleanly on compact 320x568 screen in Tagalog and Cebuano',
        (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      for (final locale in [const Locale('tl'), const Locale('ceb')]) {
        await tester.pumpWidget(
            _buildLocalizedScreen(const StealthTriggerScreen(), locale));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(StealthTriggerScreen), findsOneWidget);
      }
    });
  });

  group('Phase 7 — Asset Path Validation & Safe Audio Fallbacks', () {
    test('asset directories exist and contain documentation README files', () {
      final audioDir = Directory('assets/audio');
      final fontsDir = Directory('assets/fonts');

      expect(audioDir.existsSync(), isTrue, reason: 'assets/audio must exist');
      expect(fontsDir.existsSync(), isTrue, reason: 'assets/fonts must exist');

      final audioReadme = File('assets/audio/README.md');
      final fontsReadme = File('assets/fonts/README.md');
      expect(audioReadme.existsSync(), isTrue,
          reason: 'assets/audio/README.md must exist');
      expect(fontsReadme.existsSync(), isTrue,
          reason: 'assets/fonts/README.md must exist');
    });

    test(
        'AudioService handles missing binary audio assets safely without throwing',
        () async {
      final audioService = AudioService.custom(enableHardware: false);
      await audioService.initialize();

      // Attempting to play an unbundled/missing audio asset succeeds safely via fallback simulation
      await expectLater(
        audioService.playRingtone(
            assetPath: 'assets/audio/nonexistent_ringtone.mp3'),
        completes,
      );
      expect(audioService.isRingtonePlaying, isTrue);

      await expectLater(
        audioService.playPeerAudio('assets/audio/nonexistent_voice.mp3'),
        completes,
      );
      expect(audioService.isVoicePlaying, isTrue);

      await audioService.stopAll();
      expect(audioService.isPlaying, isFalse);
      await audioService.dispose();
    });

    test(
        'CallProvider rejects invalid delay boundaries and unknown scenarios safely',
        () {
      final provider = CallProvider(audioService: _MockAudioService());

      expect(provider.validateDelay(5), isFalse);
      expect(provider.validateDelay(10), isTrue);
      expect(provider.validateDelay(30), isTrue);
      expect(provider.validateDelay(180), isTrue);
      expect(provider.validateDelay(300), isFalse);

      // Attempting to set an invalid delay does not change the configured value
      final originalDelay = provider.delaySeconds;
      provider.setDelaySeconds(-10);
      expect(provider.delaySeconds, originalDelay);

      // Unsupported script language is rejected safely
      provider.setScriptLanguage('unsupported_lang');
      expect(provider.languageCode, 'en');

      provider.dispose();
    });
  });
}
