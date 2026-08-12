import 'package:go_router/go_router.dart';

import 'presentation/screens/analysis_comments_screen.dart';
import 'presentation/screens/analysis_details_screen.dart';
import 'presentation/screens/analysis_editor_screen.dart';
import 'presentation/screens/analysis_preview_screen.dart';
import 'presentation/screens/analyst_profile_screen.dart';
import 'presentation/screens/analyst_ratings_screen.dart';
import 'presentation/screens/asset_feed_screen.dart';
import 'presentation/screens/create_analysis_screen.dart';
import 'presentation/screens/following_feed_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/leaderboard_screen.dart';
import 'presentation/screens/premium_signals_screen.dart';
import 'presentation/screens/publish_result_screen.dart';
import 'presentation/screens/recommended_analysts_screen.dart';
import 'presentation/screens/search_screen.dart';
import 'presentation/screens/subscriptions_screen.dart';

final List<RouteBase> communityRoutes = [
  GoRoute(
    path: '/market/community',
    builder: (_, __) => const CommunityHomeScreen(),
    routes: [
      GoRoute(
        path: 'following',
        builder: (_, __) => const FollowingFeedScreen(),
      ),
      GoRoute(
        path: 'analysts',
        builder: (_, __) => const RecommendedAnalystsScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) =>
                AnalystProfileScreen(id: state.pathParameters['id'] ?? ''),
            routes: [
              GoRoute(
                path: 'ratings',
                builder: (context, state) =>
                    AnalystRatingsScreen(id: state.pathParameters['id'] ?? ''),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: 'leaderboard',
        builder: (_, __) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: 'search',
        builder: (_, __) => const CommunitySearchScreen(),
      ),
      GoRoute(
        path: 'signals',
        builder: (_, __) => const PremiumSignalsScreen(),
      ),
      GoRoute(
        path: 'subscriptions',
        builder: (_, __) => const CommunitySubscriptionsScreen(),
      ),
      GoRoute(
        path: 'create',
        builder: (_, __) => const CreateAnalysisScreen(),
        routes: [
          GoRoute(
            path: 'editor',
            builder: (_, __) => const AnalysisEditorScreen(),
          ),
          GoRoute(
            path: 'preview',
            builder: (_, __) => const AnalysisPreviewScreen(),
          ),
          GoRoute(
            path: 'result',
            builder: (_, __) => const PublishResultScreen(),
          ),
        ],
      ),
      GoRoute(
        path: 'analysis/:id',
        builder: (context, state) =>
            AnalysisDetailsScreen(id: state.pathParameters['id'] ?? ''),
        routes: [
          GoRoute(
            path: 'comments',
            builder: (context, state) =>
                AnalysisCommentsScreen(id: state.pathParameters['id'] ?? ''),
          ),
        ],
      ),
      GoRoute(
        path: 'asset/:id',
        builder: (context, state) =>
            AssetFeedScreen(id: state.pathParameters['id'] ?? ''),
      ),
    ],
  ),
];
