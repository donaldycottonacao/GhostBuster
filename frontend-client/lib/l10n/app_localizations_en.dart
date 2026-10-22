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
  String get ringtoneTelephone => 'Telephone';

  @override
  String get ringtoneRinging => 'Classic Ring';

  @override
  String get ringtoneClassic => 'Classic Phone';

  @override
  String get ringtoneModern1 => 'Modern 1';

  @override
  String get ringtoneModern2 => 'Modern 2';

  @override
  String get setupDelayCustom => 'Custom';

  @override
  String get setupDelayCustomTitle => 'Custom ring delay';

  @override
  String get setupDelayCustomRange => 'Between 10 seconds and 3 minutes.';

  @override
  String get setupDelaySet => 'SET';

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
      'Simulated call only. Nothing is dialed and no phone network is used. Keep the app open until the call rings.';

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

  @override
  String get languageSystem => 'Device language';

  @override
  String get setupChooseCaller => 'Choose caller';

  @override
  String get personaRelationshipLandlord => 'Property manager';

  @override
  String get personaRelationshipOffice => 'Workplace support';

  @override
  String get personaVoiceUrgent => 'VOICE: URGENT';

  @override
  String get personaVoiceNone => 'SCRIPT ONLY';

  @override
  String get setupAudioMissingRingtone =>
      'Ringtone audio isn\'t installed. The call screen will appear, but it won\'t ring out loud.';

  @override
  String get setupAudioMissingVoice =>
      'No voice recording for this caller. Only the on-screen script will be shown.';

  @override
  String get countdownKeepOpen =>
      'Keep GhostBuster open. Leaving the app cancels the call.';

  @override
  String get countdownRingNow => 'Preview incoming call screen';

  @override
  String get activeCallScriptTitle => 'EMERGENCY SCRIPT';

  @override
  String get voiceManagerTitle => 'Voice Script Manager';

  @override
  String get voiceManagerEntry => 'Voice scripts';

  @override
  String get voiceCreateRecording => 'Create Recording';

  @override
  String get voiceEmptyTitle => 'No voice scripts yet';

  @override
  String get voiceEmptyBody =>
      'Record your own emergency voice script to play during a simulated call.';

  @override
  String get voiceRecordingNow => 'Recording...';

  @override
  String get voicePaused => 'Paused';

  @override
  String get voicePause => 'Pause';

  @override
  String get voiceResume => 'Resume';

  @override
  String get voiceStop => 'Stop';

  @override
  String get voiceCancel => 'Cancel';

  @override
  String get voiceReviewTitle => 'Recording captured';

  @override
  String get voicePreview => 'Preview';

  @override
  String get voiceStopPreview => 'Stop preview';

  @override
  String get voiceRetake => 'Retake';

  @override
  String get voiceSave => 'Save';

  @override
  String get voiceSaveTitle => 'Save recording';

  @override
  String get voiceRename => 'Rename';

  @override
  String get voiceRenameTitle => 'Rename';

  @override
  String get voiceDelete => 'Delete';

  @override
  String get voiceDeleteTitle => 'Delete recording?';

  @override
  String get voiceDeleteBody =>
      'This permanently removes the recording from this device.';

  @override
  String get voiceNameLabel => 'Scenario name';

  @override
  String get voiceDescriptionLabel => 'Description (optional)';

  @override
  String get voiceUseForCall => 'Use for call';

  @override
  String get voiceSelectedForCall => 'Selected for call';

  @override
  String get voiceSavedSuccess => 'Voice script saved.';

  @override
  String get voiceDeletedSuccess => 'Recording deleted.';

  @override
  String get voiceMicDenied => 'Microphone permission is required to record.';

  @override
  String get voiceMicDeniedForever =>
      'Microphone access is blocked. Enable it in system settings.';

  @override
  String get voiceRecordFailed => 'Recording failed. Please try again.';

  @override
  String get voiceSaveFailed => 'Could not save the recording.';

  @override
  String get voiceEmptyRecording => 'The recording file is missing or empty.';

  @override
  String get voiceRecordBlocked => 'Finish the current call before recording.';
}
