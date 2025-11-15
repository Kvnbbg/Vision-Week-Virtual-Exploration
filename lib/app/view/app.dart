import 'package:flutter/material.dart';
import 'package:vision_week_virtual_exploration/l10n/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_service.dart';
import '../../core/settings/settings_controller.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';

class App extends StatefulWidget {
  const App({super.key, required this.settingsController, required this.authService});

  final SettingsController settingsController;
  final AuthService authService;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AppRouter _router = AppRouter(authService: widget.authService);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsController>.value(
          value: widget.settingsController,
        ),
        ChangeNotifierProvider<AuthService>.value(
          value: widget.authService,
        ),
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
            title: 'Vision Week Virtual Exploration',
            routerConfig: _router.router,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: widget.settingsController.themeMode,
            locale: widget.settingsController.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
          );
        },
      ),
    );
  }
}
