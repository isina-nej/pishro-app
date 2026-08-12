import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/news_models.dart';
import '../../data/news_repository.dart';
import '../../news_routes.dart';
import '../widgets/article_card.dart';
import '../widgets/category_tabs.dart';

/// Screen/News/Home — «۰۱ · اخبار (خانه)».
///
/// Featured card, then «آخرین اخبار» as compact rows. The category strip sits
/// under the title bar and re-queries `GET /news?category=`.
class NewsHomeScreen extends ConsumerStatefulWidget {
  const NewsHomeScreen({super.key});

  @override
  ConsumerState<NewsHomeScreen> createState() => _NewsHomeScreenState();
}

class _NewsHomeScreenState extends ConsumerState<NewsHomeScreen> {
  NewsCategoryGroup? _category;

  NewsQuery get _query => (
    search: null,
    category: _category?.id,
    sort: NewsSort.newest,
    range: NewsRange.all,
    kind: NewsKind.all,
    source: null,
    custom: null,
  );

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final feed = ref.watch(newsFeedProvider(_query));
    final categories = ref.watch(newsCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: Space.s5,
        title: Text(
          'اخبار',
          style: context.text.h2.copyWith(color: c.textPrimary),
        ),
        actions: [
          _BarIcon(
            icon: Icons.search_rounded,
            tooltip: 'جستجو',
            onTap: () => context.push(Routes.newsSearch),
          ),
          _BarIcon(
            icon: Icons.trending_up_rounded,
            tooltip: 'اخبار پربازدید',
            onTap: () => context.push(Routes.newsTrending),
          ),
          _BarIcon(
            icon: Icons.bookmark_border_rounded,
            tooltip: 'اخبار ذخیره‌شده',
            onTap: () => context.push(Routes.newsSaved),
          ),
          const SizedBox(width: Space.s3),
        ],
      ),
      body: Column(
        children: [
          categories.maybeWhen(
            data: (groups) => Padding(
              padding: const EdgeInsets.only(bottom: Space.s3),
              child: NewsCategoryTabs(
                categories: groups,
                selectedId: _category?.id,
                onSelected: (g) => setState(() => _category = g),
              ),
            ),
            orElse: () => const SizedBox(height: Space.s3),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(newsFeedProvider(_query));
                ref.invalidate(newsCategoriesProvider);
                await ref.read(newsFeedProvider(_query).future);
              },
              child: NewsAsync(
                value: feed,
                skeleton: const ArticleListSkeleton(featured: true),
                onRetry: () => ref.invalidate(newsFeedProvider(_query)),
                builder: (context, items) => items.isEmpty
                    ? ListView(
                        children: [
                          const SizedBox(height: Space.s12),
                          EmptyState(
                            key: const Key('news.home.empty'),
                            icon: Icons.newspaper_outlined,
                            title: 'خبری با این مشخصات پیدا نشد.',
                            message:
                                'فیلترها را تغییر دهید یا عبارت دیگری جستجو کنید.',
                            actionLabel: _category == null
                                ? null
                                : 'پاک کردن فیلترها',
                            onAction: _category == null
                                ? null
                                : () => setState(() => _category = null),
                          ),
                        ],
                      )
                    : _Feed(items: items),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Feed extends StatelessWidget {
  const _Feed({required this.items});

  final List<NewsArticle> items;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final featured = items.first;
    final rest = items.skip(1).toList();

    return ListView(
      key: const Key('news.home.list'),
      padding: const EdgeInsets.only(bottom: Space.s8),
      children: [
        PagePadding(
          child: FeaturedArticleCard(
            article: featured,
            onTap: () => context.push(Routes.newsDetails(featured.slug)),
          ),
        ),
        const SizedBox(height: Space.s5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.page),
          child: Divider(color: c.divider, height: 1),
        ),
        SectionHeader(
          title: 'آخرین اخبار',
          onSeeAll: () => context.push(newsSearchResultsPath()),
        ),
        for (final a in rest)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Space.page,
              Space.s1,
              Space.page,
              Space.s3,
            ),
            child: CompactArticleCard(
              article: a,
              onTap: () => context.push(Routes.newsDetails(a.slug)),
            ),
          ),
      ],
    );
  }
}

/// 36×36 tinted square from the deck, expanded to a 44×44 hit box.
class _BarIcon extends StatelessWidget {
  const _BarIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.sm + 2),
        child: SizedBox(
          width: Layout.minTapTarget,
          height: Layout.minTapTarget,
          child: Center(
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: c.surfaceSecondary,
                borderRadius: BorderRadius.circular(Radii.sm + 2),
              ),
              child: Icon(icon, size: 17, color: c.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}
