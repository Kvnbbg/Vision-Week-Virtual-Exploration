import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_service.dart';
import '../../core/config/app_config.dart';
import '../../core/settings/settings_controller.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';

class App extends StatefulWidget {
  const App({
    super.key,
    required this.settingsController,
    required this.authService,
    required this.config,
  });

  final SettingsController settingsController;
  final AuthService authService;
  final AppConfig config;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AppRouter _router = AppRouter(
    authService: widget.authService,
    navigation: widget.config.navigation,
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsController>.value(
          value: widget.settingsController,
        ),
        ChangeNotifierProvider<AuthService>.value(value: widget.authService),
        Provider<AppConfig>.value(value: widget.config),
      ],
      child: AnimatedBuilder(
        animation: widget.settingsController,
        builder: (context, _) {
          if (!widget.settingsController.isReady) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: widget.config.branding.appName,
            routerConfig: _router.router,
            theme: AppTheme.light(widget.config.branding),
            darkTheme: AppTheme.dark(widget.config.branding),
            themeMode: widget.settingsController.themeMode,
            locale: widget.settingsController.locale,
            supportedLocales: const [
              Locale('en'),
              Locale('fr'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}
