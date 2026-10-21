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

  @override
  String get setupTagline => 'DISKRETONG PAGBIYA. MAS NINDOT NGA ADLAW.';

  @override
  String get setupFieldMode => 'MODE SA DAPIT';

  @override
  String get setupTitle => 'Andama imong paggawas';

  @override
  String get setupSubtitle => 'Matuohon nga tawag, sa saktong oras.';

  @override
  String get setupRingDelay => 'DELAY SA TAWAG';

  @override
  String get setupRingDelayHelp => 'Itakda kon kanus-a mosulod ang tawag.';

  @override
  String get setupDelay10Seconds => '10 seg';

  @override
  String get setupDelay30Seconds => '30 seg';

  @override
  String get setupDelay1Minute => '1 min';

  @override
  String get setupDelay3Minutes => '3 min';

  @override
  String get setupIncomingCall => 'MOSULOD NGA TAWAG';

  @override
  String get setupPreview => 'TAN-AWA';

  @override
  String get setupEmergencyContact => 'Kontak sa emerhensya';

  @override
  String get setupVoicePanicked => 'TINGOG: NAKALIBANG';

  @override
  String get setupRingtone => 'Tingog sa Tawag';

  @override
  String get setupRingtoneContainment => 'Alarmang Pang-alerto';

  @override
  String get setupRingtoneSoft => 'Hinay nga Chime';

  @override
  String get setupRingtoneClassic => 'Klasikong Ringtone';

  @override
  String get setupScriptLanguage => 'PINULONGAN SA SCRIPT';

  @override
  String get setupSituationEvent => 'SITWASYON / HITABO';

  @override
  String get setupSituationHint =>
      'pananglitan, Naa ko sa party ug andam nang mouli';

  @override
  String get setupVoiceScript => 'SCRIPT SA TINGOG';

  @override
  String get setupGenerateWithAI => 'Himoa gamit ang AI';

  @override
  String get setupWriteMyOwn => 'Ako ang mosulat';

  @override
  String get setupScriptHint => 'Isulat ang imong script...';

  @override
  String get setupScriptExample =>
      'Uy, matawagan ko nimo? Kinahanglan kog rason para makagawas.';

  @override
  String get setupReviewNote => 'Susiha ug usba una gamiton.';

  @override
  String get setupArmButton => 'ANDAMA ANG TAGO NGA MODE';

  @override
  String get setupArmedStatus => 'ANDAM NA ANG TAGO NGA MODE';

  @override
  String get setupDisclaimer =>
      'Preview ra. Walay tawag nga gitakda niini nga screen.';

  @override
  String get countdownStandingBy => 'Naghulat...';

  @override
  String get countdownSilent => 'TAGO NGA PAG-IHAP';

  @override
  String get countdownCancelButton => 'IKANSELA';

  @override
  String get incomingCallTitle => 'Mosulod nga tawag...';

  @override
  String get tapToAnswer => 'PINDOTA ARON TUBAGON';

  @override
  String get callConnected => 'Konektado';

  @override
  String get activeCallScript => 'Script';

  @override
  String get callEndedTitle => 'Nahuman ang tawag';

  @override
  String get callEndedSubtitle => 'Nahuman na ang imong tawag.';

  @override
  String get callEndedReturnButton => 'BALIK SA SETUP';

  @override
  String get callEndedReady => 'Andam na para sa laing tawag.';

  @override
  String get errorInvalidDelay =>
      'Sayop nga delay. Kinahanglan anaa sa taliwala sa 10 ug 180 ka segundo.';

  @override
  String get errorSimulationActive =>
      'Naay aktibong tawag. Palihug hulat o ikansela ang kasamtangang tawag.';
}
