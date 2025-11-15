import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../core/data/sample_data.dart';

class MerchantDashboard extends StatelessWidget {
  const MerchantDashboard({super.key, required this.kpis, required this.orders});

  final List<MerchantKpi> kpis;
  final List<MerchantOrderSummary> orders;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.merchantOverviewTitle, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: kpis
                .map(
                  (kpi) => SizedBox(
                    width: 240,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(kpi.icon, color: theme.colorScheme.primary),
                            const SizedBox(height: 12),
                            Text(kpi.label, style: theme.textTheme.bodySmall),
                            const SizedBox(height: 4),
                            Text(kpi.value, style: theme.textTheme.titleLarge),
                            const SizedBox(height: 4),
                            Text(kpi.trend, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.secondary)),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 32),
          _buildOrderTable(l10n, theme),
          const SizedBox(height: 32),
          _buildActionsRow(l10n, theme),
        ],
      ),
    );
  }

  Widget _buildOrderTable(AppLocalizations l10n, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.ordersTableTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            if (orders.isEmpty)
              Text(l10n.ordersTableEmpty)
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text(l10n.ordersTableOrder)),
                    DataColumn(label: Text(l10n.ordersTableCustomer)),
                    DataColumn(label: Text(l10n.ordersTableValue)),
                    DataColumn(label: Text(l10n.ordersTableItems)),
                    DataColumn(label: Text(l10n.ordersTableStatus)),
                  ],
                  rows: orders
                      .map(
                        (order) => DataRow(
                          cells: [
                            DataCell(Text(order.orderNumber)),
                            DataCell(Text(order.customer)),
                            DataCell(Text(order.total)),
                            DataCell(Text(order.items.toString())),
                            DataCell(_statusChip(order.status, theme)),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status, ThemeData theme) {
    return Chip(
      label: Text(status),
      backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.2),
    );
  }

  Widget _buildActionsRow(AppLocalizations l10n, ThemeData theme) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.menu_book_outlined),
          label: Text(l10n.merchantCtaMenu),
        ),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.campaign_outlined),
          label: Text(l10n.merchantCtaCampaign),
        ),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.bolt_outlined),
          label: Text(l10n.merchantCtaAutomation),
        ),
      ],
    );
  }
}
