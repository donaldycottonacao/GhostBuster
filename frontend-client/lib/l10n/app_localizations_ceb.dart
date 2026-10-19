// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Cebuano (`ceb`).
class AppLocalizationsCeb extends AppLocalizations {
  AppLocalizationsCeb([String locale = 'ceb']) : super(locale);

  @override
  String get appTitle => 'GhostBuster - Tago nga Pag-ikyas';

  @override
  String get appSubtitle => 'Tighimo og Pekeng Tawag';

  @override
  String get escapeSequenceArmed => 'Andam na ang Pag-ikyas';

  @override
  String incomingCallTriggersIn(int seconds) {
    return 'Motingog ang tawag sulod sa $seconds ka segundo...';
  }

  @override
  String get configureTriggerDesc =>
      'I-set ang oras sa paghulat ug pilia ang pekeng persona.';

  @override
  String get callerPersona => 'PERSONA SA MANANAWAG';

  @override
  String get triggerDelay => 'ORAS SA PAGHULAT';

  @override
  String armEscapeCall(int seconds) {
    return 'ANDAMA ANG TAWAG (${seconds}s HULAT)';
  }

  @override
  String cancelCountdown(int seconds) {
    return 'IKANSELA ANG ORAS (${seconds}s)';
  }

  @override
  String get simulationDisclaimer =>
      'Pangsundog lamang. Walay aktwal nga linya sa telepono o network nga gigamit.';

  @override
  String get mobile => 'mobile';

  @override
  String get remindMe => 'Pahinumdomi Ko';

  @override
  String get message => 'Mensahe';

  @override
  String get slideToAnswer => 'i-slide aron tubagon';

  @override
  String get decline => 'Balibari';

  @override
  String get mute => 'i-mute';

  @override
  String get unmute => 'i-unmute';

  @override
  String get keypad => 'keypad';

  @override
  String get hideKeypad => 'Itago ang Keypad';

  @override
  String get speaker => 'speaker';

  @override
  String get addCall => 'dugang tawag';

  @override
  String get facetime => 'FaceTime';

  @override
  String get contacts => 'mga kontak';

  @override
  String get endCall => 'Undanga ang Tawag';

  @override
  String get language => 'Pinulongan';

  @override
  String get selectLanguage => 'Pilia ang Pinulongan';

  @override
  String get english => 'Iningles';

  @override
  String get tagalog => 'Tagalog';

  @override
  String get cebuano => 'Cebuano / Bisaya';

  @override
  String get errorAudioUnavailable =>
      'Dili magamit ang audio track. Luwas nga magpadayon nga walay tingog.';

  @override
  String get personaMom => 'Mama';

  @override
  String get personaLandlord => 'Tag-iya sa Balay (Maintenance)';

  @override
  String get personaOffice => 'Opisina / Dispatch';
}
