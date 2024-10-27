import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// The title of the app displayed in the header
  ///
  /// In en, this message translates to:
  /// **'Vision Week'**
  String get appTitle;

  /// A basic greeting to the user, often used in tutorials or initial greetings
  ///
  /// In en, this message translates to:
  /// **'Hello World'**
  String get helloWorld;

  /// A welcoming message for users when they enter the app
  ///
  /// In en, this message translates to:
  /// **'Welcome to Vision Week!'**
  String get welcomeMessage;

  /// Text displayed on the login button
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Text displayed on the logout button
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Label for the email input field in the login form
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailLabel;

  /// Label for the password input field in the login form
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// Text displayed on the sign-up button
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Link text for users to reset their password
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Title for the home screen of the app
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// Description inviting users to explore the zoo feature
  ///
  /// In en, this message translates to:
  /// **'Explore the zoo and learn about animals.'**
  String get exploreZoo;

  /// Button text to begin the exploration of the zoo
  ///
  /// In en, this message translates to:
  /// **'Start Exploring'**
  String get startExploring;

  /// Button text to generate random text or content
  ///
  /// In en, this message translates to:
  /// **'Generate Text'**
  String get generateText;

  /// Title for the section displaying a gallery of animals
  ///
  /// In en, this message translates to:
  /// **'Animal Gallery'**
  String get animalGallery;

  /// Title for the feedback submission section
  ///
  /// In en, this message translates to:
  /// **'Your Feedback'**
  String get feedbackTitle;

  /// Label for the text area where users can provide their feedback
  ///
  /// In en, this message translates to:
  /// **'Enter your feedback'**
  String get feedbackLabel;

  /// Text displayed on the button to submit feedback
  ///
  /// In en, this message translates to:
  /// **'Submit Feedback'**
  String get submitFeedback;

  /// Title for the section displaying all submitted feedback
  ///
  /// In en, this message translates to:
  /// **'Feedback List'**
  String get feedbackListTitle;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
