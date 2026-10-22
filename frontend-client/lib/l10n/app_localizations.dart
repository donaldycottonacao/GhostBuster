import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ceb.dart';
import 'app_localizations_en.dart';
import 'app_localizations_tl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ceb'),
    Locale('en'),
    Locale('tl')
  ];

  /// Main application bar title
  ///
  /// In en, this message translates to:
  /// **'GhostBuster - Stealth Escape'**
  String get appTitle;

  /// Header subtitle describing the application
  ///
  /// In en, this message translates to:
  /// **'Simulated Call Generator'**
  String get appSubtitle;

  /// Status text when countdown is running
  ///
  /// In en, this message translates to:
  /// **'Escape Sequence Armed'**
  String get escapeSequenceArmed;

  /// Countdown banner message
  ///
  /// In en, this message translates to:
  /// **'Incoming call triggers in {seconds} seconds...'**
  String incomingCallTriggersIn(int seconds);

  /// Configuration instructions text
  ///
  /// In en, this message translates to:
  /// **'Configure trigger delay and select fake caller persona.'**
  String get configureTriggerDesc;

  /// Header for caller persona selection
  ///
  /// In en, this message translates to:
  /// **'CALLER PERSONA'**
  String get callerPersona;

  /// Header for trigger delay selection
  ///
  /// In en, this message translates to:
  /// **'TRIGGER DELAY'**
  String get triggerDelay;

  /// Trigger button label
  ///
  /// In en, this message translates to:
  /// **'ARM ESCAPE CALL ({seconds}s DELAY)'**
  String armEscapeCall(int seconds);

  /// Cancel countdown button label
  ///
  /// In en, this message translates to:
  /// **'CANCEL COUNTDOWN ({seconds}s)'**
  String cancelCountdown(int seconds);

  /// Legal and ethical disclaimer at screen bottom
  ///
  /// In en, this message translates to:
  /// **'Simulation only. No actual phone lines or cellular networks are accessed.'**
  String get simulationDisclaimer;

  /// Sublabel below incoming caller number
  ///
  /// In en, this message translates to:
  /// **'mobile'**
  String get mobile;

  /// Incoming call remind me button
  ///
  /// In en, this message translates to:
  /// **'Remind Me'**
  String get remindMe;

  /// Incoming call message button
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// Gesture slider prompt text
  ///
  /// In en, this message translates to:
  /// **'slide to answer'**
  String get slideToAnswer;

  /// Call decline button label
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// Microphone mute button label
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get mute;

  /// Microphone unmute button label
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get unmute;

  /// Dial pad toggle button label
  ///
  /// In en, this message translates to:
  /// **'Keypad'**
  String get keypad;

  /// Dismiss dial pad modal label
  ///
  /// In en, this message translates to:
  /// **'Hide Keypad'**
  String get hideKeypad;

  /// Speakerphone toggle button label
  ///
  /// In en, this message translates to:
  /// **'Speaker'**
  String get speaker;

  /// Add call placeholder button label
  ///
  /// In en, this message translates to:
  /// **'add call'**
  String get addCall;

  /// Video call placeholder button label
  ///
  /// In en, this message translates to:
  /// **'FaceTime'**
  String get facetime;

  /// Contacts placeholder button label
  ///
  /// In en, this message translates to:
  /// **'contacts'**
  String get contacts;

  /// End call button tooltip
  ///
  /// In en, this message translates to:
  /// **'End Call'**
  String get endCall;

  /// Language selection label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Language dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Tagalog language name
  ///
  /// In en, this message translates to:
  /// **'Tagalog'**
  String get tagalog;

  /// Cebuano language name
  ///
  /// In en, this message translates to:
  /// **'Cebuano / Bisaya'**
  String get cebuano;

  /// Safe audio fallback error message
  ///
  /// In en, this message translates to:
  /// **'Simulated audio track is unavailable. Playing silent safe fallback.'**
  String get errorAudioUnavailable;

  /// Default Mom persona name
  ///
  /// In en, this message translates to:
  /// **'Mom'**
  String get personaMom;

  /// Default Landlord persona name
  ///
  /// In en, this message translates to:
  /// **'Landlord (Maintenance)'**
  String get personaLandlord;

  /// Default Office persona name
  ///
  /// In en, this message translates to:
  /// **'Office Dispatch'**
  String get personaOffice;

  /// Setup screen brand tagline
  ///
  /// In en, this message translates to:
  /// **'DISCREET EXITS. BRIGHTER DAYS.'**
  String get setupTagline;

  /// Setup screen mode badge
  ///
  /// In en, this message translates to:
  /// **'FIELD MODE'**
  String get setupFieldMode;

  /// Setup screen heading
  ///
  /// In en, this message translates to:
  /// **'Set your exit'**
  String get setupTitle;

  /// Setup screen introduction
  ///
  /// In en, this message translates to:
  /// **'A convincing call, right on cue.'**
  String get setupSubtitle;

  /// Ring delay section heading
  ///
  /// In en, this message translates to:
  /// **'RING DELAY'**
  String get setupRingDelay;

  /// Ring delay helper text
  ///
  /// In en, this message translates to:
  /// **'Set how long until the call comes in.'**
  String get setupRingDelayHelp;

  /// Ten-second delay choice
  ///
  /// In en, this message translates to:
  /// **'10 sec'**
  String get setupDelay10Seconds;

  /// Thirty-second delay choice
  ///
  /// In en, this message translates to:
  /// **'30 sec'**
  String get setupDelay30Seconds;

  /// One-minute delay choice
  ///
  /// In en, this message translates to:
  /// **'1 min'**
  String get setupDelay1Minute;

  /// Three-minute delay choice
  ///
  /// In en, this message translates to:
  /// **'3 min'**
  String get setupDelay3Minutes;

  /// Ringtone option: telephone
  ///
  /// In en, this message translates to:
  /// **'Telephone'**
  String get ringtoneTelephone;

  /// Ringtone option: classic ring
  ///
  /// In en, this message translates to:
  /// **'Classic Ring'**
  String get ringtoneRinging;

  /// Ringtone option: classic phone
  ///
  /// In en, this message translates to:
  /// **'Classic Phone'**
  String get ringtoneClassic;

  /// Ringtone option: modern 1
  ///
  /// In en, this message translates to:
  /// **'Modern 1'**
  String get ringtoneModern1;

  /// Ringtone option: modern 2
  ///
  /// In en, this message translates to:
  /// **'Modern 2'**
  String get ringtoneModern2;

  /// Custom ring-delay chip label
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get setupDelayCustom;

  /// Title of the custom delay dialog
  ///
  /// In en, this message translates to:
  /// **'Custom ring delay'**
  String get setupDelayCustomTitle;

  /// Allowed range hint in the custom delay dialog
  ///
  /// In en, this message translates to:
  /// **'Between 10 seconds and 3 minutes.'**
  String get setupDelayCustomRange;

  /// Confirm button in the custom delay dialog
  ///
  /// In en, this message translates to:
  /// **'SET'**
  String get setupDelaySet;

  /// Incoming call section heading
  ///
  /// In en, this message translates to:
  /// **'INCOMING CALL'**
  String get setupIncomingCall;

  /// Incoming call preview badge
  ///
  /// In en, this message translates to:
  /// **'PREVIEW'**
  String get setupPreview;

  /// Caller relationship label
  ///
  /// In en, this message translates to:
  /// **'Emergency contact'**
  String get setupEmergencyContact;

  /// Caller voice style label
  ///
  /// In en, this message translates to:
  /// **'VOICE: PANICKED'**
  String get setupVoicePanicked;

  /// Ringtone setting label
  ///
  /// In en, this message translates to:
  /// **'Ringtone'**
  String get setupRingtone;

  /// Containment alarm ringtone option
  ///
  /// In en, this message translates to:
  /// **'Containment Alarm'**
  String get setupRingtoneContainment;

  /// Soft chime ringtone option
  ///
  /// In en, this message translates to:
  /// **'Soft Chime'**
  String get setupRingtoneSoft;

  /// Classic ringtone option
  ///
  /// In en, this message translates to:
  /// **'Classic Ringtone'**
  String get setupRingtoneClassic;

  /// Script language section heading
  ///
  /// In en, this message translates to:
  /// **'SCRIPT LANGUAGE'**
  String get setupScriptLanguage;

  /// Situation input section heading
  ///
  /// In en, this message translates to:
  /// **'SITUATION / EVENT'**
  String get setupSituationEvent;

  /// Situation input hint
  ///
  /// In en, this message translates to:
  /// **'e.g., At a party and ready to head home'**
  String get setupSituationHint;

  /// Voice script section heading
  ///
  /// In en, this message translates to:
  /// **'VOICE SCRIPT'**
  String get setupVoiceScript;

  /// AI script option label
  ///
  /// In en, this message translates to:
  /// **'Generate with AI'**
  String get setupGenerateWithAI;

  /// Manual script option label
  ///
  /// In en, this message translates to:
  /// **'Write my own'**
  String get setupWriteMyOwn;

  /// Voice script input hint
  ///
  /// In en, this message translates to:
  /// **'Write your script...'**
  String get setupScriptHint;

  /// Initial editable script example
  ///
  /// In en, this message translates to:
  /// **'Hey, can you call me? I need a reason to step out.'**
  String get setupScriptExample;

  /// Reminder to review the script
  ///
  /// In en, this message translates to:
  /// **'Review and edit before use.'**
  String get setupReviewNote;

  /// Arm button label
  ///
  /// In en, this message translates to:
  /// **'ARM STEALTH MODE'**
  String get setupArmButton;

  /// Local armed-state button label
  ///
  /// In en, this message translates to:
  /// **'STEALTH MODE ARMED'**
  String get setupArmedStatus;

  /// Setup screen disclaimer: the call is simulated and needs the app in the foreground
  ///
  /// In en, this message translates to:
  /// **'Simulated call only. Nothing is dialed and no phone network is used. Keep the app open until the call rings.'**
  String get setupDisclaimer;

  /// Countdown screen header status
  ///
  /// In en, this message translates to:
  /// **'Standing by...'**
  String get countdownStandingBy;

  /// Countdown screen subtitle badge
  ///
  /// In en, this message translates to:
  /// **'SILENT COUNTDOWN'**
  String get countdownSilent;

  /// Countdown screen cancel button
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get countdownCancelButton;

  /// Incoming call status text
  ///
  /// In en, this message translates to:
  /// **'Incoming call...'**
  String get incomingCallTitle;

  /// Accessible incoming call tap answer button
  ///
  /// In en, this message translates to:
  /// **'TAP TO ANSWER'**
  String get tapToAnswer;

  /// Active call connection status
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get callConnected;

  /// Active call script control button
  ///
  /// In en, this message translates to:
  /// **'Script'**
  String get activeCallScript;

  /// Call ended screen main heading
  ///
  /// In en, this message translates to:
  /// **'Call ended'**
  String get callEndedTitle;

  /// Call ended screen subtitle message
  ///
  /// In en, this message translates to:
  /// **'Your call has ended.'**
  String get callEndedSubtitle;

  /// Call ended return to setup button
  ///
  /// In en, this message translates to:
  /// **'RETURN TO SETUP'**
  String get callEndedReturnButton;

  /// Call ended readiness status
  ///
  /// In en, this message translates to:
  /// **'Ready for another call.'**
  String get callEndedReady;

  /// Validation message when countdown delay is out of range
  ///
  /// In en, this message translates to:
  /// **'Invalid delay. Delay must be between 10 and 180 seconds.'**
  String get errorInvalidDelay;

  /// Warning message when user tries to arm while call is active
  ///
  /// In en, this message translates to:
  /// **'A simulation is already active. Please wait or cancel the current call.'**
  String get errorSimulationActive;

  /// Language picker option that follows the device language
  ///
  /// In en, this message translates to:
  /// **'Device language'**
  String get languageSystem;

  /// Title of the caller persona picker
  ///
  /// In en, this message translates to:
  /// **'Choose caller'**
  String get setupChooseCaller;

  /// Relationship label for the landlord persona
  ///
  /// In en, this message translates to:
  /// **'Property manager'**
  String get personaRelationshipLandlord;

  /// Relationship label for the office persona
  ///
  /// In en, this message translates to:
  /// **'Workplace support'**
  String get personaRelationshipOffice;

  /// Voice style badge for the landlord persona
  ///
  /// In en, this message translates to:
  /// **'VOICE: URGENT'**
  String get personaVoiceUrgent;

  /// Badge for a persona that has no voice recording
  ///
  /// In en, this message translates to:
  /// **'SCRIPT ONLY'**
  String get personaVoiceNone;

  /// Setup warning when the selected ringtone file is missing
  ///
  /// In en, this message translates to:
  /// **'Ringtone audio isn\'t installed. The call screen will appear, but it won\'t ring out loud.'**
  String get setupAudioMissingRingtone;

  /// Setup warning when the caller's voice file is missing
  ///
  /// In en, this message translates to:
  /// **'No voice recording for this caller. Only the on-screen script will be shown.'**
  String get setupAudioMissingVoice;

  /// Countdown hint: the countdown only runs in the foreground
  ///
  /// In en, this message translates to:
  /// **'Keep GhostBuster open. Leaving the app cancels the call.'**
  String get countdownKeepOpen;

  /// Countdown button that skips the wait and rings immediately
  ///
  /// In en, this message translates to:
  /// **'Preview incoming call screen'**
  String get countdownRingNow;

  /// Heading of the script card on the active call screen
  ///
  /// In en, this message translates to:
  /// **'EMERGENCY SCRIPT'**
  String get activeCallScriptTitle;

  /// Voice Script Manager screen title
  ///
  /// In en, this message translates to:
  /// **'Voice Script Manager'**
  String get voiceManagerTitle;

  /// Setup entry label opening the Voice Script Manager
  ///
  /// In en, this message translates to:
  /// **'Voice scripts'**
  String get voiceManagerEntry;

  /// Create recording action
  ///
  /// In en, this message translates to:
  /// **'Create Recording'**
  String get voiceCreateRecording;

  /// Empty-state heading
  ///
  /// In en, this message translates to:
  /// **'No voice scripts yet'**
  String get voiceEmptyTitle;

  /// Empty-state body
  ///
  /// In en, this message translates to:
  /// **'Record your own emergency voice script to play during a simulated call.'**
  String get voiceEmptyBody;

  /// Recording-in-progress status
  ///
  /// In en, this message translates to:
  /// **'Recording...'**
  String get voiceRecordingNow;

  /// Paused status
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get voicePaused;

  /// Pause control
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get voicePause;

  /// Resume control
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get voiceResume;

  /// Stop control
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get voiceStop;

  /// Cancel control
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get voiceCancel;

  /// Review heading after a recording is captured
  ///
  /// In en, this message translates to:
  /// **'Recording captured'**
  String get voiceReviewTitle;

  /// Preview control
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get voicePreview;

  /// Stop preview control
  ///
  /// In en, this message translates to:
  /// **'Stop preview'**
  String get voiceStopPreview;

  /// Retake control
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get voiceRetake;

  /// Save control
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get voiceSave;

  /// Save sheet title
  ///
  /// In en, this message translates to:
  /// **'Save recording'**
  String get voiceSaveTitle;

  /// Rename action
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get voiceRename;

  /// Rename sheet title
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get voiceRenameTitle;

  /// Delete action
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get voiceDelete;

  /// Delete confirmation title
  ///
  /// In en, this message translates to:
  /// **'Delete recording?'**
  String get voiceDeleteTitle;

  /// Delete confirmation body
  ///
  /// In en, this message translates to:
  /// **'This permanently removes the recording from this device.'**
  String get voiceDeleteBody;

  /// Scenario name field label
  ///
  /// In en, this message translates to:
  /// **'Scenario name'**
  String get voiceNameLabel;

  /// Scenario description field label
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get voiceDescriptionLabel;

  /// Use-for-call action
  ///
  /// In en, this message translates to:
  /// **'Use for call'**
  String get voiceUseForCall;

  /// Selected-for-call state label
  ///
  /// In en, this message translates to:
  /// **'Selected for call'**
  String get voiceSelectedForCall;

  /// Saved success message
  ///
  /// In en, this message translates to:
  /// **'Voice script saved.'**
  String get voiceSavedSuccess;

  /// Deleted success message
  ///
  /// In en, this message translates to:
  /// **'Recording deleted.'**
  String get voiceDeletedSuccess;

  /// Microphone denied error
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required to record.'**
  String get voiceMicDenied;

  /// Microphone permanently denied error
  ///
  /// In en, this message translates to:
  /// **'Microphone access is blocked. Enable it in system settings.'**
  String get voiceMicDeniedForever;

  /// Recording failed error
  ///
  /// In en, this message translates to:
  /// **'Recording failed. Please try again.'**
  String get voiceRecordFailed;

  /// Save failed error
  ///
  /// In en, this message translates to:
  /// **'Could not save the recording.'**
  String get voiceSaveFailed;

  /// Empty/missing recording error
  ///
  /// In en, this message translates to:
  /// **'The recording file is missing or empty.'**
  String get voiceEmptyRecording;

  /// Recording blocked during an active call
  ///
  /// In en, this message translates to:
  /// **'Finish the current call before recording.'**
  String get voiceRecordBlocked;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ceb', 'en', 'tl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ceb':
      return AppLocalizationsCeb();
    case 'en':
      return AppLocalizationsEn();
    case 'tl':
      return AppLocalizationsTl();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
