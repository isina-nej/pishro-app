import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_badge.dart';
import '../../../../shared/widgets/states.dart';

import '../../../../core/utils/formatters.dart';
import '../../data/community_repository.dart';

class FollowingFeedScreen extends ConsumerWidget {
  const FollowingFeedScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final feed = ref.watch(followingFeedProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'دنبال‌شده‌ها',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: feed.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ErrorStateView(
          onRetry: () => ref.invalidate(followingFeedProvider),
        ),
        data: (items) => items.isEmpty
            ? EmptyState(
                title: 'هنوز کسی را دنبال نکرده‌اید',
                actionLabel: 'تحلیلگران',
                onAction: () => context.push(Routes.recommendedAnalysts),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(Space.page),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: Space.s3),
                itemBuilder: (_, i) {
                  final a = items[i];
                  return PishroCard(
                    onTap: () => context.push(Routes.analysisDetails(a.id)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (a.isNew)
                          const PishroBadge(
                            label: 'جدید',
                            tone: PishroBadgeTone.info,
                            icon: Icons.fiber_new_rounded,
                          ),
                        Text(
                          a.title,
                          style: context.text.bodyMedium.copyWith(
                            color: c.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${a.author.displayName} · ${Fmt.relative(a.publishedAt)}',
                          style: context.text.caption.copyWith(
                            color: c.textMuted,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
