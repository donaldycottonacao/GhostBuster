import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'providers/call_provider.dart';
import 'screens/screen_preview_host.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const GhostBusterApp());
}

/// Root widget for the GhostBuster application.
class GhostBusterApp extends StatelessWidget {
  final CallProvider? provider;

  const GhostBusterApp({super.key, this.provider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => provider ?? CallProvider(),
      child: Consumer<CallProvider>(
        builder: (context, callProvider, _) {
          return MaterialApp(
            title: 'GhostBuster',
            debugShowCheckedModeBanner: false,
            // null follows the device language (Tagalog/Cebuano/English, else
            // English); the setup screen's language button can override it.
            locale: callProvider.localeOverride,
            supportedLocales: AppLocalizations.supportedLocales,
            localeResolutionCallback: (deviceLocale, supportedLocales) {
              if (deviceLocale != null) {
                for (final supportedLocale in supportedLocales) {
                  if (supportedLocale.languageCode ==
                      deviceLocale.languageCode) {
                    return supportedLocale;
                  }
                }
              }
              return const Locale('en');
            },
            localizationsDelegates: const [
              AppLocalizations.delegate,
              FallbackMaterialLocalizationsDelegate(),
              FallbackCupertinoLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            themeMode: ThemeMode.dark,
            theme: ThemeData(
              brightness: Brightness.light,
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF2563EB),
                brightness: Brightness.light,
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFF0A0D0C),
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF3B82F6),
                secondary: Color(0xFF10B981),
                surface: Color(0xFF191D20),
                error: Color(0xFFEF4444),
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF0A0D0C),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
            home: const ScreenPreviewHost(),
          );
        },
      ),
    );
  }
}

/// Fallback material localizations delegate for locales (such as Cebuano)
/// not natively bundled in Flutter's `GlobalMaterialLocalizations`.
class FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ceb';

  @override
  Future<MaterialLocalizations> load(Locale locale) async =>
      const DefaultMaterialLocalizations();

  @override
  bool shouldReload(FallbackMaterialLocalizationsDelegate old) => false;
}

/// Fallback cupertino localizations delegate for locales (such as Cebuano)
/// not natively bundled in Flutter's `GlobalCupertinoLocalizations`.
class FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ceb';

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      DefaultCupertinoLocalizations.load(locale);

  @override
  bool shouldReload(FallbackCupertinoLocalizationsDelegate old) => false;
}
