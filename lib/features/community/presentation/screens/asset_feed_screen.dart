import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/states.dart';

import '../../data/community_repository.dart';

class AssetFeedScreen extends ConsumerWidget {
  const AssetFeedScreen({super.key, this.id = ''});
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final feed = ref.watch(assetFeedProvider(id.toUpperCase()));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تحلیل‌های $id',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: feed.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ErrorStateView(
          onRetry: () => ref.invalidate(assetFeedProvider(id.toUpperCase())),
        ),
        data: (items) => items.isEmpty
            ? const EmptyState(title: 'تحلیلی برای این دارایی نیست')
            : ListView.separated(
                padding: const EdgeInsets.all(Space.page),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: Space.s3),
                itemBuilder: (_, i) {
                  final a = items[i];
                  return PishroCard(
                    onTap: () => context.push(Routes.analysisDetails(a.id)),
                    child: Text(
                      a.title,
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
