import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

/// Centralized definition for the application's color schemes, typography and
/// component theming. Leveraging [FlexColorScheme] keeps dark and light themes
/// visually consistent while still offering room for branding tweaks.
class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    return FlexThemeData.light(
      scheme: FlexScheme.mandyRed,
      useMaterial3: true,
      visualDensity: VisualDensity.standard,
      surfaceMode: FlexSurfaceMode.highScaffoldLevelSurface,
      blendLevel: 10,
      appBarStyle: FlexAppBarStyle.material,
      lightIsWhite: false,
      swapColors: false,
    ).copyWith(
      inputDecorationTheme: _inputDecoration,
      elevatedButtonTheme: _elevatedButtonTheme,
      snackBarTheme: _snackBarTheme,
    );
  }

  static ThemeData dark() {
    return FlexThemeData.dark(
      scheme: FlexScheme.mandyRed,
      useMaterial3: true,
      visualDensity: VisualDensity.standard,
      surfaceMode: FlexSurfaceMode.highScaffoldLevelSurface,
      blendLevel: 12,
    ).copyWith(
      inputDecorationTheme: _inputDecoration,
      elevatedButtonTheme: _elevatedButtonTheme,
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

  static SnackBarThemeData get _snackBarTheme => const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      );
}
