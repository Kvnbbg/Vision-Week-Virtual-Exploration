// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

/// Callers can obtain an [AppLocalizations] instance with `AppLocalizations.of(context)!`.
///
/// The strings in this file were generated from the ARB templates in `lib/l10n`.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  String get appTitle;
  String get helloWorld;
  String get welcomeMessage;
  String get login;
  String get loginTitle;
  String get logout;
  String get email;
  String get emailRequired;
  String get password;
  String get passwordRequired;
  String get passwordTooShort;
  String get signUp;
  String get forgotPassword;
  String get homeTitle;
  String get exploreZoo;
  String get startExploring;
  String get generateText;
  String get animalGallery;
  String get feedbackTitle;
  String get feedbackLabel;
  String get submitFeedback;
  String get feedbackListTitle;
  String get welcomeAppBarTitle;
  String get welcomeMessageBody;
  String get welcomeStartButton;
  String get registerSuccessMessage;
  String get registerTitle;
  String get feedbackEmpty;
  String get settings;
  String get darkModeLabel;
  String get darkModeDescription;
  String get lightModeDescription;
  String get languagePickerLabel;
  String get languagesTooltip;
  String get languageEnglish;
  String get languageFrench;
  String get accessibilityTitle;
  String get accessibilityDescription;
  String get userProfile;
  String get manageProfile;
  String get videos;
  String get watchVideos;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(_lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

bool _isSupported(Locale locale) {
  for (final supportedLocale in AppLocalizations.supportedLocales) {
    if (supportedLocale.languageCode == locale.languageCode) {
      return true;
    }
  }
  return false;
}

AppLocalizations _lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }
  throw FlutterError('AppLocalizations.delegate failed to load unsupported locale "${locale}".');
}

class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn() : super('en');

  @override
  String get appTitle => 'Vision Week';
  @override
  String get helloWorld => 'Hello World';
  @override
  String get welcomeMessage => 'Welcome to Vision Week!';
  @override
  String get login => 'Login';
  @override
  String get loginTitle => 'Sign in';
  @override
  String get logout => 'Logout';
  @override
  String get email => 'Email address';
  @override
  String get emailRequired => 'Email is required';
  @override
  String get password => 'Password';
  @override
  String get passwordRequired => 'Password is required';
  @override
  String get passwordTooShort => 'Password must contain at least 8 characters';
  @override
  String get signUp => 'Sign Up';
  @override
  String get forgotPassword => 'Forgot Password?';
  @override
  String get homeTitle => 'Home';
  @override
  String get exploreZoo => 'Explore the zoo and learn about animals.';
  @override
  String get startExploring => 'Start Exploring';
  @override
  String get generateText => 'Generate Text';
  @override
  String get animalGallery => 'Animal Gallery';
  @override
  String get feedbackTitle => 'Your Feedback';
  @override
  String get feedbackLabel => 'Enter your feedback';
  @override
  String get submitFeedback => 'Submit Feedback';
  @override
  String get feedbackListTitle => 'Feedback List';
  @override
  String get welcomeAppBarTitle => 'Vision Week';
  @override
  String get welcomeMessageBody => 'Welcome to Vision Week!';
  @override
  String get welcomeStartButton => 'Start';
  @override
  String get registerSuccessMessage => 'Account created successfully. Check your inbox to verify your email.';
  @override
  String get registerTitle => 'Create an account';
  @override
  String get feedbackEmpty => 'No feedback yet';
  @override
  String get settings => 'Settings';
  @override
  String get darkModeLabel => 'Dark theme';
  @override
  String get darkModeDescription => 'Using the dark experience';
  @override
  String get lightModeDescription => 'Using the light experience';
  @override
  String get languagePickerLabel => 'App language';
  @override
  String get languagesTooltip => 'Languages';
  @override
  String get languageEnglish => 'English';
  @override
  String get languageFrench => 'French';
  @override
  String get accessibilityTitle => 'Accessibility';
  @override
  String get accessibilityDescription => 'Responsive layout and larger tap targets are enabled by default.';
  @override
  String get userProfile => 'User Profile';
  @override
  String get manageProfile => 'Manage your account and preferences.';
  @override
  String get videos => 'Videos';
  @override
  String get watchVideos => 'Watch the latest exploration highlights.';
}

class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr() : super('fr');

  @override
  String get appTitle => 'Semaine de la Vision';
  @override
  String get helloWorld => 'Bonjour le monde';
  @override
  String get welcomeMessage => 'Bienvenue à la Semaine de la Vision !';
  @override
  String get login => 'Connexion';
  @override
  String get loginTitle => 'Connexion';
  @override
  String get logout => 'Déconnexion';
  @override
  String get email => 'Adresse e-mail';
  @override
  String get emailRequired => "L'e-mail est obligatoire";
  @override
  String get password => 'Mot de passe';
  @override
  String get passwordRequired => 'Le mot de passe est obligatoire';
  @override
  String get passwordTooShort => 'Le mot de passe doit contenir au moins 8 caractères';
  @override
  String get signUp => "S'inscrire";
  @override
  String get forgotPassword => 'Mot de passe oublié ?';
  @override
  String get homeTitle => 'Accueil';
  @override
  String get exploreZoo => 'Explorer le zoo et découvrir les animaux.';
  @override
  String get startExploring => "Commencer l'exploration";
  @override
  String get generateText => 'Générer du texte';
  @override
  String get animalGallery => "Galerie d'animaux";
  @override
  String get feedbackTitle => 'Votre avis';
  @override
  String get feedbackLabel => 'Entrez votre avis';
  @override
  String get submitFeedback => 'Envoyer un avis';
  @override
  String get feedbackListTitle => 'Liste des avis';
  @override
  String get welcomeAppBarTitle => 'Semaine Vision';
  @override
  String get welcomeMessageBody => 'Bienvenue à la Semaine Vision !';
  @override
  String get welcomeStartButton => 'Commencer';
  @override
  String get registerSuccessMessage => 'Compte créé avec succès. Consultez votre messagerie pour vérifier votre email.';
  @override
  String get registerTitle => 'Créer un compte';
  @override
  String get feedbackEmpty => 'Aucun avis pour le moment';
  @override
  String get settings => 'Paramètres';
  @override
  String get darkModeLabel => 'Thème sombre';
  @override
  String get darkModeDescription => 'Expérience sombre activée';
  @override
  String get lightModeDescription => 'Expérience claire activée';
  @override
  String get languagePickerLabel => "Langue de l'application";
  @override
  String get languagesTooltip => 'Langues';
  @override
  String get languageEnglish => 'Anglais';
  @override
  String get languageFrench => 'Français';
  @override
  String get accessibilityTitle => 'Accessibilité';
  @override
  String get accessibilityDescription => 'Disposition adaptative et grandes zones tactiles activées par défaut.';
  @override
  String get userProfile => 'Profil utilisateur';
  @override
  String get manageProfile => 'Gérez votre compte et vos préférences.';
  @override
  String get videos => 'Vidéos';
  @override
  String get watchVideos => "Regardez les derniers moments forts de l'exploration.";
}
