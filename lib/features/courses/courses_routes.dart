import 'package:go_router/go_router.dart';

import 'presentation/screens/categories_screen.dart';
import 'presentation/screens/certificate_screen.dart';
import 'presentation/screens/chapters_screen.dart';
import 'presentation/screens/checkout_regular_screen.dart';
import 'presentation/screens/checkout_vip_screen.dart';
import 'presentation/screens/completion_screen.dart';
import 'presentation/screens/courses_home_screen.dart';
import 'presentation/screens/details_screen.dart';
import 'presentation/screens/discount_and_coin_screen.dart';
import 'presentation/screens/downloads_and_resources_screen.dart';
import 'presentation/screens/filters_screen.dart';
import 'presentation/screens/learning_dashboard_screen.dart';
import 'presentation/screens/lesson_details_screen.dart';
import 'presentation/screens/my_courses_screen.dart';
import 'presentation/screens/network_error_screen.dart';
import 'presentation/screens/package_comparison_screen.dart';
import 'presentation/screens/payment_failure_screen.dart';
import 'presentation/screens/payment_method_screen.dart';
import 'presentation/screens/payment_processing_screen.dart';
import 'presentation/screens/payment_success_screen.dart';
import 'presentation/screens/processing_screen.dart';
import 'presentation/screens/search_results_screen.dart';
import 'presentation/screens/search_screen.dart';
import 'presentation/screens/vip_instructor_chat_screen.dart';

/// Courses tab branch (keeps bottom nav).
final List<RouteBase> coursesTabRoutes = [
  GoRoute(
    path: '/courses',
    builder: (_, __) => const CoursesHomeScreen(),
    routes: [
      GoRoute(
        path: 'categories',
        builder: (_, __) => const CoursesCategoriesScreen(),
      ),
      GoRoute(
        path: 'search',
        builder: (_, __) => const CoursesSearchScreen(),
        routes: [
          GoRoute(
            path: 'results',
            builder: (_, __) => const CoursesSearchResultsScreen(),
          ),
          GoRoute(
            path: 'filters',
            builder: (_, __) => const CoursesFiltersScreen(),
          ),
        ],
      ),
      GoRoute(path: 'mine', builder: (_, __) => const MyCoursesScreen()),
      GoRoute(
        path: ':id',
        builder: (context, state) =>
            CourseDetailsScreen(id: state.pathParameters['id'] ?? ''),
        routes: [
          GoRoute(
            path: 'packages',
            builder: (context, state) =>
                PackageComparisonScreen(id: state.pathParameters['id'] ?? ''),
          ),
          GoRoute(
            path: 'learn',
            builder: (context, state) =>
                LearningDashboardScreen(id: state.pathParameters['id'] ?? ''),
          ),
          GoRoute(
            path: 'chapters',
            builder: (context, state) =>
                ChaptersScreen(id: state.pathParameters['id'] ?? ''),
          ),
          GoRoute(
            path: 'downloads',
            builder: (context, state) => DownloadsAndResourcesScreen(
              id: state.pathParameters['id'] ?? '',
            ),
          ),
          GoRoute(
            path: 'chat',
            builder: (context, state) =>
                VIPInstructorChatScreen(id: state.pathParameters['id'] ?? ''),
          ),
          GoRoute(
            path: 'completion',
            builder: (context, state) =>
                CompletionScreen(id: state.pathParameters['id'] ?? ''),
          ),
          GoRoute(
            path: 'certificate',
            builder: (context, state) =>
                CertificateScreen(id: state.pathParameters['id'] ?? ''),
          ),
          GoRoute(
            path: 'lessons/:lessonId',
            builder: (context, state) => LessonDetailsScreen(
              id: state.pathParameters['id'] ?? '',
              lessonId: state.pathParameters['lessonId'] ?? '',
            ),
          ),
        ],
      ),
    ],
  ),
];

/// Checkout covers the bottom nav (full-screen flow).
final List<RouteBase> checkoutRoutes = [
  GoRoute(
    path: '/checkout',
    builder: (_, __) => const CourseRegularScreen(),
    routes: [
      GoRoute(path: 'vip', builder: (_, __) => const CourseVIPScreen()),
      GoRoute(
        path: 'payment-method',
        builder: (_, __) => const PaymentMethodScreen(),
      ),
      GoRoute(
        path: 'discount',
        builder: (_, __) => const DiscountAndCoinScreen(),
      ),
      GoRoute(
        path: 'processing',
        builder: (_, __) => const PaymentProcessingScreen(),
      ),
      GoRoute(
        path: 'gateway',
        builder: (_, __) => const CheckoutProcessingScreen(),
      ),
      GoRoute(
        path: 'success',
        builder: (_, __) => const PaymentSuccessScreen(),
      ),
      GoRoute(
        path: 'failure',
        builder: (_, __) => const PaymentFailureScreen(),
      ),
      GoRoute(
        path: 'network-error',
        builder: (_, __) => const CheckoutNetworkErrorScreen(),
      ),
    ],
  ),
];

/// Combined export for agents / docs.
final List<RouteBase> coursesRoutes = [...coursesTabRoutes, ...checkoutRoutes];
