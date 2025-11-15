import 'package:flutter/material.dart';

/// Immutable configuration model that centralizes the Flutter template's
/// branding, navigation, and content. Editing a single JSON file allows teams
/// to re-theme and rebrand the application without touching layout code.
class AppConfig {
  const AppConfig({
    required this.branding,
    required this.navigation,
    required this.home,
    required this.welcome,
    this.quickLinks = const <QuickLink>[],
  });

  final BrandingConfig branding;
  final NavigationConfig navigation;
  final HomeConfig home;
  final WelcomeConfig welcome;
  final List<QuickLink> quickLinks;

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      branding: BrandingConfig.fromJson(
        json['branding'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
      navigation: NavigationConfig.fromJson(
        json['navigation'] as Map<String, dynamic>?,
      ),
      home: HomeConfig.fromJson(
        json['home'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
      welcome: WelcomeConfig.fromJson(
        json['welcome'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
      quickLinks: (json['quickLinks'] as List<dynamic>? ?? const <dynamic>[])
          .map((dynamic item) => QuickLink.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  static const AppConfig fallback = AppConfig(
    branding: BrandingConfig(
      appName: 'Vision Week Virtual Exploration',
      tagline: 'Explore and discover new possibilities!',
      primaryColor: Color(0xFF6C63FF),
      secondaryColor: Color(0xFFFFB347),
    ),
    navigation: NavigationConfig(),
    home: HomeConfig(
      heroTitle: 'Welcome to Vision Week!',
      heroSubtitle: 'Explore immersive habitats, live events, and curated activities.',
      randomMessages: <String>[
        'Explore and discover new possibilities!',
        "Let's make the most out of our virtual journey!",
        'Embrace creativity and innovation!',
        'Join us in our exploration adventures!',
        'Celebrate curiosity with every click!',
      ],
      callToActions: <HomeAction>[
        HomeAction(
          label: 'Start Exploring',
          routeName: 'welcome',
          style: HomeActionStyle.filled,
          icon: FeatureIcon.explore,
        ),
        HomeAction(
          label: 'Open Settings',
          routeName: 'settings',
          style: HomeActionStyle.outlined,
          icon: FeatureIcon.settings,
        ),
      ],
      gallery: <GalleryItem>[
        GalleryItem(
          title: 'Lion',
          assetPath: 'assets/images/lion.jpg',
          description: 'King of the savannah.',
        ),
        GalleryItem(
          title: 'Tiger',
          assetPath: 'assets/images/tiger.jpg',
          description: 'Stealthy forest predator.',
        ),
        GalleryItem(
          title: 'Elephant',
          assetPath: 'assets/images/elephant.jpg',
          description: 'Gentle giant with a powerful memory.',
        ),
        GalleryItem(
          title: 'Giraffe',
          assetPath: 'assets/images/giraffe.jpg',
          description: 'Tallest land animal with a lofty view.',
        ),
        GalleryItem(
          title: 'Zebra',
          assetPath: 'assets/images/zebra.jpg',
          description: 'Stripes that stand out in every herd.',
        ),
      ],
      features: <FeatureHighlight>[
        FeatureHighlight(
          title: 'Live Tours',
          description: 'Experience real-time guided sessions led by wildlife experts.',
          icon: FeatureIcon.live,
        ),
        FeatureHighlight(
          title: 'Team Challenges',
          description: 'Compete in friendly scavenger hunts to unlock hidden facts.',
          icon: FeatureIcon.trophy,
        ),
        FeatureHighlight(
          title: 'Wellness Breaks',
          description: 'Mindful audio journeys to reset focus during the day.',
          icon: FeatureIcon.wellness,
        ),
      ],
      featuresTitle: 'Program highlights',
      galleryTitle: 'Animal Gallery',
      quickLinksTitle: 'Quick links',
      linkErrorMessage: 'Unable to open link. Please try again later.',
    ),
    welcome: WelcomeConfig(
      headline: 'Welcome, Visionaries!',
      message:
          'Dive into curated habitats, insightful talks, and collaborative missions crafted for your organization.',
      primaryButtonLabel: 'Enter the Habitat',
    ),
    quickLinks: <QuickLink>[
      QuickLink(label: 'Visit Program Site', url: 'https://example.com/program'),
      QuickLink(label: 'Download Schedule', url: 'https://example.com/schedule.pdf'),
    ],
  );
}

class BrandingConfig {
  const BrandingConfig({
    required this.appName,
    required this.tagline,
    this.primaryColor,
    this.secondaryColor,
  });

  final String appName;
  final String tagline;
  final Color? primaryColor;
  final Color? secondaryColor;

  factory BrandingConfig.fromJson(Map<String, dynamic> json) {
    return BrandingConfig(
      appName: json['appName'] as String? ?? AppConfig.fallback.branding.appName,
      tagline: json['tagline'] as String? ?? AppConfig.fallback.branding.tagline,
      primaryColor:
          _parseColor(json['primaryColor'] as String?) ?? AppConfig.fallback.branding.primaryColor,
      secondaryColor:
          _parseColor(json['secondaryColor'] as String?) ?? AppConfig.fallback.branding.secondaryColor,
    );
  }
}

class NavigationConfig {
  const NavigationConfig({this.initialRoute = '/welcome'});

  final String initialRoute;

  factory NavigationConfig.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const NavigationConfig();
    }
    return NavigationConfig(
      initialRoute: json['initialRoute'] as String? ?? '/welcome',
    );
  }
}

class HomeConfig {
  const HomeConfig({
    required this.heroTitle,
    required this.heroSubtitle,
    required this.randomMessages,
    required this.callToActions,
    required this.gallery,
    required this.features,
    this.featuresTitle,
    this.galleryTitle,
    this.quickLinksTitle,
    this.linkErrorMessage,
  });

  final String heroTitle;
  final String heroSubtitle;
  final List<String> randomMessages;
  final List<HomeAction> callToActions;
  final List<GalleryItem> gallery;
  final List<FeatureHighlight> features;
  final String? featuresTitle;
  final String? galleryTitle;
  final String? quickLinksTitle;
  final String? linkErrorMessage;

  factory HomeConfig.fromJson(Map<String, dynamic> json) {
    return HomeConfig(
      heroTitle: json['heroTitle'] as String? ?? AppConfig.fallback.home.heroTitle,
      heroSubtitle: json['heroSubtitle'] as String? ?? AppConfig.fallback.home.heroSubtitle,
      randomMessages: (json['randomMessages'] as List<dynamic>? ?? AppConfig.fallback.home.randomMessages)
          .map((dynamic item) => item.toString())
          .toList(),
      callToActions: (json['callToActions'] as List<dynamic>? ??
              AppConfig.fallback.home.callToActions)
          .map((dynamic item) {
        if (item is HomeAction) {
          return item;
        }
        return HomeAction.fromJson(item as Map<String, dynamic>);
      }).toList(),
      gallery: (json['gallery'] as List<dynamic>? ?? AppConfig.fallback.home.gallery)
          .map((dynamic item) {
        if (item is GalleryItem) {
          return item;
        }
        return GalleryItem.fromJson(item as Map<String, dynamic>);
      }).toList(),
      features: (json['features'] as List<dynamic>? ?? AppConfig.fallback.home.features)
          .map((dynamic item) {
        if (item is FeatureHighlight) {
          return item;
        }
        return FeatureHighlight.fromJson(item as Map<String, dynamic>);
      }).toList(),
      featuresTitle: json['featuresTitle'] as String? ?? AppConfig.fallback.home.featuresTitle,
      galleryTitle: json['galleryTitle'] as String? ?? AppConfig.fallback.home.galleryTitle,
      quickLinksTitle: json['quickLinksTitle'] as String? ?? AppConfig.fallback.home.quickLinksTitle,
      linkErrorMessage: json['linkErrorMessage'] as String? ?? AppConfig.fallback.home.linkErrorMessage,
    );
  }
}

enum HomeActionStyle { filled, outlined, text }

enum FeatureIcon { explore, settings, live, trophy, wellness, info }

class HomeAction {
  const HomeAction({
    required this.label,
    required this.routeName,
    required this.style,
    this.icon,
  });

  final String label;
  final String routeName;
  final HomeActionStyle style;
  final FeatureIcon? icon;

  factory HomeAction.fromJson(Map<String, dynamic> json) {
    return HomeAction(
      label: json['label'] as String? ?? '',
      routeName: json['routeName'] as String? ?? 'home',
      style: _parseHomeActionStyle(json['style'] as String?) ?? HomeActionStyle.filled,
      icon: _parseFeatureIcon(json['icon'] as String?),
    );
  }
}

class GalleryItem {
  const GalleryItem({
    required this.title,
    required this.assetPath,
    this.description,
  });

  final String title;
  final String assetPath;
  final String? description;

  factory GalleryItem.fromJson(Map<String, dynamic> json) {
    return GalleryItem(
      title: json['title'] as String? ?? '',
      assetPath: json['assetPath'] as String? ?? '',
      description: json['description'] as String?,
    );
  }
}

class FeatureHighlight {
  const FeatureHighlight({
    required this.title,
    required this.description,
    this.icon,
  });

  final String title;
  final String description;
  final FeatureIcon? icon;

  factory FeatureHighlight.fromJson(Map<String, dynamic> json) {
    return FeatureHighlight(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: _parseFeatureIcon(json['icon'] as String?),
    );
  }
}

class WelcomeConfig {
  const WelcomeConfig({
    required this.headline,
    required this.message,
    required this.primaryButtonLabel,
  });

  final String headline;
  final String message;
  final String primaryButtonLabel;

  factory WelcomeConfig.fromJson(Map<String, dynamic> json) {
    return WelcomeConfig(
      headline: json['headline'] as String? ?? AppConfig.fallback.welcome.headline,
      message: json['message'] as String? ?? AppConfig.fallback.welcome.message,
      primaryButtonLabel:
          json['primaryButtonLabel'] as String? ?? AppConfig.fallback.welcome.primaryButtonLabel,
    );
  }
}

class QuickLink {
  const QuickLink({required this.label, required this.url});

  final String label;
  final String url;

  factory QuickLink.fromJson(Map<String, dynamic> json) {
    return QuickLink(
      label: json['label'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }
}

HomeActionStyle? _parseHomeActionStyle(String? value) {
  switch (value?.toLowerCase()) {
    case 'filled':
      return HomeActionStyle.filled;
    case 'outlined':
      return HomeActionStyle.outlined;
    case 'text':
      return HomeActionStyle.text;
    default:
      return null;
  }
}

FeatureIcon? _parseFeatureIcon(String? value) {
  switch (value?.toLowerCase()) {
    case 'explore':
      return FeatureIcon.explore;
    case 'settings':
      return FeatureIcon.settings;
    case 'live':
      return FeatureIcon.live;
    case 'trophy':
      return FeatureIcon.trophy;
    case 'wellness':
      return FeatureIcon.wellness;
    case 'info':
      return FeatureIcon.info;
    default:
      return null;
  }
}

Color? _parseColor(String? hex) {
  if (hex == null || hex.isEmpty) {
    return null;
  }
  final buffer = StringBuffer();
  if (hex.length == 6 || hex.length == 7) {
    buffer.write('ff');
  }
  buffer.write(hex.replaceFirst('#', ''));
  try {
    return Color(int.parse(buffer.toString(), radix: 16));
  } catch (_) {
    return null;
  }
}
