import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth/auth_service.dart';
import 'settings/theme_provider.dart';
import 'screens/ecran_principal.dart';
import 'screens/login.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(VisionWeekApp());
}

class VisionWeekApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SettingsProvider(),
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: 'Vision Week Virtual Exploration',
            theme: settingsProvider.themeMode == ThemeMode.dark ? ThemeData.dark() : ThemeData.light(),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('fr', ''),
            ],
            locale: settingsProvider.locale,
            home: AuthService().isUserLoggedIn() ? HomeScreen() : LoginScreen(),
          );
        },
      ),
    );
  }
}

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = Locale('en', '');

  SettingsProvider() {
    _loadSettings();
  }

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _saveSettings();
    notifyListeners();
  }

  void switchLocale(String languageCode) {
    _locale = Locale(languageCode, '');
    _saveSettings();
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = (prefs.getBool('isDarkTheme') ?? false) ? ThemeMode.dark : ThemeMode.light;
    _locale = Locale(prefs.getString('languageCode') ?? 'en', '');
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', _themeMode == ThemeMode.dark);
    await prefs.setString('languageCode', _locale.languageCode);
  }
}
