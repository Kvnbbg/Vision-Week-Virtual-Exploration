import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vision_week_virtual_exploration/core/config/app_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppConfig', () {
    test('parses colors and actions from json', () {
      final config = AppConfig.fromJson(<String, dynamic>{
        'branding': <String, dynamic>{
          'appName': 'Test App',
          'tagline': 'Testing made simple',
          'primaryColor': '#112233',
          'secondaryColor': '#445566',
        },
        'navigation': <String, dynamic>{'initialRoute': '/welcome'},
        'home': <String, dynamic>{
          'heroTitle': 'Hero',
          'heroSubtitle': 'Subtitle',
          'randomMessages': <String>['A', 'B'],
          'callToActions': <Map<String, dynamic>>[
            <String, dynamic>{
              'label': 'Open Settings',
              'routeName': 'settings',
              'style': 'outlined',
              'icon': 'settings',
            },
          ],
          'gallery': <Map<String, dynamic>>[
            <String, dynamic>{'title': 'Lion', 'assetPath': 'assets/lion.png'}
          ],
          'features': <Map<String, dynamic>>[
            <String, dynamic>{
              'title': 'Streaming',
              'description': 'Live events',
              'icon': 'live',
            }
          ],
          'featuresTitle': 'Highlights',
          'galleryTitle': 'Gallery',
          'quickLinksTitle': 'Links',
          'linkErrorMessage': 'Cannot open',
        },
        'welcome': <String, dynamic>{
          'headline': 'Welcome testers',
          'message': 'Enjoy your stay',
          'primaryButtonLabel': 'Enter',
        },
        'quickLinks': <Map<String, dynamic>>[
          <String, dynamic>{'label': 'Docs', 'url': 'https://example.com'},
        ],
      });

      expect(config.branding.appName, 'Test App');
      expect(config.branding.tagline, 'Testing made simple');
      expect(config.branding.primaryColor, const Color(0xFF112233));
      expect(config.branding.secondaryColor, const Color(0xFF445566));
      expect(config.navigation.initialRoute, '/welcome');
      expect(config.home.callToActions.first.style, HomeActionStyle.outlined);
      expect(config.home.callToActions.first.icon, FeatureIcon.settings);
      expect(config.home.featuresTitle, 'Highlights');
      expect(config.home.quickLinksTitle, 'Links');
      expect(config.quickLinks.single.url, 'https://example.com');
    });

    test('falls back to defaults when sections missing', () {
      final config = AppConfig.fromJson(<String, dynamic>{});

      expect(config.branding.appName, isNotEmpty);
      expect(config.home.randomMessages, isNotEmpty);
      expect(config.home.gallery, isNotEmpty);
      expect(config.quickLinks, isNotEmpty);
    });
  });
}
