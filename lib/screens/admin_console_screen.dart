import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../core/data/sample_data.dart';

class AdminConsolePanel extends StatelessWidget {
  const AdminConsolePanel({super.key, required this.insights});

  final List<AdminInsight> insights;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.adminOverviewTitle, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.adminInsightsTitle, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  ...insights.map(
                    (insight) => ListTile(
                      leading: Icon(insight.icon, color: theme.colorScheme.primary),
                      title: Text(insight.title),
                      subtitle: Text(insight.subtitle),
                      trailing: Chip(label: Text(insight.highlight)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.policy_outlined),
                  title: Text(l10n.adminGovernanceTitle),
                  subtitle: Text(l10n.adminGovernanceSubtitle),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.document_scanner_outlined),
                  title: Text(l10n.adminAuditTitle),
                  subtitle: Text(l10n.adminAuditSubtitle),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.shield_outlined),
                label: Text(l10n.adminActionSecurity),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.show_chart_outlined),
                label: Text(l10n.adminActionMetrics),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.people_alt_outlined),
                label: Text(l10n.adminActionTeams),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
