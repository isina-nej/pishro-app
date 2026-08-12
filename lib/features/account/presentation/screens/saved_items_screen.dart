import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/states.dart';

import '../../../news/data/news_repository.dart';

class SavedItemsScreen extends ConsumerWidget {
  const SavedItemsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final saved = ref.watch(bookmarksProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ذخیره‌شده‌ها',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: saved.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            ErrorStateView(onRetry: () => ref.invalidate(bookmarksProvider)),
        data: (items) => items.isEmpty
            ? const EmptyState(title: 'مورد ذخیره‌شده‌ای نیست')
            : ListView.separated(
                padding: const EdgeInsets.all(Space.page),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: Space.s3),
                itemBuilder: (_, i) {
                  final s = items[i];
                  return PishroCard(
                    onTap: () => context.push(Routes.newsDetails(s.slug)),
                    child: Text(
                      s.title,
                      style: context.text.bodyMedium.copyWith(
                        color: c.textPrimary,
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
