import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'app_config.dart';

/// Loads [AppConfig] from an asset-backed JSON file. When the asset is missing
/// or malformed, the loader falls back to a curated default configuration so the
/// UI remains functional.
class AppConfigLoader {
  const AppConfigLoader({this.assetPath = 'assets/config/app_config.json'});

  final String assetPath;

  Future<AppConfig> load() async {
    try {
      final data = await rootBundle.loadString(assetPath);
      final Map<String, dynamic> jsonMap = json.decode(data) as Map<String, dynamic>;
      return AppConfig.fromJson(jsonMap);
    } on FlutterError catch (error) {
      debugPrint('AppConfig asset not found at $assetPath: ${error.message}');
    } on FormatException catch (error) {
      debugPrint('Failed to decode AppConfig JSON: $error');
    }
    return AppConfig.fallback;
  }
}
