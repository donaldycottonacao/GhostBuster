// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'GhostBuster - Stealth Escape';

  @override
  String get appSubtitle => 'Simulated Call Generator';

  @override
  String get escapeSequenceArmed => 'Escape Sequence Armed';

  @override
  String incomingCallTriggersIn(int seconds) {
    return 'Incoming call triggers in $seconds seconds...';
  }

  @override
  String get configureTriggerDesc =>
      'Configure trigger delay and select fake caller persona.';

  @override
  String get callerPersona => 'CALLER PERSONA';

  @override
  String get triggerDelay => 'TRIGGER DELAY';

  @override
  String armEscapeCall(int seconds) {
    return 'ARM ESCAPE CALL (${seconds}s DELAY)';
  }

  @override
  String cancelCountdown(int seconds) {
    return 'CANCEL COUNTDOWN (${seconds}s)';
  }

  @override
  String get simulationDisclaimer =>
      'Simulation only. No actual phone lines or cellular networks are accessed.';

  @override
  String get mobile => 'mobile';

  @override
  String get remindMe => 'Remind Me';

  @override
  String get message => 'Message';

  @override
  String get slideToAnswer => 'slide to answer';

  @override
  String get decline => 'Decline';

  @override
  String get mute => 'Mute';

  @override
  String get unmute => 'Unmute';

  @override
  String get keypad => 'Keypad';

  @override
  String get hideKeypad => 'Hide Keypad';

  @override
  String get speaker => 'Speaker';

  @override
  String get addCall => 'add call';

  @override
  String get facetime => 'FaceTime';

  @override
  String get contacts => 'contacts';

  @override
  String get endCall => 'End Call';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get tagalog => 'Tagalog';

  @override
  String get cebuano => 'Cebuano / Bisaya';

  @override
  String get errorAudioUnavailable =>
      'Simulated audio track is unavailable. Playing silent safe fallback.';

  @override
  String get personaMom => 'Mom';

  @override
  String get personaLandlord => 'Landlord (Maintenance)';

  @override
  String get personaOffice => 'Office Dispatch';

  @override
  String get setupTagline => 'DISCREET EXITS. BRIGHTER DAYS.';

  @override
  String get setupFieldMode => 'FIELD MODE';

  @override
  String get setupTitle => 'Set your exit';

  @override
  String get setupSubtitle => 'A convincing call, right on cue.';

  @override
  String get setupRingDelay => 'RING DELAY';

  @override
  String get setupRingDelayHelp => 'Set how long until the call comes in.';

  @override
  String get setupDelay10Seconds => '10 sec';

  @override
  String get setupDelay30Seconds => '30 sec';

  @override
  String get setupDelay1Minute => '1 min';

  @override
  String get setupDelay3Minutes => '3 min';

  @override
  String get setupIncomingCall => 'INCOMING CALL';

  @override
  String get setupPreview => 'PREVIEW';

  @override
  String get setupEmergencyContact => 'Emergency contact';

  @override
  String get setupVoicePanicked => 'VOICE: PANICKED';

  @override
  String get setupRingtone => 'Ringtone';

  @override
  String get setupRingtoneContainment => 'Containment Alarm';

  @override
  String get setupRingtoneSoft => 'Soft Chime';

  @override
  String get setupRingtoneClassic => 'Classic Ringtone';

  @override
  String get setupScriptLanguage => 'SCRIPT LANGUAGE';

  @override
  String get setupSituationEvent => 'SITUATION / EVENT';

  @override
  String get setupSituationHint => 'e.g., At a party and ready to head home';

  @override
  String get setupVoiceScript => 'VOICE SCRIPT';

  @override
  String get setupGenerateWithAI => 'Generate with AI';

  @override
  String get setupWriteMyOwn => 'Write my own';

  @override
  String get setupScriptHint => 'Write your script...';

  @override
  String get setupScriptExample =>
      'Hey, can you call me? I need a reason to step out.';

  @override
  String get setupReviewNote => 'Review and edit before use.';

  @override
  String get setupArmButton => 'ARM STEALTH MODE';

  @override
  String get setupArmedStatus => 'STEALTH MODE ARMED';

  @override
  String get setupDisclaimer =>
      'Preview only. No call is scheduled from this screen.';

  @override
  String get countdownStandingBy => 'Standing by...';

  @override
  String get countdownSilent => 'SILENT COUNTDOWN';

  @override
  String get countdownCancelButton => 'CANCEL';

  @override
  String get incomingCallTitle => 'Incoming call...';

  @override
  String get tapToAnswer => 'TAP TO ANSWER';

  @override
  String get callConnected => 'Connected';

  @override
  String get activeCallScript => 'Script';

  @override
  String get callEndedTitle => 'Call ended';

  @override
  String get callEndedSubtitle => 'Your call has ended.';

  @override
  String get callEndedReturnButton => 'RETURN TO SETUP';

  @override
  String get callEndedReady => 'Ready for another call.';

  @override
  String get errorInvalidDelay =>
      'Invalid delay. Delay must be between 10 and 180 seconds.';

  @override
  String get errorSimulationActive =>
      'A simulation is already active. Please wait or cancel the current call.';
}
