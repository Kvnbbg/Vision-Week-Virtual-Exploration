import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../auth/auth_service.dart';
import '../core/data/sample_data.dart';
import '../core/settings/settings_controller.dart';
import 'admin_console_screen.dart';
import 'courier_dashboard.dart';
import 'explorer_dashboard.dart';
import 'merchant_dashboard.dart';
import 'order_tracking_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final LiveOrder _activeOrder;
  late final List<ExperiencePackage> _experiences;
  late final List<ExperienceBundle> _bundles;
  late final List<MerchantKpi> _merchantKpis;
  late final List<MerchantOrderSummary> _merchantOrders;
  late final List<CourierAssignment> _assignments;
  late final List<AdminInsight> _adminInsights;

  @override
  void initState() {
    super.initState();
    _activeOrder = SampleData.activeOrder();
    _experiences = SampleData.featuredExperiences();
    _bundles = SampleData.curatedBundles();
    _merchantKpis = SampleData.merchantKpis();
    _merchantOrders = SampleData.merchantOrders();
    _assignments = SampleData.courierAssignments();
    _adminInsights = SampleData.adminInsights();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsController>();
    final auth = context.watch<AuthService>();
    final tabs = _visibleTabs(l10n, auth, settings);
    final selectedIndex = _selectedIndex.clamp(0, tabs.length - 1).toInt();
    final selectedTab = tabs[selectedIndex];
    final isDarkMode = settings.themeMode == ThemeMode.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final useRail = screenWidth >= 1100;

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedTab.title(l10n)),
        actions: [
          IconButton(
            tooltip: l10n.logout,
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
          IconButton(
            tooltip: isDarkMode ? l10n.lightModeDescription : l10n.darkModeDescription,
            onPressed: () => settings.toggleDarkMode(!isDarkMode),
            icon: Icon(isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined),
          ),
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            tooltip: l10n.languagesTooltip,
            onSelected: settings.updateLocale,
            itemBuilder: (context) => [
              PopupMenuItem(value: const Locale('en'), child: Text(l10n.languageEnglish)),
              PopupMenuItem(value: const Locale('fr'), child: Text(l10n.languageFrench)),
            ],
          ),
          IconButton(
            tooltip: l10n.settings,
            onPressed: () => context.goNamed('settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: Row(
        children: [
          if (useRail)
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) => setState(() => _selectedIndex = index),
              extended: screenWidth >= 1440,
              labelType: NavigationRailLabelType.selected,
              destinations: [
                for (final tab in tabs)
                  NavigationRailDestination(
                    icon: Icon(tab.icon),
                    selectedIcon: Icon(tab.icon, color: Theme.of(context).colorScheme.primary),
                    label: Text(tab.title(l10n)),
                  ),
              ],
            ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: KeyedSubtree(
                key: ValueKey(selectedTab.key),
                child: selectedTab.builder(context),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: useRail
          ? null
          : NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) => setState(() => _selectedIndex = index),
              destinations: [
                for (final tab in tabs)
                  NavigationDestination(
                    icon: Icon(tab.icon),
                    label: tab.title(l10n),
                  ),
              ],
            ),
    );
  }

  List<_HomeTab> _visibleTabs(
    AppLocalizations l10n,
    AuthService auth,
    SettingsController settings,
  ) {
    final allTabs = <_HomeTab>[
      _HomeTab(
        key: 'explorer',
        icon: Icons.auto_awesome_outlined,
        roles: const {
          UserRole.explorer,
          UserRole.seller,
          UserRole.courier,
          UserRole.admin,
        },
        title: (l10n) => l10n.explorerTabLabel,
        builder: (context) => ExplorerDashboard(
          packages: _experiences,
          bundles: _bundles,
          liveOrder: _activeOrder,
          onViewOrder: () => context.goNamed('order-tracking'),
        ),
      ),
      _HomeTab(
        key: 'merchant',
        icon: Icons.storefront_outlined,
        roles: const {UserRole.seller, UserRole.admin},
        title: (l10n) => l10n.merchantTabLabel,
        builder: (context) => MerchantDashboard(
          kpis: _merchantKpis,
          orders: _merchantOrders,
        ),
      ),
      _HomeTab(
        key: 'courier',
        icon: Icons.delivery_dining_outlined,
        roles: const {UserRole.courier, UserRole.admin},
        title: (l10n) => l10n.courierTabLabel,
        builder: (context) => CourierDashboard(
          assignments: _assignments,
          liveOrder: _activeOrder,
        ),
      ),
      _HomeTab(
        key: 'tracking',
        icon: Icons.location_on_outlined,
        roles: const {
          UserRole.explorer,
          UserRole.courier,
          UserRole.seller,
          UserRole.admin,
        },
        title: (l10n) => l10n.trackingTabLabel,
        builder: (context) => OrderTrackingView(order: _activeOrder),
      ),
      _HomeTab(
        key: 'profile',
        icon: Icons.account_circle_outlined,
        roles: const {
          UserRole.explorer,
          UserRole.courier,
          UserRole.seller,
          UserRole.admin,
        },
        title: (l10n) => l10n.profileTabLabel,
        builder: (context) => ProfilePanel(
          authService: auth,
          settingsController: settings,
          onOpenSettings: () => context.goNamed('settings'),
        ),
      ),
      _HomeTab(
        key: 'admin',
        icon: Icons.dashboard_customize_outlined,
        roles: const {UserRole.admin},
        title: (l10n) => l10n.adminTabLabel,
        builder: (context) => AdminConsolePanel(insights: _adminInsights),
      ),
    ];

    final role = auth.role;
    final visibleTabs = allTabs.where((tab) => tab.roles.contains(role)).toList();
    return visibleTabs.isEmpty ? allTabs.where((tab) => tab.roles.contains(UserRole.explorer)).toList() : visibleTabs;
  }

  Future<void> _logout() async {
    await context.read<AuthService>().signOut();
    if (!mounted) {
      return;
    }
    context.goNamed('login');
  }
}

class _HomeTab {
  const _HomeTab({
    required this.key,
    required this.icon,
    required this.roles,
    required this.title,
    required this.builder,
  });

  final String key;
  final IconData icon;
  final Set<UserRole> roles;
  final String Function(AppLocalizations l10n) title;
  final WidgetBuilder builder;
}

class _FeedbackPanel extends StatelessWidget {
  const _FeedbackPanel({
    required this.controller,
    required this.onSubmit,
    required this.feedback,
    required this.l10n,
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;
  final List<String> feedback;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.feedbackTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: l10n.feedbackLabel,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onSubmit,
              icon: const Icon(Icons.send),
              label: Text(l10n.submitFeedback),
            ),
            const SizedBox(height: 16),
            Text(l10n.feedbackListTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (feedback.isEmpty)
              Text(
                l10n.feedbackEmpty,
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              ...feedback.map(
                (item) => ListTile(
                  leading: const Icon(Icons.chat_bubble_outline),
                  title: Text(item),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

IconData? _iconForFeature(FeatureIcon? icon) {
  switch (icon) {
    case FeatureIcon.explore:
      return Icons.travel_explore_outlined;
    case FeatureIcon.settings:
      return Icons.settings_outlined;
    case FeatureIcon.live:
      return Icons.videocam_outlined;
    case FeatureIcon.trophy:
      return Icons.emoji_events_outlined;
    case FeatureIcon.wellness:
      return Icons.self_improvement;
    case FeatureIcon.info:
      return Icons.info_outline;
    case null:
      return null;
  }
}
