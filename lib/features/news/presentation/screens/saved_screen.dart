import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/news_repository.dart';
import '../widgets/article_card.dart';

/// Screen/News/Saved.
class NewsSavedScreen extends ConsumerWidget {
  const NewsSavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final saved = ref.watch(bookmarksProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'اخبار ذخیره‌شده',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: NewsAsync(
        value: saved,
        onRetry: () => ref.invalidate(bookmarksProvider),
        builder: (context, items) {
          if (items.isEmpty) {
            return EmptyState(
              title: 'هنوز خبری ذخیره نکرده‌اید',
              message:
                  'با انتخاب نشان ذخیره، خبرها را برای مطالعه بعدی نگه دارید.',
              actionLabel: 'مشاهده اخبار',
              onAction: () => context.go(Routes.news),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(Space.page),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: Space.s3),
            itemBuilder: (_, i) {
              final s = items[i];
              return PishroCard(
                onTap: () => context.push(Routes.newsDetails(s.slug)),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.bodyMedium.copyWith(
                              color: c.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: Space.s1),
                          Text(
                            [
                              if (s.category != null) s.category!,
                              if (s.savedAt != null) Fmt.relative(s.savedAt!),
                            ].join(' · '),
                            style: context.text.caption.copyWith(
                              color: c.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'حذف از ذخیره‌ها',
                      onPressed: () =>
                          ref.read(bookmarksProvider.notifier).removeSaved(s),
                      icon: Icon(
                        Icons.bookmark_rounded,
                        color: c.actionPrimary,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
