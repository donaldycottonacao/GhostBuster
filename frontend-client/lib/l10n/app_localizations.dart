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
  /// **'mute'**
  String get mute;

  /// Microphone unmute button label
  ///
  /// In en, this message translates to:
  /// **'unmute'**
  String get unmute;

  /// Dial pad toggle button label
  ///
  /// In en, this message translates to:
  /// **'keypad'**
  String get keypad;

  /// Dismiss dial pad modal label
  ///
  /// In en, this message translates to:
  /// **'Hide Keypad'**
  String get hideKeypad;

  /// Speakerphone toggle button label
  ///
  /// In en, this message translates to:
  /// **'speaker'**
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
