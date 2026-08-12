import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_badge.dart';
import '../../data/investment_models.dart';

class PlanTile extends StatelessWidget {
  const PlanTile({super.key, required this.plan, this.onTap});

  final InvestmentPlan plan;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final rate = plan.monthlyRatePercent;
    return PishroCard(
      onTap: onTap,
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
          const SizedBox(height: Space.s2),
          Text(
            plan.isDynamic
                ? 'بازده: $kPerContract'
                : (rate == null
                      ? kSampleValue
                      : 'برآورد ماهانه ${Fmt.fa(rate.toStringAsFixed(0))}٪'),
            style: context.text.bodySmall.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: Space.s3),
          _Spec(label: 'حداقل مبلغ', value: Fmt.toman(plan.minAmount)),
          const SizedBox(height: Space.s1),
          _Spec(
            // A hold plan states a hold period, a monthly plan a term.
            label: plan.isDynamic ? 'دوره هولد' : 'مدت طرح',
            value:
                '${Fmt.fa('${plan.minDurationMonths}')} تا ${Fmt.fa('${plan.maxDurationMonths}')} ماه',
          ),
        ],
      ),
    );
  }
}

class _Spec extends StatelessWidget {
  const _Spec({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        Text(label, style: context.text.caption.copyWith(color: c.textMuted)),
        const Spacer(),
        Text(
          value,
          style: context.text.caption.copyWith(
            color: c.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
