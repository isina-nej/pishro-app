import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_routes.dart';
import '../features/shell/app_shell.dart';
import '../shared/providers/session_provider.dart';
import 'routes.dart';

final _rootKey = GlobalKey<NavigatorState>();

/// Router root.
///
/// Module agents own screen files only. Module route lists (e.g. [authRoutes])
/// are composed here by the coordinator.
final routerProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(sessionProvider);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      // Splash decides for itself; everything else needs a resolved session.
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

      // ---- Five-tab shell ----
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => AppShell(navigationShell: shell),
        branches: [
          _branch(Routes.courses, 'دوره‌ها'),
          _branch(Routes.news, 'اخبار'),
          _branch(Routes.investment, 'سرمایه‌گذاری'),
          _branch(Routes.market, 'بازار'),
          _branch(Routes.account, 'حساب کاربری'),
        ],
      ),
    ],
  );
});

/// Routes reachable while signed out.
const _authRoutePrefixes = [
  Routes.welcome,
  Routes.onboarding,
  Routes.login,
  Routes.signup,
  Routes.otp,
  Routes.forgotPassword,
];

StatefulShellBranch _branch(String path, String title) => StatefulShellBranch(
  routes: [GoRoute(path: path, builder: (_, __) => PlaceholderScreen(title))],
);
