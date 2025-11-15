import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vision_week_virtual_exploration/l10n/generated/app_localizations.dart';

import '../core/settings/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsController>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile.adaptive(
              value: settings.themeMode == ThemeMode.dark,
              title: Text(l10n.darkModeLabel),
              subtitle: Text(settings.themeMode == ThemeMode.dark
                  ? l10n.darkModeDescription
                  : l10n.lightModeDescription),
              onChanged: (value) => settings.toggleDarkMode(value),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              title: Text(l10n.languagePickerLabel),
              subtitle: Text('${settings.locale.languageCode.toUpperCase()}'),
              trailing: DropdownButton<Locale>(
                value: settings.locale,
                underline: const SizedBox(),
                onChanged: (locale) {
                  if (locale != null) {
                    settings.updateLocale(locale);
                  }
                },
                items: [
                  DropdownMenuItem(value: const Locale('en'), child: Text(l10n.languageEnglish)),
                  DropdownMenuItem(value: const Locale('fr'), child: Text(l10n.languageFrench)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              title: Text(l10n.accessibilityTitle),
              subtitle: Text(l10n.accessibilityDescription),
              leading: const Icon(Icons.accessibility_new),
            ),
          ),
        ],
      ),
    );
  }
}
