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
  String get mute => 'mute';

  @override
  String get unmute => 'unmute';

  @override
  String get keypad => 'keypad';

  @override
  String get hideKeypad => 'Hide Keypad';

  @override
  String get speaker => 'speaker';

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
}
