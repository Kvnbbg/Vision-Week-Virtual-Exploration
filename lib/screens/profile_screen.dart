import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_service.dart';
import '../core/settings/settings_controller.dart';

class ProfilePanel extends StatelessWidget {
  const ProfilePanel({
    super.key,
    required this.authService,
    required this.settingsController,
    required this.onOpenSettings,
  });

  final AuthService authService;
  final SettingsController settingsController;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = authService.user;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.profileHeadline, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(Icons.person_outline),
              ),
              title: Text(user?.displayName ?? l10n.profileGuestName),
              subtitle: Text(user?.email ?? l10n.profileGuestEmail),
              trailing: user != null && !authService.isEmailVerified
                  ? Chip(
                      label: Text(l10n.profileEmailPending),
                      backgroundColor: Theme.of(context).colorScheme.errorContainer,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.profileRoleLabel, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(l10n.profileRoleDescription, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<UserRole>(
                    value: authService.role,
                    onChanged: (value) {
                      if (value != null) {
                        authService.selectRole(value);
                      }
                    },
                    decoration: InputDecoration(labelText: l10n.profileRoleLabel),
                    items: authService.supportedRoles
                        .map(
                          (role) => DropdownMenuItem<UserRole>(
                            value: role,
                            child: Text(_roleLabel(role, l10n)),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  value: settingsController.themeMode == ThemeMode.dark,
                  title: Text(l10n.darkModeLabel),
                  subtitle: Text(l10n.darkModeDescription),
                  onChanged: (value) => settingsController.toggleDarkMode(value),
                ),
                ListTile(
                  leading: const Icon(Icons.tune_outlined),
                  title: Text(l10n.profilePreferences),
                  subtitle: Text(l10n.profilePreferencesSubtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: onOpenSettings,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_active_outlined),
                  title: Text(l10n.profileNotifications),
                  subtitle: Text(l10n.profileNotificationsSubtitle),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: Text(l10n.profileSecurity),
                  subtitle: Text(l10n.profileSecuritySubtitle),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: () async {
                await authService.signOut();
                if (context.mounted) {
                  context.goNamed('login');
                }
              },
              icon: const Icon(Icons.logout),
              label: Text(l10n.profileSignOut),
            ),
          ),
        ],
      ),
    );
  }

  String _roleLabel(UserRole role, AppLocalizations l10n) {
    switch (role) {
      case UserRole.explorer:
        return l10n.roleExplorer;
      case UserRole.seller:
        return l10n.roleSeller;
      case UserRole.courier:
        return l10n.roleCourier;
      case UserRole.admin:
        return l10n.roleAdmin;
    }
  }
}
