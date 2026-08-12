import 'package:go_router/go_router.dart';

import '../../routing/routes.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/onboarding_01_screen.dart';
import 'presentation/screens/onboarding_02_screen.dart';
import 'presentation/screens/onboarding_03_screen.dart';
import 'presentation/screens/otp_screen.dart';
import 'presentation/screens/signup_screen.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/welcome_screen.dart';

/// Auth module routes — outside the tab shell.
///
/// Wired by the coordinator into [routerProvider]; screen agents do not edit
/// `app_router.dart`.
final List<RouteBase> authRoutes = [
  GoRoute(path: Routes.splash, builder: (_, __) => const SplashScreen()),
  GoRoute(path: Routes.welcome, builder: (_, __) => const WelcomeScreen()),
  GoRoute(
    path: Routes.onboarding,
    builder: (_, __) => const Onboarding01Screen(),
    routes: [
      GoRoute(path: '2', builder: (_, __) => const Onboarding02Screen()),
      GoRoute(path: '3', builder: (_, __) => const Onboarding03Screen()),
    ],
  ),
  GoRoute(path: Routes.login, builder: (_, __) => const LoginScreen()),
  GoRoute(path: Routes.signup, builder: (_, __) => const SignupScreen()),
  GoRoute(
    path: Routes.otp,
    builder: (context, state) {
      final phone = state.uri.queryParameters['phone'] ?? '';
      return OtpScreen(phone: phone);
    },
  ),
];
