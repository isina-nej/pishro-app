import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/states.dart';

import '../../../../core/utils/formatters.dart';
import '../../data/community_repository.dart';

class RecommendedAnalystsScreen extends ConsumerWidget {
  const RecommendedAnalystsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final list = ref.watch(recommendedAnalystsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تحلیلگران پیشنهادی',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: list.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ErrorStateView(
          onRetry: () => ref.invalidate(recommendedAnalystsProvider),
        ),
        data: (items) => ListView(
          padding: const EdgeInsets.all(Space.page),
          children: [
            Text(
              'این پیشنهادها بر اساس علایق، فعالیت و تنظیمات شما نمایش داده '
              'می‌شوند.',
              style: context.text.caption.copyWith(color: c.textMuted),
            ),
            const SizedBox(height: Space.s4),
            for (final a in items) ...[
              PishroCard(
                onTap: () => context.push(Routes.analystProfile(a.id)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.displayName,
                      style: context.text.bodyMedium.copyWith(
                        color: c.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: Space.s1),
                    Text(
                      '${a.specialty} · ${Fmt.fa('${a.publishedCount}')} تحلیل منتشرشده',
                      style: context.text.caption.copyWith(color: c.textMuted),
                    ),
                    const SizedBox(height: Space.s2),
                    Row(
                      children: [
                        Text(
                          '★ ${Fmt.fa(a.rating.toStringAsFixed(1))}',
                          style: context.text.bodySmall.copyWith(
                            color: c.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: Space.s2),
                        Text(
                          '(${Fmt.fa('${a.reviewCount}')} نظر)',
                          style: context.text.caption.copyWith(
                            color: c.textMuted,
                          ),
                        ),
                        const Spacer(),
                        PishroButton(
                          label: a.isFollowing ? 'لغو دنبال' : 'دنبال کردن',
                          variant: PishroButtonVariant.ghost,
                          onPressed: () async {
                            await ref
                                .read(communityRepositoryProvider)
                                .toggleFollow(a.id);
                            ref.invalidate(recommendedAnalystsProvider);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Space.s3),
            ],
          ],
        ),
      ),
    );
  }
}
