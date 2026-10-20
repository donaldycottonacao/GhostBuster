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

  @override
  String get setupTagline => 'DISKRETONG PAG-ALIS. MAS MAGANDANG ARAW.';

  @override
  String get setupFieldMode => 'MODE SA LUGAR';

  @override
  String get setupTitle => 'Ihanda ang pag-alis mo';

  @override
  String get setupSubtitle => 'Kapani-paniwalang tawag, sa tamang oras.';

  @override
  String get setupRingDelay => 'ANTALA BAGO TUMAWAG';

  @override
  String get setupRingDelayHelp => 'Itakda kung kailan papasok ang tawag.';

  @override
  String get setupDelay10Seconds => '10 seg';

  @override
  String get setupDelay30Seconds => '30 seg';

  @override
  String get setupDelay1Minute => '1 min';

  @override
  String get setupDelay3Minutes => '3 min';

  @override
  String get setupIncomingCall => 'PAPASOK NA TAWAG';

  @override
  String get setupPreview => 'SILIPIN';

  @override
  String get setupEmergencyContact => 'Pang-emergency na contact';

  @override
  String get setupVoicePanicked => 'BOSES: TARANTA';

  @override
  String get setupRingtone => 'Tono ng Tawag';

  @override
  String get setupRingtoneContainment => 'Alarmang Pang-alerto';

  @override
  String get setupRingtoneSoft => 'Mahinang Tunog';

  @override
  String get setupRingtoneClassic => 'Klasikong Ringtone';

  @override
  String get setupScriptLanguage => 'WIKA NG SCRIPT';

  @override
  String get setupSituationEvent => 'SITWASYON / PANGYAYARI';

  @override
  String get setupSituationHint => 'hal., Nasa party ako at handa nang umuwi';

  @override
  String get setupVoiceScript => 'SCRIPT NG SASABIHIN';

  @override
  String get setupGenerateWithAI => 'Gumawa gamit ang AI';

  @override
  String get setupWriteMyOwn => 'Ako ang susulat';

  @override
  String get setupScriptHint => 'Isulat ang script mo...';

  @override
  String get setupScriptExample =>
      'Uy, puwede mo ba akong tawagan? Kailangan ko ng dahilan para makalabas.';

  @override
  String get setupReviewNote => 'Suriin at i-edit bago gamitin.';

  @override
  String get setupArmButton => 'IHANDA ANG PALIHIM NA MODE';

  @override
  String get setupArmedStatus => 'NAIHANDA NA ANG PALIHIM NA MODE';

  @override
  String get setupDisclaimer =>
      'Preview lang. Walang tawag na itinatakda mula sa screen na ito.';
}
