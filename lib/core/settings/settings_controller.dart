import 'package:flutter/material.dart';

import 'settings_storage.dart';

/// Reactive controller that keeps the application configuration (theme,
/// locale, text scaling…) in sync with persistent storage and notifies the UI
/// about changes. All mutations are debounced through async setters to keep the
/// UI responsive while guaranteeing durability.
class SettingsController extends ChangeNotifier {
  SettingsController(this._storage);

  final SettingsStorage _storage;

  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');
  bool _isReady = false;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get isReady => _isReady;

  Future<void> load() async {
    _themeMode = _storage.readTheme();
    _locale = _storage.readLocale();
    _isReady = true;
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) {
      return;
    }
    _themeMode = mode;
    notifyListeners();
    await _storage.writeTheme(mode);
  }

  Future<void> toggleDarkMode(bool isDark) =>
      updateThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);

  Future<void> updateLocale(Locale locale) async {
    if (_locale == locale) {
      return;
    }
    _locale = locale;
    notifyListeners();
    await _storage.writeLocale(locale);
  }
}
