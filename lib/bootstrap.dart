import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/view/app.dart';
import 'auth/auth_service.dart';
import 'core/config/app_config_loader.dart';
import 'core/settings/settings_controller.dart';
import 'core/settings/settings_storage.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Crashlytics is disabled automatically in debug to prevent noisy reports
  // while still capturing critical issues in release builds.
  if (kDebugMode) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  } else {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  final sharedPreferences = await SharedPreferences.getInstance();
  final settingsStorage = SettingsStorage(sharedPreferences);
  final settingsController = SettingsController(settingsStorage);
  await settingsController.load();

  final authService = AuthService();
  final appConfig = await const AppConfigLoader().load();

  runZonedGuarded(
    () => runApp(
        App(
          settingsController: settingsController,
          authService: authService,
          config: appConfig,
        ),
    ),
    (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack),
  );
}
