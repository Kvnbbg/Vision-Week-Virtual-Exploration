import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get homeTitle => 'Home';

  @override
  String get loginTitle => 'Login';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get usernameRequired => 'Username is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get welcomeMessage => 'Welcome to the home screen';

  @override
  String get exploreZoo => 'Explore our virtual zoo and discover the wonders of wildlife.';

  @override
  String get startExploring => 'Start Exploring';

  @override
  String get informationText => 'For the best experience, use headphones and a stable internet connection.';
}
