import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/states.dart';

import '../../../../core/utils/formatters.dart';
import '../../data/community_repository.dart';

class PremiumSignalsScreen extends ConsumerWidget {
  const PremiumSignalsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final signals = ref.watch(signalsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'سیگنال‌های ویژه',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: signals.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            ErrorStateView(onRetry: () => ref.invalidate(signalsProvider)),
        data: (items) => ListView.separated(
          padding: const EdgeInsets.all(Space.page),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: Space.s3),
          itemBuilder: (_, i) {
            final s = items[i];
            return PishroCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.provider.displayName,
                    style: context.text.bodyMedium.copyWith(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${s.coverage} · ${s.cadence}',
                    style: context.text.caption.copyWith(color: c.textMuted),
                  ),
                  const SizedBox(height: Space.s2),
                  Text(
                    Fmt.toman(s.priceToman),
                    style: context.text.bodySmall.copyWith(
                      color: c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: Space.s2),
                  const NoticeBanner(
                    message: 'داده عملکرد تأییدشده در دسترس نیست.',
                    tone: NoticeTone.warning,
                  ),
                  if (!s.isEligible)
                    Text(
                      'شرایط دریافت اشتراک را بررسی کنید',
                      style: context.text.caption.copyWith(color: c.danger),
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
