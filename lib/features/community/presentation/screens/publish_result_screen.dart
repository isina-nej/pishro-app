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
import '../../../../shared/widgets/pishro_button.dart';
import '../../data/community_models.dart';
import '../../data/community_repository.dart';

/// Screen/Community/PublishResult — pending ≠ failed.
class PublishResultScreen extends ConsumerWidget {
  const PublishResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final out = ref.watch(publishOutcomeProvider);
    final status = out?.status ?? PublishStatus.pendingModeration;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'نتیجه انتشار',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(Space.page),
        child: Column(
          children: [
            const Spacer(),
            Icon(
              switch (status) {
                PublishStatus.published => Icons.check_circle_rounded,
                PublishStatus.pendingModeration => Icons.hourglass_top_rounded,
                PublishStatus.failed => Icons.error_outline_rounded,
              },
              size: 56,
              color: switch (status) {
                PublishStatus.published => c.success,
                PublishStatus.pendingModeration => c.warning,
                PublishStatus.failed => c.danger,
              },
            ),
            const SizedBox(height: Space.s4),
            Text(
              switch (status) {
                PublishStatus.published => 'تحلیل منتشر شد',
                PublishStatus.pendingModeration => 'انتشار در انتظار بررسی',
                PublishStatus.failed => 'انتشار تحلیل ناموفق بود',
              },
              textAlign: TextAlign.center,
              style: context.text.h2.copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: Space.s2),
            Text(
              switch (status) {
                PublishStatus.published =>
                  'تحلیل شما در جامعه قابل مشاهده است.',
                PublishStatus.pendingModeration =>
                  'تحلیل پس از تأیید ناظر منتشر می‌شود. در انتظار بررسی با ناموفق یکی نیست.',
                PublishStatus.failed =>
                  'ارسال انجام نشد. می‌توانید دوباره از پیش‌نمایش تلاش کنید.',
              },
              textAlign: TextAlign.center,
              style: context.text.bodySmall.copyWith(color: c.textSecondary),
            ),
            if (out != null) ...[
              const SizedBox(height: Space.s5),
              PishroCard(
                child: Column(
                  children: [
                    _Row('عنوان', out.title.isEmpty ? '—' : out.title),
                    _Row(
                      'زمان انتشار',
                      out.publishedAt == null
                          ? 'اکنون'
                          : Fmt.relative(out.publishedAt!),
                    ),
                    _Row('نمایانی', out.visibility.label),
                    if (out.analysisId != null)
                      _Row('شناسه تحلیل', out.analysisId!),
                    Row(
                      children: [
                        Text(
                          'وضعیت',
                          style: context.text.caption.copyWith(
                            color: c.textMuted,
                          ),
                        ),
                        const Spacer(),
                        PishroBadge(
                          label: switch (status) {
                            PublishStatus.published => 'منتشرشده',
                            PublishStatus.pendingModeration =>
                              'در انتظار بررسی',
                            PublishStatus.failed => 'ناموفق',
                          },
                          tone: switch (status) {
                            PublishStatus.published => PishroBadgeTone.success,
                            PublishStatus.pendingModeration =>
                              PishroBadgeTone.warning,
                            PublishStatus.failed => PishroBadgeTone.danger,
                          },
                          icon: switch (status) {
                            PublishStatus.published => Icons.check_rounded,
                            PublishStatus.pendingModeration =>
                              Icons.hourglass_top_rounded,
                            PublishStatus.failed => Icons.error_outline_rounded,
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const Spacer(),
            if (status == PublishStatus.published)
              PishroButton(
                label: 'مشاهده تحلیل',
                onPressed: out?.analysisId == null
                    ? () => context.go(Routes.community)
                    : () =>
                          context.go(Routes.analysisDetails(out!.analysisId!)),
              ),
            if (status == PublishStatus.failed)
              PishroButton(
                label: 'بازگشت به پیش‌نمایش',
                onPressed: () => context.go(Routes.analysisPreview),
              ),
            if (status == PublishStatus.pendingModeration)
              PishroButton(
                label: 'بازگشت به جامعه',
                onPressed: () => context.go(Routes.community),
              ),
            const SizedBox(height: Space.s3),
            PishroButton(
              label: 'ایجاد تحلیل دیگر',
              variant: PishroButtonVariant.secondary,
              onPressed: () {
                ref.read(analysisDraftProvider.notifier).reset();
                context.go(Routes.createAnalysis);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.s2),
      child: Row(
        children: [
          Text(label, style: context.text.caption.copyWith(color: c.textMuted)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: context.text.bodySmall.copyWith(
                color: c.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
