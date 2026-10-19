import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Base class providing strongly typed localized strings for GhostBuster.
///
/// Implemented for English ('en'), Tagalog ('tl'), and Cebuano ('ceb').
abstract class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('tl'),
    Locale('ceb'),
  ];

  String get appTitle;
  String get appSubtitle;
  String get escapeSequenceArmed;
  String incomingCallTriggersIn(int seconds);
  String get configureTriggerDesc;
  String get callerPersona;
  String get triggerDelay;
  String armEscapeCall(int seconds);
  String cancelCountdown(int seconds);
  String get simulationDisclaimer;
  String get mobile;
  String get remindMe;
  String get message;
  String get slideToAnswer;
  String get decline;
  String get mute;
  String get unmute;
  String get keypad;
  String get hideKeypad;
  String get speaker;
  String get addCall;
  String get facetime;
  String get contacts;
  String get endCall;
  String get language;
  String get selectLanguage;
  String get english;
  String get tagalog;
  String get cebuano;
  String get errorAudioUnavailable;
  String get personaMom;
  String get personaLandlord;
  String get personaOffice;
}

class _AppLocalizationsEn extends AppLocalizations {
  _AppLocalizationsEn() : super(const Locale('en'));

  @override String get appTitle => 'GhostBuster - Stealth Escape';
  @override String get appSubtitle => 'Simulated Call Generator';
  @override String get escapeSequenceArmed => 'Escape Sequence Armed';
  @override String incomingCallTriggersIn(int seconds) => 'Incoming call triggers in $seconds seconds...';
  @override String get configureTriggerDesc => 'Configure trigger delay and select fake caller persona.';
  @override String get callerPersona => 'CALLER PERSONA';
  @override String get triggerDelay => 'TRIGGER DELAY';
  @override String armEscapeCall(int seconds) => 'ARM ESCAPE CALL (${seconds}s DELAY)';
  @override String cancelCountdown(int seconds) => 'CANCEL COUNTDOWN (${seconds}s)';
  @override String get simulationDisclaimer => 'Simulation only. No actual phone lines or cellular networks are accessed.';
  @override String get mobile => 'mobile';
  @override String get remindMe => 'Remind Me';
  @override String get message => 'Message';
  @override String get slideToAnswer => 'slide to answer';
  @override String get decline => 'Decline';
  @override String get mute => 'mute';
  @override String get unmute => 'unmute';
  @override String get keypad => 'keypad';
  @override String get hideKeypad => 'Hide Keypad';
  @override String get speaker => 'speaker';
  @override String get addCall => 'add call';
  @override String get facetime => 'FaceTime';
  @override String get contacts => 'contacts';
  @override String get endCall => 'End Call';
  @override String get language => 'Language';
  @override String get selectLanguage => 'Select Language';
  @override String get english => 'English';
  @override String get tagalog => 'Tagalog';
  @override String get cebuano => 'Cebuano / Bisaya';
  @override String get errorAudioUnavailable => 'Simulated audio track is unavailable. Playing silent safe fallback.';
  @override String get personaMom => 'Mom';
  @override String get personaLandlord => 'Landlord (Maintenance)';
  @override String get personaOffice => 'Office Dispatch';
}

class _AppLocalizationsTl extends AppLocalizations {
  _AppLocalizationsTl() : super(const Locale('tl'));

