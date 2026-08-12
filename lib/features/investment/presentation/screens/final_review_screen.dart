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

/// Screen/Investment/FinalReview.
class FinalReviewScreen extends ConsumerWidget {
  const FinalReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final draft = ref.watch(investmentFlowProvider);
    final plan = draft.plan;
    if (plan == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(title: 'طرحی انتخاب نشده'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'بازبینی نهایی',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          PishroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        plan.name,
                        style: context.text.bodyMedium.copyWith(
                          color: c.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    RiskBadge(plan.riskLevel),
                  ],
                ),
                const SizedBox(height: Space.s3),
                _Row('مبلغ', Fmt.toman(draft.amount)),
                _Row('مدت', '${Fmt.fa('${draft.durationMonths}')} ماه'),
                _Row('منبع وجه', draft.funding.title),
                _Row(
                  'برآورد ماهانه',
                  draft.monthlyEstimate == null
                      ? kPerContract
                      : Fmt.toman(draft.monthlyEstimate!),
                ),
                _Row(
                  'برآورد کل',
                  draft.totalEstimate == null
                      ? kPerContract
                      : Fmt.toman(draft.totalEstimate!),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.s4),
          const NoticeBanner(
            message: 'ارسال درخواست سفارش ایجاد می‌کند، نه سرمایه‌گذاری فعال.',
            tone: NoticeTone.info,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.page),
          child: PishroButton(
            label: 'تأیید و ادامه',
            onPressed: () => context.push(Routes.contractConfirmation),
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
