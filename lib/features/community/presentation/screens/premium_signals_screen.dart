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
import '../../../../shared/widgets/states.dart';
import '../../data/community_repository.dart';

/// Screen/Community/PremiumSignals — «۰۹ · سیگنال‌های اشتراکی».
///
/// Gold stays on the badge only, never on the price or the body text.
class PremiumSignalsScreen extends ConsumerWidget {
  const PremiumSignalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final signals = ref.watch(signalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'سیگنال‌های اشتراکی',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: signals.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            ErrorStateView(onRetry: () => ref.invalidate(signalsProvider)),
        data: (items) => ListView(
          padding: const EdgeInsets.all(Space.page),
          children: [
            const NoticeBanner(
              message:
                  'محتوای اشتراکی دیدگاه شخصی تحلیلگر است، نه دستور معاملاتی '
                  'خودکار.',
              tone: NoticeTone.info,
            ),
            const SizedBox(height: Space.s4),
            if (items.isEmpty)
              const EmptyState(title: 'سیگنالی برای نمایش نیست')
            else
              for (final s in items) ...[
                PishroCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              s.provider.displayName,
                              style: context.text.bodyMedium.copyWith(
                                color: c.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (s.isSubscribed)
                            const PishroBadge(
                              label: 'مشترک هستید',
                              tone: PishroBadgeTone.success,
                              icon: Icons.check_rounded,
                            )
                          else
                            const PishroBadge(
                              label: 'اشتراکی',
                              tone: PishroBadgeTone.premium,
                              icon: Icons.workspace_premium_outlined,
                            ),
                        ],
                      ),
                      const SizedBox(height: Space.s2),
                      Text(
                        [
                          'پوشش: ${s.coverage}',
                          'نوع: ${s.cadence}',
                          if (s.horizon != null) 'بازه: ${s.horizon}',
                        ].join(' · '),
                        style: context.text.caption.copyWith(
                          color: c.textMuted,
                        ),
                      ),
                      if (!s.performanceDataAvailable) ...[
                        const SizedBox(height: Space.s3),
                        const NoticeBanner(
                          message: 'داده عملکرد تأییدشده در دسترس نیست.',
                          tone: NoticeTone.warning,
                        ),
                      ],
                      const SizedBox(height: Space.s3),
                      if (s.isSubscribed)
                        PishroButton(
                          label: 'مشاهده محتوا',
                          variant: PishroButtonVariant.secondary,
                          onPressed: () => context.push(
                            Routes.analystProfile(s.provider.id),
                          ),
                        )
                      else ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              Fmt.grouped(s.priceToman),
                              style: context.text.h3.copyWith(
                                color: c.textPrimary,
                              ),
                            ),
                            const SizedBox(width: Space.s2),
                            Text(
                              // Offers are billed monthly; the cadence field
                              // describes the content, not the billing period.
                              'تومان / ماهانه',
                              style: context.text.caption.copyWith(
                                color: c.textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Space.s3),
                        PishroButton(
                          label: 'مشاهده جزئیات',
                          variant: PishroButtonVariant.secondary,
                          onPressed: () => context.push(
                            Routes.analystProfile(s.provider.id),
                          ),
                        ),
                        if (!s.isEligible) ...[
                          const SizedBox(height: Space.s2),
                          Text(
                            'شرایط دریافت اشتراک را بررسی کنید',
                            style: context.text.caption.copyWith(
                              color: c.danger,
                            ),
                          ),
                        ],
                      ],
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
