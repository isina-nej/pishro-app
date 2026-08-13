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
import '../../data/investment_flow.dart';
import '../../data/investment_models.dart';

/// Screen/Investment/Success — بدون کانفتی / بدون ROI جعلی.
class InvestmentSuccessScreen extends ConsumerWidget {
  const InvestmentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final draft = ref.watch(investmentFlowProvider);
    final id = draft.orderId;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.page),
          child: Column(
            children: [
              const Spacer(),
              Icon(Icons.check_circle_rounded, size: 56, color: c.success),
              const SizedBox(height: Space.s4),
              Text(
                'درخواست با موفقیت ثبت شد',
                textAlign: TextAlign.center,
                style: context.text.h2.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: Space.s2),
              const PishroBadge(
                label: 'وضعیت فعال‌سازی: در انتظار',
                tone: PishroBadgeTone.warning,
                icon: Icons.hourglass_top_rounded,
              ),
              const SizedBox(height: Space.s5),
              PishroCard(
                child: Column(
                  children: [
                    _Row('طرح', draft.plan?.name ?? '—'),
                    _Row('مبلغ', Fmt.toman(draft.amount)),
                    _Row('تاریخ ثبت', Fmt.jalaliLong(DateTime.now())),
                    if (id != null && id.isNotEmpty)
                      _Row('شناسه سرمایه‌گذاری', Fmt.fa(id)),
                    const _Row('پرداخت بعدی', kPerContractSchedule),
                  ],
                ),
              ),
              const SizedBox(height: Space.s4),
              const NoticeBanner(
                message:
                    'فعال‌سازی پس از تأیید بک‌اند نمایش داده می‌شود. هیچ بازدهی تضمینی اعلام نشده است.',
                tone: NoticeTone.info,
              ),
              const SizedBox(height: Space.s3),
              Row(
                children: [
                  Expanded(
                    child: PishroButton(
                      label: 'مشاهده قرارداد',
                      variant: PishroButtonVariant.ghost,
                      onPressed: () => context.push(Routes.terms),
                    ),
                  ),
                  Expanded(
                    child: PishroButton(
                      label: 'مشاهده رسید',
                      variant: PishroButtonVariant.ghost,
                      // The receipt lives with the transaction record.
                      onPressed: id == null || id.isEmpty
                          ? null
                          : () => context.push(Routes.paymentSchedule(id)),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              PishroButton(
                label: 'مشاهده جزئیات سرمایه‌گذاری',
                onPressed: () => context.go(Routes.activeInvestments),
              ),
              const SizedBox(height: Space.s3),
              PishroButton(
                label: 'بازگشت به سرمایه‌گذاری‌ها',
                variant: PishroButtonVariant.secondary,
                onPressed: () => context.go(Routes.activeInvestments),
              ),
            ],
          ),
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
