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
            locale: callProvider.currentLocale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
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
              scaffoldBackgroundColor: const Color(0xFF0F172A),
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF3B82F6),
                secondary: Color(0xFF10B981),
                surface: Color(0xFF1E293B),
                error: Color(0xFFEF4444),
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF0F172A),
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