  @override String get appTitle => 'GhostBuster - Palihim na Pagtakas';
  @override String get appSubtitle => 'Tagabuo ng Huwad na Tawag';
  @override String get escapeSequenceArmed => 'Nakahanda na ang Pagtakas';
  @override String incomingCallTriggersIn(int seconds) => 'Tutunog ang tawag sa loob ng $seconds segundo...';
  @override String get configureTriggerDesc => 'Itakda ang oras ng paghihintay at piliin ang huwad na personahe.';
  @override String get callerPersona => 'PERSONAHE NG TUMATAWAG';
  @override String get triggerDelay => 'ORAS NG PAGHIHINTAY';
  @override String armEscapeCall(int seconds) => 'IHANDA ANG TAWAG (${seconds}s PAGHINTAY)';
  @override String cancelCountdown(int seconds) => 'IKANSELA ANG ORAS (${seconds}s)';
  @override String get simulationDisclaimer => 'Panggagaya lamang. Walang aktwal na linya ng telepono o network ang ginagamit.';
  @override String get mobile => 'mobile';
  @override String get remindMe => 'Ipaalala sa Akin';
  @override String get message => 'Mensahe';
  @override String get slideToAnswer => 'i-slide upang sagutin';
  @override String get decline => 'Tanggihan';
  @override String get mute => 'i-mute';
  @override String get unmute => 'i-unmute';
  @override String get keypad => 'keypad';
  @override String get hideKeypad => 'Itago ang Keypad';
  @override String get speaker => 'speaker';
  @override String get addCall => 'dagdag tawag';
  @override String get facetime => 'FaceTime';
  @override String get contacts => 'mga kontak';
  @override String get endCall => 'Tapusin ang Tawag';
  @override String get language => 'Wika';
  @override String get selectLanguage => 'Pumili ng Wika';
  @override String get english => 'Ingles';
  @override String get tagalog => 'Tagalog';
  @override String get cebuano => 'Cebuano / Bisaya';
  @override String get errorAudioUnavailable => 'Hindi magagamit ang audio track. Ligtas na ipinagpapatuloy nang walang tunog.';
  @override String get personaMom => 'Nanay';
  @override String get personaLandlord => 'May-ari ng Bahay (Maintenance)';
  @override String get personaOffice => 'Opisina / Dispatch';
}

class _AppLocalizationsCeb extends AppLocalizations {
  _AppLocalizationsCeb() : super(const Locale('ceb'));

  @override String get appTitle => 'GhostBuster - Tago nga Pag-ikyas';
  @override String get appSubtitle => 'Tighimo og Pekeng Tawag';
  @override String get escapeSequenceArmed => 'Andam na ang Pag-ikyas';
  @override String incomingCallTriggersIn(int seconds) => 'Motingog ang tawag sulod sa $seconds ka segundo...';
  @override String get configureTriggerDesc => 'I-set ang oras sa paghulat ug pilia ang pekeng persona.';
  @override String get callerPersona => 'PERSONA SA MANANAWAG';
  @override String get triggerDelay => 'ORAS SA PAGHULAT';
  @override String armEscapeCall(int seconds) => 'ANDAMA ANG TAWAG (${seconds}s HULAT)';
  @override String cancelCountdown(int seconds) => 'IKANSELA ANG ORAS (${seconds}s)';
  @override String get simulationDisclaimer => 'Pangsundog lamang. Walay aktwal nga linya sa telepono o network nga gigamit.';
  @override String get mobile => 'mobile';
  @override String get remindMe => 'Pahinumdomi Ko';
  @override String get message => 'Mensahe';
  @override String get slideToAnswer => 'i-slide aron tubagon';
  @override String get decline => 'Balibari';
  @override String get mute => 'i-mute';
  @override String get unmute => 'i-unmute';
  @override String get keypad => 'keypad';
  @override String get hideKeypad => 'Itago ang Keypad';
  @override String get speaker => 'speaker';
  @override String get addCall => 'dugang tawag';
  @override String get facetime => 'FaceTime';
  @override String get contacts => 'mga kontak';
  @override String get endCall => 'Undanga ang Tawag';
  @override String get language => 'Pinulongan';
  @override String get selectLanguage => 'Pilia ang Pinulongan';
  @override String get english => 'Iningles';
  @override String get tagalog => 'Tagalog';
  @override String get cebuano => 'Cebuano / Bisaya';
  @override String get errorAudioUnavailable => 'Dili magamit ang audio track. Luwas nga magpadayon nga walay tingog.';
  @override String get personaMom => 'Mama';
  @override String get personaLandlord => 'Tag-iya sa Balay (Maintenance)';
  @override String get personaOffice => 'Opisina / Dispatch';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'tl', 'ceb'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    switch (locale.languageCode) {
      case 'tl':
        return SynchronousFuture<AppLocalizations>(_AppLocalizationsTl());
      case 'ceb':
        return SynchronousFuture<AppLocalizations>(_AppLocalizationsCeb());
      case 'en':
      default:
        return SynchronousFuture<AppLocalizations>(_AppLocalizationsEn());
    }
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
