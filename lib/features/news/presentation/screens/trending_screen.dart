import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/news_models.dart';
import '../../data/news_repository.dart';
import '../widgets/article_card.dart';
import '../widgets/category_tabs.dart';

/// Screen/News/Trending — «۰۲ · پربازدید».
///
/// `GET /news` has no trending endpoint and only orders by `publishedAt`, so
/// the ranking is a client-side view-count sort over the loaded page. The
/// footnote the deck puts at the bottom says exactly that.
class TrendingScreen extends ConsumerStatefulWidget {
  const TrendingScreen({super.key});

  @override
  ConsumerState<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends ConsumerState<TrendingScreen> {
  var _range = NewsRange.today;

  static const _ranges = [NewsRange.today, NewsRange.week, NewsRange.month];

  NewsQuery get _query =>
      (search: null, category: null, sort: NewsSort.mostViewed, range: _range);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final feed = ref.watch(newsFeedProvider(_query));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'اخبار پربازدید',
          style: context.text.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: c.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Space.page,
              Space.s1,
              Space.page,
              Space.s3,
            ),
            child: SegmentedPills<NewsRange>(
              expanded: true,
              values: _ranges,
              labelOf: (r) => r.label,
              selected: _range,
              onSelected: (r) => setState(() => _range = r),
            ),
          ),
          Expanded(
            child: NewsAsync(
              value: feed,
              onRetry: () => ref.invalidate(newsFeedProvider(_query)),
              builder: (context, items) => items.isEmpty
                  ? const EmptyState(
                      icon: Icons.trending_up_rounded,
                      title: 'خبری با این مشخصات پیدا نشد.',
                      message: 'بازه زمانی دیگری را انتخاب کنید.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Space.page,
                      ),
                      itemCount: items.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: Space.s2 + 2),
                      itemBuilder: (context, i) => TrendingArticleCard(
                        article: items[i],
                        rank: i + 1,
                        onTap: () =>
                            context.push(Routes.newsDetails(items[i].slug)),
                      ),
                    ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.page,
                Space.s2 + 2,
                Space.page,
                Space.s5,
              ),
              child: Text(
                'ترتیب بر اساس بازدید همین فهرست محاسبه شده و مرتب‌سازی سراسری از سرور تأمین نشده',
                textAlign: TextAlign.center,
                style: context.text.micro.copyWith(color: c.textMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
