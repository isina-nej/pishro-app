import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/news_repository.dart';
import '../widgets/article_card.dart';

/// Screen/News/SearchResults.
class NewsSearchResultsScreen extends ConsumerWidget {
  const NewsSearchResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final query = ref.watch(newsQueryProvider);
    final feed = ref.watch(newsFeedProvider(query));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          query.search?.isNotEmpty == true ? query.search! : 'نتایج اخبار',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
        actions: [
          IconButton(
            tooltip: 'فیلترها',
            onPressed: () => context.push(Routes.newsFilters),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: NewsAsync(
        value: feed,
        onRetry: () => ref.invalidate(newsFeedProvider(query)),
        builder: (context, items) {
          if (items.isEmpty) {
            return EmptyState(
              title: 'خبری مطابق جستجو پیدا نشد',
              message: 'فیلترها را تغییر دهید یا عبارت دیگری جستجو کنید.',
              icon: Icons.search_off_rounded,
              actionLabel: 'تغییر فیلتر',
              onAction: () => context.push(Routes.newsFilters),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(Space.page),
            itemCount: items.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: Space.s3),
            itemBuilder: (context, i) {
              if (i == 0) {
                return Text(
                  '${Fmt.fa('${items.length}')} خبر',
                  style: context.text.caption.copyWith(color: c.textMuted),
                );
              }
              final a = items[i - 1];
              return CompactArticleCard(
                article: a,
                onTap: () => context.push(Routes.newsDetails(a.slug)),
              );
            },
          );
        },
      ),
    );
  }
}
