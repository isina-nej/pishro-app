import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/account/account_routes.dart';
import '../features/auth/auth_routes.dart';
import '../features/courses/courses_routes.dart';
import '../features/investment/investment_routes.dart';
import '../features/market/market_routes.dart';
import '../features/news/news_routes.dart';
import '../features/shell/app_shell.dart';
import '../shared/providers/session_provider.dart';
import 'routes.dart';

final _rootKey = GlobalKey<NavigatorState>();

/// Router root — module route lists composed here.
final routerProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(sessionProvider);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      if (state.matchedLocation == Routes.splash) return null;

      final loggedIn = session.isAuthenticated;
      final onAuthRoute = _authRoutePrefixes.any(
        state.matchedLocation.startsWith,
      );

      if (!loggedIn && !onAuthRoute) return Routes.welcome;
      if (loggedIn && onAuthRoute) return Routes.homeAfterLogin;
      return null;
    },
    routes: [
      ...authRoutes,
      ...checkoutRoutes,

      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: coursesTabRoutes),
          StatefulShellBranch(routes: newsRoutes),
          StatefulShellBranch(routes: investmentRoutes),
          StatefulShellBranch(routes: marketRoutes),
          StatefulShellBranch(routes: accountRoutes),
        ],
      ),
    ],
  );
});

const _authRoutePrefixes = [
  Routes.welcome,
  Routes.onboarding,
  Routes.login,
  Routes.signup,
  Routes.otp,
  Routes.forgotPassword,
];
