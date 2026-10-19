// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tagalog (`tl`).
class AppLocalizationsTl extends AppLocalizations {
  AppLocalizationsTl([String locale = 'tl']) : super(locale);

  @override
  String get appTitle => 'GhostBuster - Palihim na Pagtakas';

  @override
  String get appSubtitle => 'Tagabuo ng Huwad na Tawag';

  @override
  String get escapeSequenceArmed => 'Nakahanda na ang Pagtakas';

  @override
  String incomingCallTriggersIn(int seconds) {
    return 'Tutunog ang tawag sa loob ng $seconds segundo...';
  }

  @override
  String get configureTriggerDesc =>
      'Itakda ang oras ng paghihintay at piliin ang huwad na personahe.';

  @override
  String get callerPersona => 'PERSONAHE NG TUMATAWAG';

  @override
  String get triggerDelay => 'ORAS NG PAGHIHINTAY';

  @override
  String armEscapeCall(int seconds) {
    return 'IHANDA ANG TAWAG (${seconds}s PAGHINTAY)';
  }

  @override
  String cancelCountdown(int seconds) {
    return 'IKANSELA ANG ORAS (${seconds}s)';
  }

  @override
  String get simulationDisclaimer =>
      'Panggagaya lamang. Walang aktwal na linya ng telepono o network ang ginagamit.';

  @override
  String get mobile => 'mobile';

  @override
  String get remindMe => 'Ipaalala sa Akin';

  @override
  String get message => 'Mensahe';

  @override
  String get slideToAnswer => 'i-slide upang sagutin';

  @override
  String get decline => 'Tanggihan';

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
  String get addCall => 'dagdag tawag';

  @override
  String get facetime => 'FaceTime';

  @override
  String get contacts => 'mga kontak';

  @override
  String get endCall => 'Tapusin ang Tawag';

  @override
  String get language => 'Wika';

  @override
  String get selectLanguage => 'Pumili ng Wika';

  @override
  String get english => 'Ingles';

  @override
  String get tagalog => 'Tagalog';

  @override
  String get cebuano => 'Cebuano / Bisaya';

  @override
  String get errorAudioUnavailable =>
      'Hindi magagamit ang audio track. Ligtas na ipinagpapatuloy nang walang tunog.';

  @override
  String get personaMom => 'Nanay';

  @override
  String get personaLandlord => 'May-ari ng Bahay (Maintenance)';

  @override
  String get personaOffice => 'Opisina / Dispatch';
}
