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

class AnalysisPreviewScreen extends ConsumerWidget {
  const AnalysisPreviewScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final d = ref.watch(analysisDraftProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'پیش‌نمایش',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          Text(
            d.title.isEmpty ? 'بدون عنوان' : d.title,
            style: context.text.h3.copyWith(color: c.textPrimary),
          ),
          Text(
            '${d.asset?.symbol ?? '—'} · ${d.kind.label} · ${d.timeframe.label}',
            style: context.text.caption.copyWith(color: c.textMuted),
          ),
          const SizedBox(height: Space.s3),
          RiskBadge(d.risk),
          const SizedBox(height: Space.s4),
          Text(
            d.summary.isEmpty ? 'خلاصه‌ای نوشته نشده' : d.summary,
            style: context.text.bodySmall.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: Space.s3),
          Text(
            d.body,
            style: context.text.bodySmall.copyWith(
              color: c.textSecondary,
              height: 1.8,
            ),
          ),
          if (d.invalidation.isNotEmpty) ...[
            const SizedBox(height: Space.s3),
            NoticeBanner(
              message: 'شرط بی‌اعتبار شدن: ${d.invalidation}',
              tone: NoticeTone.warning,
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.page),
          child: PishroButton(
            label: 'ارسال برای بررسی',
            onPressed: () async {
              final out = await ref
                  .read(communityRepositoryProvider)
                  .publish(d);
              ref.read(publishOutcomeProvider.notifier).state = out;
              if (context.mounted) context.go(Routes.publishResult);
            },
          ),
        ),
      ),
    );
  }
}
