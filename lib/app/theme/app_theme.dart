import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';

/// Centralized definition for the application's color schemes, typography and
/// component theming. The template derives its palette directly from
/// [BrandingConfig] so teams can restyle the experience with only configuration
/// changes.
class AppTheme {
  const AppTheme._();

  static ThemeData light(BrandingConfig branding) {
    final seed = branding.primaryColor ?? const Color(0xFF6750A4);
    final secondary = branding.secondaryColor ?? const Color(0xFFFFB347);
    final scheme = ColorScheme.fromSeed(seedColor: seed).copyWith(secondary: secondary);

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      visualDensity: VisualDensity.standard,
      inputDecorationTheme: _inputDecoration,
      elevatedButtonTheme: _elevatedButtonTheme,
      filledButtonTheme: _filledButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      snackBarTheme: _snackBarTheme,
    );
  }

  static ThemeData dark(BrandingConfig branding) {
    final seed = branding.primaryColor ?? const Color(0xFF6750A4);
    final secondary = branding.secondaryColor ?? const Color(0xFFFFB347);
    final scheme =
        ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark).copyWith(secondary: secondary);

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      visualDensity: VisualDensity.standard,
      inputDecorationTheme: _inputDecoration,
      elevatedButtonTheme: _elevatedButtonTheme,
      filledButtonTheme: _filledButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      snackBarTheme: _snackBarTheme,
    );
  }

  static const _borderRadius = BorderRadius.all(Radius.circular(14));

  static InputDecorationTheme get _inputDecoration => const InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(borderRadius: _borderRadius),
      );

  static ElevatedButtonThemeData get _elevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: _borderRadius),
          minimumSize: const Size.fromHeight(48),
        ),
      );

  static const FilledButtonThemeData _filledButtonTheme = FilledButtonThemeData(
    style: ButtonStyle(
      shape: MaterialStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: _borderRadius),
      ),
      minimumSize: MaterialStatePropertyAll<Size>(Size.fromHeight(48)),
    ),
  );

  static const OutlinedButtonThemeData _outlinedButtonTheme = OutlinedButtonThemeData(
    style: ButtonStyle(
      shape: MaterialStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: _borderRadius),
      ),
      minimumSize: MaterialStatePropertyAll<Size>(Size.fromHeight(48)),
    ),
  );

  static SnackBarThemeData get _snackBarTheme => const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      );
}
