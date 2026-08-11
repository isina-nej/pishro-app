import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/shell/app_shell.dart';
import '../shared/providers/session_provider.dart';
import 'routes.dart';

final _rootKey = GlobalKey<NavigatorState>();

/// Router root.
///
/// Module agents add their routes to the matching branch below and to the
/// top-level `routes` list for full-screen flows (checkout, onboarding) that
/// must cover the bottom navigation.
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
      final onAuthRoute = _authRoutes.any(state.matchedLocation.startsWith);

      if (!loggedIn && !onAuthRoute) return Routes.welcome;
      if (loggedIn && onAuthRoute) return Routes.homeAfterLogin;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (_, __) => const _SplashGate(),
      ),

      // ---- Auth flow (no tab bar) ----
      GoRoute(
        path: Routes.welcome,
        builder: (_, __) => const PlaceholderScreen('خوش آمدید'),
      ),
      GoRoute(
        path: Routes.login,
        builder: (_, __) => const PlaceholderScreen('ورود به حساب'),
      ),

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
const _authRoutes = [
  Routes.welcome,
  Routes.onboarding,
  Routes.login,
  Routes.signup,
  Routes.otp,
  Routes.forgotPassword,
];

StatefulShellBranch _branch(String path, String title) => StatefulShellBranch(
      routes: [
        GoRoute(path: path, builder: (_, __) => PlaceholderScreen(title)),
      ],
    );

/// Resolves the stored session, then hands off. The real Auth/Splash screen
/// replaces this.
class _SplashGate extends ConsumerWidget {
  const _SplashGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(sessionProvider, (_, next) {
      if (next.isResolved) {
        context.go(next.isAuthenticated ? Routes.homeAfterLogin : Routes.welcome);
      }
    });
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
