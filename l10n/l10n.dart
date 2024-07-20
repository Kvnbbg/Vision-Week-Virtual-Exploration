import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppLocalizations {
  static const AppLocalizationsDelegate delegate = AppLocalizationsDelegate();

  static List<Locale> get supportedLocales => [
        Locale('en', ''),
        Locale('fr', ''),
      ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
}
