import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/states.dart';

import '../../../../core/utils/formatters.dart';
import '../../data/community_repository.dart';

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
          'امتیاز تحلیلگر',
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
              '${Fmt.fa(s.average.toStringAsFixed(1))} از ۵ · ${Fmt.fa('${s.reviewCount}')} نظر',
              style: context.text.h3.copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: Space.s4),
            for (final cat in s.categories) ...[
              Text(
                cat.label,
                style: context.text.caption.copyWith(color: c.textMuted),
              ),
              PishroProgress(value: cat.value, showPercent: false),
              const SizedBox(height: Space.s3),
            ],
            const NoticeBanner(
              message: 'معیار میزان سوددهی وجود ندارد.',
              tone: NoticeTone.info,
            ),
            const SizedBox(height: Space.s4),
            for (final r in s.reviews) ...[
              PishroCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${r.authorName} · ${Fmt.fa('${r.stars}')} ستاره',
                      style: context.text.bodySmall.copyWith(
                        color: c.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
