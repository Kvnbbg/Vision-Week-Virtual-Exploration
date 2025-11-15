import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../core/data/sample_data.dart';

class CourierDashboard extends StatelessWidget {
  const CourierDashboard({super.key, required this.assignments, required this.liveOrder});

  final List<CourierAssignment> assignments;
  final LiveOrder liveOrder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final nextAssignment = assignments.isNotEmpty ? assignments.first : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.courierOverviewTitle, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          if (nextAssignment != null) _buildNextStopCard(context, l10n, theme, nextAssignment),
          const SizedBox(height: 24),
          _buildAssignmentList(context, l10n, theme),
          const SizedBox(height: 24),
          _buildLiveOrderTelemetry(context, l10n, theme),
        ],
      ),
    );
  }

  Widget _buildNextStopCard(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    CourierAssignment assignment,
  ) {
    final etaLabel = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(assignment.eta),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.courierNextStopTitle, style: theme.textTheme.titleLarge),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.navigation_outlined),
                  label: Text(l10n.courierOpenNavigation),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.storefront_outlined)),
              title: Text(assignment.pickup),
              subtitle: Text(l10n.courierPickupSubtitle(assignment.dropOff)),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StatPill(icon: Icons.social_distance_outlined, label: l10n.courierDistance(assignment.distanceKm.toStringAsFixed(1))),
                _StatPill(icon: Icons.schedule_outlined, label: l10n.courierEta(etaLabel)),
                _StatPill(icon: Icons.flag_outlined, label: l10n.courierStatus(assignment.status)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentList(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.courierAssignmentsTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            if (assignments.isEmpty)
              Text(l10n.courierAssignmentsEmpty)
            else
              ...assignments.map(
                (assignment) => ListTile(
                  leading: const Icon(Icons.local_shipping_outlined),
                  title: Text('${assignment.pickup} → ${assignment.dropOff}'),
                  subtitle: Text(
                    l10n.courierDistanceEta(
                      assignment.distanceKm.toStringAsFixed(1),
                      MaterialLocalizations.of(context)
                          .formatTimeOfDay(TimeOfDay.fromDateTime(assignment.eta)),
                    ),
                  ),
                  trailing: Chip(label: Text(assignment.status)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveOrderTelemetry(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final eta = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(liveOrder.eta),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.courierLiveOrderTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: liveOrder.progress),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.activeOrderSubtitle(liveOrder.orderNumber)),
                Text(l10n.courierEta(eta)),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: liveOrder.steps
                  .map(
                    (step) => Chip(
                      avatar: const Icon(Icons.timeline_outlined),
                      label: Text(step.label),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.check_circle_outline),
              label: Text(l10n.courierCompleteStop),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      avatar: Icon(icon, size: 18, color: theme.colorScheme.primary),
      label: Text(label),
    );
  }
}
