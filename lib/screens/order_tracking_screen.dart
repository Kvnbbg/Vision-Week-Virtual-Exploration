import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../core/data/sample_data.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key, required this.order});

  final LiveOrder order;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.trackingTabLabel)),
      body: OrderTrackingView(order: order),
    );
  }
}

class OrderTrackingView extends StatelessWidget {
  const OrderTrackingView({super.key, required this.order});

  final LiveOrder order;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final eta = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(order.eta),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.orderTrackingTitle(order.orderNumber), style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(l10n.orderTrackingEta(eta)),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(value: order.progress),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      Chip(label: Text(l10n.activeOrderCourier(order.courierName))),
                      Chip(label: Text(l10n.activeOrderRating(order.courierRating.toStringAsFixed(1)))),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(l10n.orderTimelineTitle, style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          Stepper(
            physics: const NeverScrollableScrollPhysics(),
            currentStep: _currentStepIndex(),
            controlsBuilder: (context, details) => const SizedBox.shrink(),
            steps: [
              for (final step in order.steps)
                Step(
                  title: Text(step.label),
                  subtitle: Text(step.description),
                  state: step.timestamp.isBefore(DateTime.now()) ? StepState.complete : StepState.indexed,
                  isActive: true,
                  content: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      MaterialLocalizations.of(context).formatTimeOfDay(
                        TimeOfDay.fromDateTime(step.timestamp),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.share_location_outlined),
            label: Text(l10n.orderTrackingShare),
          ),
        ],
      ),
    );
  }

  int _currentStepIndex() {
    final now = DateTime.now();
    final completed = order.steps.where((step) => step.timestamp.isBefore(now)).length;
    final index = completed == 0 ? 0 : (completed - 1).clamp(0, order.steps.length - 1);
    return index.toInt();
  }
}
