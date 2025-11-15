import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vision_week_virtual_exploration/l10n/generated/app_localizations.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../auth/auth_service.dart';
import '../core/config/app_config.dart';
import '../core/settings/settings_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _random = Random();
  final _feedbackController = TextEditingController();
  final List<String> _feedbackList = <String>[];
  String? _generatedText;

  @override
  void initState() {
    super.initState();
    _generatedText = null;
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _generateRandomText(AppLocalizations l10n, List<String> messages) {
    if (messages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.generateText)),
      );
      return;
    }

    setState(() {
      _generatedText = messages[_random.nextInt(messages.length)];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.generateText)),
    );
  }

  Future<void> _logout() async {
    await context.read<AuthService>().signOut();
    if (!mounted) {
      return;
    }
    context.goNamed('login');
  }

  void _submitFeedback(AppLocalizations l10n) {
    final feedback = _feedbackController.text.trim();
    if (feedback.isEmpty) {
      return;
    }
    setState(() {
      _feedbackList.insert(0, feedback);
      _feedbackController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.submitFeedback)),
    );
  }

  Future<void> _openLink(String url, String? errorMessage) async {
    if (url.isEmpty) {
      return;
    }
    final launched = await launchUrlString(url);
    if (!launched && mounted && errorMessage != null && errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsController>();
    final config = context.watch<AppConfig>();
    final homeConfig = config.home;
    final isDarkMode = settings.themeMode == ThemeMode.dark;
    final userEmail = context.watch<AuthService>().user?.email;

    return Scaffold(
      appBar: AppBar(
        title: Text(config.branding.appName),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: l10n.logout,
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
          IconButton(
            tooltip: isDarkMode ? l10n.lightModeDescription : l10n.darkModeDescription,
            onPressed: () => settings.toggleDarkMode(!isDarkMode),
            icon: Icon(
              isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            ),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;
          final content = _buildContent(
            l10n: l10n,
            isWide: isWide,
            userEmail: userEmail,
            homeConfig: homeConfig,
            branding: config.branding,
            quickLinks: config.quickLinks,
          );

          if (isWide) {
            return Row(
              children: [
                Expanded(child: content),
                SizedBox(
                  width: min(360, constraints.maxWidth * 0.32),
                  child: _FeedbackPanel(
                    controller: _feedbackController,
                    onSubmit: () => _submitFeedback(l10n),
                    feedback: _feedbackList,
                    l10n: l10n,
                  ),
                ),
              ],
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              children: [
                content,
                const SizedBox(height: 24),
                _FeedbackPanel(
                  controller: _feedbackController,
                  onSubmit: () => _submitFeedback(l10n),
                  feedback: _feedbackList,
                  l10n: l10n,
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: homeConfig.randomMessages.isEmpty
            ? null
            : () => _generateRandomText(l10n, homeConfig.randomMessages),
        label: Text(l10n.generateText),
        icon: const Icon(Icons.auto_awesome),
      ),
    );
  }

  Widget _buildContent({
    required AppLocalizations l10n,
    required bool isWide,
    required String? userEmail,
    required HomeConfig homeConfig,
    required BrandingConfig branding,
    required List<QuickLink> quickLinks,
  }) {
    final headline = Theme.of(context).textTheme.headlineMedium;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(homeConfig.heroTitle, style: headline),
                const SizedBox(height: 12),
                Text(
                  branding.tagline,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(homeConfig.heroSubtitle),
                if (userEmail != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    userEmail,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
                if (homeConfig.callToActions.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: homeConfig.callToActions
                        .map((action) => _buildActionButton(action))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (homeConfig.features.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(homeConfig.featuresTitle ?? branding.tagline, style: headline),
          const SizedBox(height: 12),
          _FeatureHighlights(features: homeConfig.features),
        ],
        if (homeConfig.gallery.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(homeConfig.galleryTitle ?? l10n.animalGallery, style: headline),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isWide ? 4 : 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 4 / 5,
            ),
            itemCount: homeConfig.gallery.length,
            itemBuilder: (context, index) {
              final item = homeConfig.gallery[index];
              return _AnimalCard(item: item);
            },
          ),
        ],
        if (_generatedText?.isNotEmpty == true) ...[
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: Text(_generatedText!),
            ),
          ),
        ],
        if (quickLinks.isNotEmpty) ...[
          const SizedBox(height: 24),
          _QuickLinksCard(
            title: homeConfig.quickLinksTitle ?? 'Quick links',
            quickLinks: quickLinks,
            onTap: (url) => _openLink(url, homeConfig.linkErrorMessage),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton(HomeAction action) {
    Future<void> handleTap() async {
      try {
        if (!mounted) {
          return;
        }
        context.goNamed(action.routeName);
      } catch (error, stackTrace) {
        debugPrint('Failed to navigate to ${action.routeName}: $error');
        debugPrint('$stackTrace');
      }
    }

    final iconData = _iconForFeature(action.icon);

    switch (action.style) {
      case HomeActionStyle.outlined:
        return iconData != null
            ? OutlinedButton.icon(
                onPressed: handleTap,
                icon: Icon(iconData),
                label: Text(action.label),
              )
            : OutlinedButton(
                onPressed: handleTap,
                child: Text(action.label),
              );
      case HomeActionStyle.text:
        return iconData != null
            ? TextButton.icon(
                onPressed: handleTap,
                icon: Icon(iconData),
                label: Text(action.label),
              )
            : TextButton(
                onPressed: handleTap,
                child: Text(action.label),
              );
      case HomeActionStyle.filled:
      default:
        return iconData != null
            ? FilledButton.icon(
                onPressed: handleTap,
                icon: Icon(iconData),
                label: Text(action.label),
              )
            : FilledButton(
                onPressed: handleTap,
                child: Text(action.label),
              );
    }
  }
}

class _AnimalCard extends StatelessWidget {
  const _AnimalCard({required this.item});

  final GalleryItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.asset(
              item.assetPath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.photo, size: 48),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (item.description != null && item.description!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    item.description!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureHighlights extends StatelessWidget {
  const _FeatureHighlights({required this.features});

  final List<FeatureHighlight> features;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: features
          .map(
            (feature) => SizedBox(
              width: 280,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_iconForFeature(feature.icon) != null) ...[
                        Icon(
                          _iconForFeature(feature.icon)!,
                          size: 28,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                      ],
                      Text(
                        feature.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        feature.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _QuickLinksCard extends StatelessWidget {
  const _QuickLinksCard({
    required this.title,
    required this.quickLinks,
    required this.onTap,
  });

  final String title;
  final List<QuickLink> quickLinks;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...quickLinks.map(
              (link) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.open_in_new),
                title: Text(link.label),
                onTap: () => onTap(link.url),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
