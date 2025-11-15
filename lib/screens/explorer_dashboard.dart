import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../core/data/sample_data.dart';

class ExplorerDashboard extends StatefulWidget {
  const ExplorerDashboard({
    super.key,
    required this.packages,
    required this.bundles,
    required this.liveOrder,
    required this.onViewOrder,
  });

  final List<ExperiencePackage> packages;
  final List<ExperienceBundle> bundles;
  final LiveOrder liveOrder;
  final VoidCallback onViewOrder;

  @override
  State<ExplorerDashboard> createState() => _ExplorerDashboardState();
}

class _ExplorerDashboardState extends State<ExplorerDashboard> {
  final TextEditingController _feedbackController = TextEditingController();
  final List<String> _communityHighlights = <String>[
    'Aurora canopy pairing was unforgettable – please keep the chef table slots!',
    'Can we add a wildlife nutrition workshop next week? Our team loved the pilot.',
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 1100;
        final slivers = <Widget>[
          SliverToBoxAdapter(child: _buildHero(l10n, theme, constraints.maxWidth)),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(child: _buildQuickActions(l10n, theme)),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(child: _buildActiveOrder(l10n, theme)),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(child: _buildTrendingExperiences(l10n, theme)),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(child: _buildBundles(l10n, theme, isWide)),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(child: _buildCommunityHighlights(l10n, theme, isWide)),
          if (!isWide)
            SliverToBoxAdapter(child: _buildFeedbackPanel(l10n, theme)),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ];

        final content = CustomScrollView(
          key: const PageStorageKey<String>('explorer-dashboard'),
          slivers: slivers,
        );

        if (isWide) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: content),
                const SizedBox(width: 24),
                Expanded(
                  flex: 3,
                  child: _buildFeedbackPanel(l10n, theme, expand: true),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
          child: content,
        );
      },
    );
  }

  Widget _buildHero(AppLocalizations l10n, ThemeData theme, double width) {
    return AspectRatio(
      aspectRatio: width > 900 ? 16 / 5 : 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          image: const DecorationImage(
            image: AssetImage('assets/images/app.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.black.withOpacity(0.1),
              ],
            ),
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                l10n.explorerHeroHeadline,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Text(
                  l10n.explorerHeroSubtitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: widget.onViewOrder,
                    icon: const Icon(Icons.location_searching),
                    label: Text(l10n.quickActionTrack),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.schedule_send),
                    label: Text(l10n.quickActionSchedule),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.group_add_outlined),
                    label: Text(l10n.quickActionInvite),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(AppLocalizations l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.quickActionsTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _QuickActionCard(
              icon: Icons.restaurant,
              title: l10n.quickActionOrder,
              description: l10n.quickActionOrderDescription,
              onTap: () {},
            ),
            _QuickActionCard(
              icon: Icons.vrpano_outlined,
              title: l10n.quickActionExperience,
              description: l10n.quickActionExperienceDescription,
              onTap: () {},
            ),
            _QuickActionCard(
              icon: Icons.campaign_outlined,
              title: l10n.quickActionShare,
              description: l10n.quickActionShareDescription,
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveOrder(AppLocalizations l10n, ThemeData theme) {
    final order = widget.liveOrder;
    final timeOfDay = TimeOfDay.fromDateTime(order.eta);
    final etaLabel = MaterialLocalizations.of(context).formatTimeOfDay(timeOfDay);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.activeOrderTitle, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(l10n.activeOrderSubtitle(order.orderNumber)),
                  ],
                ),
                FilledButton.icon(
                  onPressed: widget.onViewOrder,
                  icon: const Icon(Icons.map_outlined),
                  label: Text(l10n.activeOrderView),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: order.progress.clamp(0, 1)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _InfoChip(icon: Icons.timer_outlined, label: l10n.activeOrderEta(etaLabel)),
                _InfoChip(icon: Icons.person_pin_circle_outlined, label: l10n.activeOrderCourier(order.courierName)),
                _InfoChip(icon: Icons.star_rate_outlined, label: l10n.activeOrderRating(order.courierRating.toStringAsFixed(1))),
              ],
            ),
            const SizedBox(height: 16),
            ...order.steps.map(
              (step) => ListTile(
                dense: true,
                leading: Icon(
                  Icons.check_circle,
                  color: step.timestamp.isBefore(DateTime.now())
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                ),
                title: Text(step.label),
                subtitle: Text(step.description),
                trailing: Text(
                  MaterialLocalizations.of(context).formatTimeOfDay(
                    TimeOfDay.fromDateTime(step.timestamp),
                    alwaysUse24HourFormat: false,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingExperiences(AppLocalizations l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.trendingExperiencesTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        SizedBox(
          height: 240,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.packages.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final item = widget.packages[index];
              return SizedBox(
                width: 280,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Image.asset(
                          item.imageAsset,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.photo_size_select_actual_outlined)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.title, style: theme.textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Text(item.subtitle, style: theme.textTheme.bodySmall),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              children: item.tags
                                  .map((tag) => Chip(label: Text(tag), padding: EdgeInsets.zero))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBundles(AppLocalizations l10n, ThemeData theme, bool isWide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.signatureBundlesTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: widget.bundles.map((bundle) {
            return SizedBox(
              width: isWide ? 320 : double.infinity,
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.asset(
                        bundle.imageAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.photo_library_outlined)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(bundle.name, style: theme.textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text(bundle.description, style: theme.textTheme.bodySmall),
                          const SizedBox(height: 12),
                          Text(l10n.bundlePrice(bundle.price.toStringAsFixed(0))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCommunityHighlights(AppLocalizations l10n, ThemeData theme, bool isWide) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.communityHighlightsTitle, style: theme.textTheme.titleLarge),
                if (isWide)
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.analytics_outlined),
                    label: Text(l10n.communityHighlightsInsights),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_communityHighlights.isEmpty)
              Text(l10n.communityHighlightsEmpty)
            else
              ..._communityHighlights.map(
                (highlight) => ListTile(
                  leading: const Icon(Icons.chat_bubble_outline),
                  title: Text(highlight),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackPanel(AppLocalizations l10n, ThemeData theme, {bool expand = false}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.feedbackTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(l10n.feedbackLabel, style: theme.textTheme.bodySmall),
            const SizedBox(height: 12),
            TextField(
              controller: _feedbackController,
              minLines: 4,
              maxLines: expand ? 8 : 5,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () => _submitFeedback(l10n),
                icon: const Icon(Icons.send),
                label: Text(l10n.submitFeedback),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitFeedback(AppLocalizations l10n) {
    final value = _feedbackController.text.trim();
    if (value.isEmpty) {
      return;
    }
    setState(() {
      _communityHighlights.insert(0, value);
      _feedbackController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.feedbackSubmitted)));
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 260,
      child: Card(
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 28, color: theme.colorScheme.primary),
                const SizedBox(height: 12),
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(description, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}
