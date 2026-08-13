import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/pishro_chip.dart';
import '../../data/news_models.dart';
import '../../data/news_repository.dart';
import '../../news_routes.dart';

/// Screen/News/Filters — مرتب‌سازی + بازه زمانی.
class NewsFiltersScreen extends ConsumerWidget {
  const NewsFiltersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final q = ref.watch(newsQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'فیلتر اخبار',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          Text(
            'مرتب‌سازی',
            style: context.text.bodySmall.copyWith(
              color: c.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: Space.s3),
          Wrap(
            spacing: Space.s2,
            runSpacing: Space.s2,
            children: [
              for (final s in NewsSort.values)
                PishroChip(
                  label: s.label,
                  selected: q.sort == s,
                  onTap: () => ref.read(newsQueryProvider.notifier).state = (
                    search: q.search,
                    category: q.category,
                    sort: s,
                    range: q.range,
                  ),
                ),
            ],
          ),
          const SizedBox(height: Space.s6),
          Text(
            'بازه زمانی',
            style: context.text.bodySmall.copyWith(
              color: c.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: Space.s3),
          Wrap(
            spacing: Space.s2,
            runSpacing: Space.s2,
            children: [
              for (final r in NewsRange.values)
                PishroChip(
                  label: r.spanLabel,
                  selected: q.range == r,
                  onTap: () => ref.read(newsQueryProvider.notifier).state = (
                    search: q.search,
                    category: q.category,
                    sort: q.sort,
                    range: r,
                  ),
                ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.page),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PishroButton(
                label: 'اعمال فیلتر',
                onPressed: () => context.go(newsSearchResultsPath()),
              ),
              const SizedBox(height: Space.s3),
              PishroButton(
                label: 'حذف فیلترها',
                variant: PishroButtonVariant.secondary,
                onPressed: () {
                  ref.read(newsQueryProvider.notifier).state = (
                    search: q.search,
                    category: q.category,
                    sort: NewsSort.newest,
                    range: NewsRange.all,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
