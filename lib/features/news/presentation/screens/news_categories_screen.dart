import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/news_repository.dart';
import '../../news_routes.dart';
import '../widgets/article_card.dart';
import '../widgets/category_tabs.dart';

/// Screen/News/Categories — «۰۳ · دسته‌بندی».
///
/// Tapping a tile opens SearchResults pre-filtered by that category, which is
/// the connection the deck's prototype map draws
/// («Home / Categories → SearchResults (فیلترشده)»).
class NewsCategoriesScreen extends ConsumerWidget {
  const NewsCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final categories = ref.watch(newsCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'دسته‌بندی اخبار',
          style: context.text.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: c.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'جستجو',
            icon: const Icon(Icons.search_rounded, size: 19),
            onPressed: () => context.push(Routes.newsSearch),
          ),
          const SizedBox(width: Space.s2),
        ],
      ),
      body: NewsAsync(
        value: categories,
        onRetry: () => ref.invalidate(newsCategoriesProvider),
        builder: (context, groups) => groups.isEmpty
            ? const EmptyState(
                icon: Icons.category_outlined,
                title: 'دسته‌بندی‌ای برای نمایش نیست.',
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  Space.page,
                  Space.s2 - 2,
                  Space.page,
                  Space.s6,
                ),
                itemCount: groups.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: Space.s2 + 2),
                itemBuilder: (context, i) => CategoryCard(
                  group: groups[i],
                  onTap: () => context.push(
                    newsSearchResultsPath(
                      category: groups[i].id,
                      categoryLabel: groups[i].title,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
