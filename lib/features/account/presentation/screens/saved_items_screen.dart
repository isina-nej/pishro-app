import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_badge.dart';
import '../../../../shared/widgets/pishro_chip.dart';
import '../../../../shared/widgets/states.dart';
import '../../../news/data/news_repository.dart';

/// Screen/Account/SavedItems.
class SavedItemsScreen extends ConsumerStatefulWidget {
  const SavedItemsScreen({super.key});

  @override
  ConsumerState<SavedItemsScreen> createState() => _SavedItemsScreenState();
}

class _SavedItemsScreenState extends ConsumerState<SavedItemsScreen> {
  var _tab = 0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final saved = ref.watch(bookmarksProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ذخیره‌شده‌ها',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: Column(
        children: [
          PishroChipBar(
            labels: const ['همه', 'دوره‌ها', 'اخبار', 'تحلیل‌ها'],
            selectedIndex: _tab,
            onSelected: (i) => setState(() => _tab = i),
          ),
          Expanded(
            child: saved.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => ErrorStateView(
                onRetry: () => ref.invalidate(bookmarksProvider),
              ),
              data: (items) {
                if (_tab == 1 || _tab == 3) {
                  return const EmptyState(
                    title: 'موردی در این دسته نیست',
                    message: 'فعلاً فقط اخبار ذخیره‌شده از سرور می‌آید.',
                  );
                }
                if (items.isEmpty) {
                  return const EmptyState(title: 'هنوز موردی ذخیره نکرده‌اید');
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(Space.page),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: Space.s3),
                  itemBuilder: (_, i) {
                    final s = items[i];
                    return PishroCard(
                      onTap: () => context.push(Routes.newsDetails(s.slug)),
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
                          const SizedBox(height: Space.s2),
                          Row(
                            children: [
                              const PishroBadge(
                                label: 'خبر',
                                tone: PishroBadgeTone.info,
                              ),
                              const SizedBox(width: Space.s2),
                              Text(
                                s.savedAt == null
                                    ? 'ذخیره‌شده'
                                    : 'ذخیره: ${Fmt.relative(s.savedAt!)}',
                                style: context.text.caption.copyWith(
                                  color: c.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
