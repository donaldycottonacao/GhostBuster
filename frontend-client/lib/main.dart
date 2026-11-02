import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'providers/call_provider.dart';
import 'screens/screen_preview_host.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Restore the saved light/dark choice before the first frame so the app
  // doesn't flash the wrong theme on launch.
  final themeController =
      ThemeController(store: SharedPreferencesThemeModeStore());
  await themeController.load();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(GhostBusterApp(themeController: themeController));
}

/// Root widget for the GhostBuster application.
class GhostBusterApp extends StatelessWidget {
  final CallProvider? provider;

  /// Light/dark choice. Defaults to an in-memory controller that follows the
  /// device setting, so tests don't touch device storage.
  final ThemeController? themeController;

  const GhostBusterApp({super.key, this.provider, this.themeController});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => provider ?? CallProvider()),
        ChangeNotifierProvider(
          create: (_) => themeController ?? ThemeController(),
        ),
      ],
      child: Consumer2<CallProvider, ThemeController>(
        builder: (context, callProvider, themeController, _) {
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
            themeMode: themeController.mode,
            theme: GhostTheme.light(),
            darkTheme: GhostTheme.dark(),
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
