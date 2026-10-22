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
  String get ringtoneTelephone => 'Telepono';

  @override
  String get ringtoneRinging => 'Klasikong Tunog';

  @override
  String get ringtoneClassic => 'Klasikong Telepono';

  @override
  String get ringtoneModern1 => 'Moderno 1';

  @override
  String get ringtoneModern2 => 'Moderno 2';

  @override
  String get setupDelayCustom => 'Pasadya';

  @override
  String get setupDelayCustomTitle => 'Pasadyang antala ng tawag';

  @override
  String get setupDelayCustomRange => 'Sa pagitan ng 10 segundo at 3 minuto.';

  @override
  String get setupDelaySet => 'ITAKDA';

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
      'Huwad na tawag lamang. Walang dina-dial at walang network ng telepono na ginagamit. Panatilihing bukas ang app hanggang tumunog ang tawag.';

  @override
  String get countdownStandingBy => 'Nakaantabay...';

  @override
  String get countdownSilent => 'PALIHIM NA PAGBILANG';

  @override
  String get countdownCancelButton => 'IKANSELA';

  @override
  String get incomingCallTitle => 'Papasok na tawag...';

  @override
  String get tapToAnswer => 'PINDUTIN UPANG SAGUTIN';

  @override
  String get callConnected => 'Konektado';

  @override
  String get activeCallScript => 'Script';

  @override
  String get callEndedTitle => 'Tapos na ang tawag';

  @override
  String get callEndedSubtitle => 'Natapos na ang iyong tawag.';

  @override
  String get callEndedReturnButton => 'BUMALIK SA SETUP';

  @override
  String get callEndedReady => 'Handa na para sa isa pang tawag.';

  @override
  String get errorInvalidDelay =>
      'Maling oras ng paghihintay. Dapat ay nasa pagitan ng 10 at 180 segundo.';

  @override
  String get errorSimulationActive =>
      'May aktibong tawag na. Maghintay o ikansela ang kasalukuyang tawag.';

  @override
  String get languageSystem => 'Wika ng device';

  @override
  String get setupChooseCaller => 'Pumili ng tatawag';

  @override
  String get personaRelationshipLandlord => 'Tagapamahala ng paupahan';

  @override
  String get personaRelationshipOffice => 'Suporta sa trabaho';

  @override
  String get personaVoiceUrgent => 'BOSES: MADALIAN';

  @override
  String get personaVoiceNone => 'SCRIPT LANG';

  @override
  String get setupAudioMissingRingtone =>
      'Walang naka-install na ringtone. Lalabas ang tawag pero hindi ito tutunog nang malakas.';

  @override
  String get setupAudioMissingVoice =>
      'Walang recording ng boses para sa tumatawag na ito. Ang script lang sa screen ang ipapakita.';

  @override
  String get countdownKeepOpen =>
      'Panatilihing bukas ang GhostBuster. Makakansela ang tawag kapag umalis ka sa app.';

  @override
  String get countdownRingNow => 'Ipakita na ang papasok na tawag';

  @override
  String get activeCallScriptTitle => 'EMERGENCY NA SCRIPT';

  @override
  String get voiceManagerTitle => 'Tagapamahala ng Voice Script';

  @override
  String get voiceManagerEntry => 'Mga voice script';

  @override
  String get voiceCreateRecording => 'Gumawa ng Recording';

  @override
  String get voiceEmptyTitle => 'Wala pang voice script';

  @override
  String get voiceEmptyBody =>
      'Mag-record ng sarili mong emergency voice script na tutugtog sa simulated na tawag.';

  @override
  String get voiceRecordingNow => 'Nagre-record...';

  @override
  String get voicePaused => 'Naka-pause';

  @override
  String get voicePause => 'I-pause';

  @override
  String get voiceResume => 'Ituloy';

  @override
  String get voiceStop => 'Itigil';

  @override
  String get voiceCancel => 'Kanselahin';

  @override
  String get voiceReviewTitle => 'Nakuha ang recording';

  @override
  String get voicePreview => 'I-preview';

  @override
  String get voiceStopPreview => 'Itigil ang preview';

  @override
  String get voiceRetake => 'Ulitin';

  @override
  String get voiceSave => 'I-save';

  @override
  String get voiceSaveTitle => 'I-save ang recording';

  @override
  String get voiceRename => 'Palitan ng pangalan';

  @override
  String get voiceRenameTitle => 'Palitan ng pangalan';

  @override
  String get voiceDelete => 'Burahin';

  @override
  String get voiceDeleteTitle => 'Burahin ang recording?';

  @override
  String get voiceDeleteBody =>
      'Permanenteng aalisin nito ang recording sa device na ito.';

  @override
  String get voiceNameLabel => 'Pangalan ng senaryo';

  @override
  String get voiceDescriptionLabel => 'Paglalarawan (opsyonal)';

  @override
  String get voiceUseForCall => 'Gamitin sa tawag';

  @override
  String get voiceSelectedForCall => 'Napili para sa tawag';

  @override
  String get voiceSavedSuccess => 'Na-save ang voice script.';

  @override
  String get voiceDeletedSuccess => 'Nabura ang recording.';

  @override
  String get voiceMicDenied =>
      'Kailangan ng pahintulot sa mikropono para makapag-record.';

  @override
  String get voiceMicDeniedForever =>
      'Naka-block ang mikropono. I-enable ito sa system settings.';

  @override
  String get voiceRecordFailed => 'Nabigo ang pag-record. Subukan ulit.';

  @override
  String get voiceSaveFailed => 'Hindi ma-save ang recording.';

  @override
  String get voiceEmptyRecording =>
      'Nawawala o walang laman ang recording file.';

  @override
  String get voiceRecordBlocked =>
      'Tapusin muna ang kasalukuyang tawag bago mag-record.';
}
