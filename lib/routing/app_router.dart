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
///
/// The session is **read**, never watched. Watching it would rebuild this
/// provider the moment the stored token resolves, handing `MaterialApp.router`
/// a brand-new [GoRouter] that starts over at [Routes.splash] — which threw
/// away Splash's own `context.go` and left the app stuck on the splash screen.
/// `redirect` runs on every navigation, so reading gives it fresh state
/// without tying the router's identity to the session.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      if (state.matchedLocation == Routes.splash) return null;

      final session = ref.read(sessionProvider);
      // Before the token has been read, no destination is wrong yet — sending
      // a signed-in user to Welcome here is the cold-start flash.
      if (!session.isResolved) return null;

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
