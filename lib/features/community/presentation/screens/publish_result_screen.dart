import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/pishro_button.dart';

import '../../data/community_models.dart';
import '../../data/community_repository.dart';

class PublishResultScreen extends ConsumerWidget {
  const PublishResultScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final out = ref.watch(publishOutcomeProvider);
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
            Icon(Icons.hourglass_top_rounded, size: 48, color: c.warning),
            const SizedBox(height: Space.s4),
            Text(
              out?.status == PublishStatus.pendingModeration
                  ? 'در انتظار بررسی'
                  : (out?.title ?? 'ارسال شد'),
              textAlign: TextAlign.center,
              style: context.text.h3.copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: Space.s2),
            Text(
              'تحلیل پس از تأیید ناظر منتشر می‌شود.',
              textAlign: TextAlign.center,
              style: context.text.bodySmall.copyWith(color: c.textSecondary),
            ),
            if (out?.analysisId != null)
              Text(
                'شناسه: ${out!.analysisId}',
                style: context.text.caption.copyWith(color: c.textMuted),
              ),
            const Spacer(),
            PishroButton(
              label: 'بازگشت به جامعه',
              onPressed: () => context.go(Routes.community),
            ),
          ],
        ),
      ),
    );
  }
}
