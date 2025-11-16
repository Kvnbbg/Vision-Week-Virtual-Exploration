import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight storage facade responsible for persisting presentation-level
/// configuration without leaking the underlying implementation to the rest of
/// the application. Keeping storage reads and writes contained in a dedicated
/// class makes it trivial to replace `SharedPreferences` with a secure or
/// remote store in the future without touching presentation code.
class SettingsStorage {
  SettingsStorage(this._preferences);

  static const _themeKey = 'settings.theme_mode';
  static const _localeKey = 'settings.locale_code';

  final SharedPreferences _preferences;

  ThemeMode readTheme() {
    final value = _preferences.getString(_themeKey);
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> writeTheme(ThemeMode mode) async {
    var serializedMode = 'system';
    switch (mode) {
      case ThemeMode.dark:
        serializedMode = 'dark';
        break;
      case ThemeMode.light:
        serializedMode = 'light';
        break;
      case ThemeMode.system:
        break;
    }

    await _preferences.setString(_themeKey, serializedMode);
  }

  Locale readLocale() {
    final value = _preferences.getString(_localeKey);
    if (value == null || value.isEmpty) {
      return const Locale('en');
    }
    return Locale(value);
  }

  Future<void> writeLocale(Locale locale) async {
    await _preferences.setString(_localeKey, locale.languageCode);
  }
}
