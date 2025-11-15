import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vision_week_virtual_exploration/l10n/generated/app_localizations.dart';

import '../auth/auth_service.dart';
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
  late String _generatedText;

  static const _animalImages = [
    'assets/images/lion.jpg',
    'assets/images/tiger.jpg',
    'assets/images/elephant.jpg',
    'assets/images/giraffe.jpg',
    'assets/images/zebra.jpg',
  ];

  static const _animalNames = [
    'Lion',
    'Tiger',
    'Elephant',
    'Giraffe',
    'Zebra',
  ];

  @override
  void initState() {
    super.initState();
    _generatedText = '';
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _generateRandomText(AppLocalizations l10n) {
    const messages = [
      "Welcome to Vision Week!",
      "Explore and discover new possibilities!",
      "Let's make the most out of our virtual journey!",
      "Embrace creativity and innovation!",
      "Join us in our exploration adventures!",
    ];

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsController>();
    final isDarkMode = settings.themeMode == ThemeMode.dark;
    final userEmail = context.watch<AuthService>().user?.email;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
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
          final content = _buildContent(l10n, isWide, userEmail);

          if (isWide) {
            return Row(
              children: [
                Expanded(child: content),
                SizedBox(
                  width: min(320, constraints.maxWidth * 0.3),
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
        onPressed: () => _generateRandomText(l10n),
        label: Text(l10n.generateText),
        icon: const Icon(Icons.auto_awesome),
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n, bool isWide, String? userEmail) {
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
                Text(l10n.welcomeMessage, style: headline),
                const SizedBox(height: 12),
                if (userEmail != null)
                  Text(
                    userEmail,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                const SizedBox(height: 12),
                Text(l10n.exploreZoo),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: () => context.goNamed('welcome'),
                      icon: const Icon(Icons.map_outlined),
                      label: Text(l10n.startExploring),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.goNamed('settings'),
                      icon: const Icon(Icons.tune),
                      label: Text(l10n.settings),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(l10n.animalGallery, style: headline),
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
          itemCount: _animalImages.length,
          itemBuilder: (context, index) {
            final image = _animalImages[index];
            final name = _animalNames[index];
            return _AnimalCard(assetPath: image, name: name);
          },
        ),
        if (_generatedText.isNotEmpty) ...[
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: Text(_generatedText),
            ),
          ),
        ],
      ],
    );
  }
}

class _AnimalCard extends StatelessWidget {
  const _AnimalCard({required this.assetPath, required this.name});

  final String assetPath;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.asset(
              assetPath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.photo, size: 48),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
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
