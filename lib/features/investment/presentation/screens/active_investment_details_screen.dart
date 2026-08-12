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
import '../../data/investment_models.dart';
import '../../data/investment_repository.dart';

/// Screen/Investment/ActiveInvestmentDetails — بدون طرح جعلی.
class ActiveInvestmentDetailsScreen extends ConsumerWidget {
  const ActiveInvestmentDetailsScreen({super.key, this.id = ''});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final tx = ref.watch(transactionProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'جزئیات سرمایه‌گذاری',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: tx.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ErrorStateView(
          onRetry: () => ref.invalidate(transactionProvider(id)),
        ),
        data: (t) {
          if (t == null) {
            return const EmptyState(title: 'این رکورد یافت نشد');
          }
          return ListView(
            padding: const EdgeInsets.all(Space.page),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t.title,
                      style: context.text.h3.copyWith(color: c.textPrimary),
                    ),
                  ),
                  PishroBadge(
                    label: t.investmentStatusLabel,
                    tone: switch (t.status) {
                      TxStatus.success => PishroBadgeTone.success,
                      TxStatus.pending => PishroBadgeTone.warning,
                      TxStatus.failed => PishroBadgeTone.danger,
                    },
                    icon: switch (t.status) {
                      TxStatus.success => Icons.check_rounded,
                      TxStatus.pending => Icons.hourglass_top_rounded,
                      TxStatus.failed => Icons.error_outline_rounded,
                    },
                  ),
                ],
              ),
              const SizedBox(height: Space.s5),
              PishroCard(
                child: Column(
                  children: [
                    _Row('مبلغ سرمایه‌گذاری', Fmt.toman(t.amount)),
                    _Row('تاریخ فعال‌سازی', Fmt.jalaliLong(t.createdAt)),
                    const _Row('نرخ اعلام‌شده', kPerContract),
                    const _Row('دریافتی تاکنون', kSampleValue),
                    const _Row('پرداخت بعدی', kPerContractSchedule),
                    if (t.refNumber != null) _Row('شناسه پیگیری', t.refNumber!),
                  ],
                ),
              ),
              const SizedBox(height: Space.s4),
              const NoticeBanner(
                message:
                    'API طرح، مدت یا جدول اقساط را روی تراکنش نمی‌فرستد؛ جزئیات فقط طبق داده موجود است و درصد اختراعی نمایش داده نمی‌شود.',
                tone: NoticeTone.info,
              ),
              const SizedBox(height: Space.s5),
              PishroButton(
                label: 'مشاهده برنامه پرداخت کامل',
                onPressed: () => context.push(Routes.paymentSchedule(id)),
              ),
              const SizedBox(height: Space.s3),
              PishroButton(
                label: 'قرارداد — نسخه ۱٫۲',
                variant: PishroButtonVariant.secondary,
                onPressed: () => context.push(Routes.terms),
              ),
              const SizedBox(height: Space.s3),
              PishroButton(
                label: 'سند ریسک طرح',
                variant: PishroButtonVariant.ghost,
                onPressed: () => context.push(Routes.riskDisclosure),
              ),
              const SizedBox(height: Space.s4),
              Text(
                'آخرین به‌روزرسانی داده: ${Fmt.relative(DateTime.now())}',
                style: context.text.caption.copyWith(color: c.textMuted),
              ),
            ],
          );
        },
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
      padding: const EdgeInsets.only(bottom: Space.s3),
      child: Row(
        children: [
          Text(label, style: context.text.caption.copyWith(color: c.textMuted)),
          const Spacer(),
          Text(
            value,
            style: context.text.bodySmall.copyWith(
              color: c.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
