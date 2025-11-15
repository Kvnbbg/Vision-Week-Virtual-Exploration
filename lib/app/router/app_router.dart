import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../auth/auth_service.dart';
import '../../screens/home_screen.dart';
import '../../screens/login.dart';
import '../../screens/order_tracking_screen.dart';
import '../../screens/register.dart';
import '../../screens/settings_screen.dart';
import '../../screens/welcome_screen.dart';
import '../../core/data/sample_data.dart';

/// Central routing table backed by `go_router` to support declarative,
/// deep-link friendly navigation. The router listens to [AuthService] changes in
/// order to redirect automatically when authentication state mutates.
class AppRouter {
  AppRouter({required AuthService authService}) : _authService = authService;

  final AuthService _authService;

  late final GoRouter router = GoRouter(
    initialLocation: '/home',
    refreshListenable: _authService,
    routes: <RouteBase>[
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/order-tracking',
        name: 'order-tracking',
        builder: (context, state) => OrderTrackingScreen(order: SampleData.activeOrder()),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
    ],
    redirect: (context, state) {
      final loggedIn = _authService.isUserLoggedIn();
      final loggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final onWelcome = state.matchedLocation == '/welcome';

      if (!loggedIn && !loggingIn && !onWelcome) {
        return '/login';
      }
      if (loggedIn && loggingIn) {
        return '/home';
      }
      return null;
    },
    errorBuilder: (context, state) => ErrorWidget.withDetails(
      message: state.error.toString(),
    ),
  );
}
