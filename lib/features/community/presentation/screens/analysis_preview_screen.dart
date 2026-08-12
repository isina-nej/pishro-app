import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/pishro_badge.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/community_repository.dart';

/// Screen/Community/AnalysisPreview — بدون آمار جعلی.
class AnalysisPreviewScreen extends ConsumerWidget {
  const AnalysisPreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final d = ref.watch(analysisDraftProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'پیش‌نمایش تحلیل',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          const NoticeBanner(
            message: 'این صفحه پیش‌نمایش است و هنوز منتشر نشده است.',
            tone: NoticeTone.info,
          ),
          const SizedBox(height: Space.s4),
          Text(
            'شما (نام کاربر نمونه)',
            style: context.text.caption.copyWith(color: c.textMuted),
          ),
          const SizedBox(height: Space.s2),
          Text(
            d.title.isEmpty ? 'بدون عنوان' : d.title,
            style: context.text.h3.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: Space.s2),
          Wrap(
            spacing: Space.s2,
            runSpacing: Space.s2,
            children: [
              PishroBadge(label: d.asset?.symbol ?? '—'),
              PishroBadge(label: d.kind.label),
              PishroBadge(label: d.timeframe.label),
              RiskBadge(d.risk),
            ],
          ),
          const SizedBox(height: Space.s4),
          Text(
            d.summary.isEmpty
                ? 'متن نمونه پیش‌نمایش — بدون آمار تعامل جعلی.'
                : d.summary,
            style: context.text.bodySmall.copyWith(color: c.textSecondary),
          ),
          if (d.body.isNotEmpty) ...[
            const SizedBox(height: Space.s3),
            Text(
              d.body,
              style: context.text.bodySmall.copyWith(
                color: c.textSecondary,
                height: 1.8,
              ),
            ),
          ],
          if (d.invalidation.isNotEmpty) ...[
            const SizedBox(height: Space.s3),
            NoticeBanner(
              message: 'شرط بی‌اعتبارشدن: ${d.invalidation}',
              tone: NoticeTone.warning,
            ),
          ],
          const SizedBox(height: Space.s4),
          Text(
            'این محتوا دیدگاه نویسنده است و توصیه قطعی برای خرید یا فروش محسوب نمی‌شود.',
            style: context.text.caption.copyWith(color: c.textMuted),
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
                label: 'انتشار تحلیل',
                onPressed: () async {
                  final out = await ref
                      .read(communityRepositoryProvider)
                      .publish(d);
                  ref.read(publishOutcomeProvider.notifier).state = out;
                  if (context.mounted) context.go(Routes.publishResult);
                },
              ),
              const SizedBox(height: Space.s3),
              PishroButton(
                label: 'بازگشت و ویرایش',
                variant: PishroButtonVariant.secondary,
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
