import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_badge.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/community_repository.dart';

/// Screen/Community/AnalystRatings — بدون معیار سوددهی.
class AnalystRatingsScreen extends ConsumerWidget {
  const AnalystRatingsScreen({super.key, this.id = ''});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final ratings = ref.watch(analystRatingsProvider(id));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'امتیازها و نظرات',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: ratings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ErrorStateView(
          onRetry: () => ref.invalidate(analystRatingsProvider(id)),
        ),
        data: (s) => ListView(
          padding: const EdgeInsets.all(Space.page),
          children: [
            Text(
              Fmt.fa(s.average.toStringAsFixed(1)),
              style: context.text.h2.copyWith(color: c.textPrimary),
            ),
            Row(
              children: [
                Icon(Icons.star_rounded, size: 18, color: c.warning),
                const SizedBox(width: 4),
                Text(
                  '${Fmt.fa('${s.reviewCount}')} نظر',
                  style: context.text.caption.copyWith(color: c.textMuted),
                ),
              ],
            ),
            const SizedBox(height: Space.s5),
            for (final cat in s.categories) ...[
              Text(
                cat.label,
                style: context.text.caption.copyWith(color: c.textMuted),
              ),
              PishroProgress(value: cat.value, showPercent: false),
              const SizedBox(height: Space.s3),
            ],
            const NoticeBanner(
              message:
                  'داده عملکرد تأییدشده برای این رتبه‌بندی در دسترس نیست. رتبه‌بندی بر اساس امتیاز و مشارکت کاربران است و معیار میزان سوددهی وجود ندارد.',
              tone: NoticeTone.info,
            ),
            const SizedBox(height: Space.s4),
            for (final r in s.reviews) ...[
              PishroCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            r.authorName,
                            style: context.text.bodySmall.copyWith(
                              color: c.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (r.isVerifiedSubscriber)
                          const PishroBadge(
                            label: 'مشترک تأییدشده',
                            tone: PishroBadgeTone.success,
                            icon: Icons.verified_outlined,
                          ),
                      ],
                    ),
                    const SizedBox(height: Space.s1),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 14, color: c.warning),
                        const SizedBox(width: 4),
                        Text(
                          Fmt.fa('${r.stars}'),
                          style: context.text.caption.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Space.s2),
                    Text(
                      r.body,
                      style: context.text.bodySmall.copyWith(
                        color: c.textSecondary,
                      ),
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
