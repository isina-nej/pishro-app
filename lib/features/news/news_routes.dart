import 'package:go_router/go_router.dart';

import '../../routing/routes.dart';
import 'presentation/screens/comment_thread_screen.dart';
import 'presentation/screens/comments_screen.dart';
import 'presentation/screens/details_screen.dart';
import 'presentation/screens/filters_screen.dart';
import 'presentation/screens/news_categories_screen.dart';
import 'presentation/screens/news_home_screen.dart';
import 'presentation/screens/saved_screen.dart';
import 'presentation/screens/search_results_screen.dart';
import 'presentation/screens/search_screen.dart';
import 'presentation/screens/trending_screen.dart';

/// Builds `/news/search/results` with optional category query params.
String newsSearchResultsPath({String? category, String? categoryLabel}) {
  final params = <String, String>{
    if (category != null && category.isNotEmpty) 'category': category,
    if (categoryLabel != null && categoryLabel.isNotEmpty)
      'label': categoryLabel,
  };
  if (params.isEmpty) return '${Routes.newsSearch}/results';
  return Uri(
    path: '${Routes.newsSearch}/results',
    queryParameters: params,
  ).toString();
}

final List<RouteBase> newsRoutes = [
  GoRoute(
    path: '/news',
    builder: (_, __) => const NewsHomeScreen(),
    routes: [
      GoRoute(path: 'trending', builder: (_, __) => const TrendingScreen()),
      GoRoute(
        path: 'categories',
        builder: (_, __) => const NewsCategoriesScreen(),
      ),
      GoRoute(
        path: 'search',
        builder: (_, __) => const NewsSearchScreen(),
        routes: [
          GoRoute(
            path: 'results',
            builder: (_, __) => const NewsSearchResultsScreen(),
          ),
          GoRoute(
            path: 'filters',
            builder: (_, __) => const NewsFiltersScreen(),
          ),
        ],
      ),
      GoRoute(path: 'saved', builder: (_, __) => const NewsSavedScreen()),
      GoRoute(
        path: ':slug',
        builder: (context, state) =>
            NewsDetailsScreen(id: state.pathParameters['slug'] ?? ''),
        routes: [
          GoRoute(
            path: 'comments',
            builder: (context, state) =>
                NewsCommentsScreen(id: state.pathParameters['slug'] ?? ''),
            routes: [
              GoRoute(
                path: ':commentId',
                builder: (context, state) => NewsCommentThreadScreen(
                  id: state.pathParameters['slug'] ?? '',
                  commentId: state.pathParameters['commentId'] ?? '',
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  ),
];
