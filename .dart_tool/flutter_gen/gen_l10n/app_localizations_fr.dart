import 'app_localizations.dart';

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get homeTitle => 'Accueil';

  @override
  String get loginTitle => 'Connexion';

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get password => 'Mot de passe';

  @override
  String get login => 'Connexion';

  @override
  String get register => 'S\'inscrire';

  @override
  String get usernameRequired => 'Le nom d\'utilisateur est requis';

  @override
  String get passwordRequired => 'Le mot de passe est requis';

  @override
  String get welcomeMessage => 'Bienvenue à l\'écran d\'accueil';

  @override
  String get exploreZoo => 'Explorez notre zoo virtuel et découvrez les merveilles de la faune.';

  @override
  String get startExploring => 'Commencer l\'exploration';

  @override
  String get informationText => 'Pour une meilleure expérience, utilisez des écouteurs et une connexion Internet stable.';
}
