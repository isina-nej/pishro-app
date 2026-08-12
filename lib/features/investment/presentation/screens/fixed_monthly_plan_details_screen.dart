import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/pishro_badge.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/investment_flow.dart';
import '../../data/investment_models.dart';
import '../../data/investment_repository.dart';
import 'dynamic_hold_plan_details_screen.dart';

/// Screen/Investment/FixedMonthlyPlanDetails.
class FixedMonthlyPlanDetailsScreen extends ConsumerWidget {
  const FixedMonthlyPlanDetailsScreen({super.key, this.id = ''});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(planProvider(id));
    return plan.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorStateView(onRetry: () => ref.invalidate(planProvider(id))),
      ),
      data: (p) {
        if (p == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyState(title: 'این طرح یافت نشد'),
          );
        }
        if (p.isDynamic) return DynamicHoldPlanDetailsScreen(id: id);
        return _FixedBody(plan: p);
      },
    );
  }
}

class _FixedBody extends ConsumerWidget {
  const _FixedBody({required this.plan});
  final InvestmentPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final rate = plan.monthlyRatePercent;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          plan.name,
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  plan.name,
                  style: context.text.h2.copyWith(color: c.textPrimary),
                ),
              ),
              RiskBadge(plan.riskLevel),
            ],
          ),
          const SizedBox(height: Space.s3),
          Text(
            rate == null
                ? kPerContract
                : 'برآورد ماهانه ${Fmt.fa(rate.toStringAsFixed(0))}٪ — تضمین نیست',
            style: context.text.bodyMedium.copyWith(color: c.textSecondary),
          ),
          if (plan.description != null) ...[
            const SizedBox(height: Space.s4),
            Text(
              plan.description!,
              style: context.text.bodySmall.copyWith(
                color: c.textSecondary,
                height: 1.8,
              ),
            ),
          ],
          const SizedBox(height: Space.s4),
          _Spec(
            label: 'نرخ اعلام‌شده طرح',
            value: rate == null
                ? kPerContract
                : '${Fmt.fa(rate.toStringAsFixed(0))}٪ ماهیانه',
          ),
          const _Spec(
            label: 'نحوه محاسبه',
            value: 'طبق شرایط و نحوه محاسبه قرارداد',
          ),
          _Spec(
            label: 'مدت طرح',
            value:
                '${Fmt.fa('${plan.minDurationMonths}')} تا ${Fmt.fa('${plan.maxDurationMonths}')} ماه',
          ),
          _Spec(
            label: 'حداقل / حداکثر مبلغ',
            value:
                '${Fmt.toman(plan.minAmount)} تا ${Fmt.toman(plan.maxAmount)}',
          ),
          const _Spec(label: 'شرایط برداشت', value: 'طبق شرایط قرارداد طرح'),
          const _Spec(label: 'احراز هویت موردنیاز', value: 'سطح پایه'),
          const SizedBox(height: Space.s4),
          Text(
            'این نرخ به‌تنهایی به معنای تضمین پرداخت یا نبود ریسک نیست.',
            style: context.text.caption.copyWith(color: c.textMuted),
          ),
          const SizedBox(height: Space.s4),
          Row(
            children: [
              Expanded(
                child: PishroButton(
                  label: 'محاسبه‌گر',
                  variant: PishroButtonVariant.ghost,
                  onPressed: () => context.push(Routes.calculator),
                ),
              ),
              Expanded(
                child: PishroButton(
                  label: 'مقایسه طرح‌ها',
                  variant: PishroButtonVariant.ghost,
                  onPressed: () => context.push(Routes.planComparison),
                ),
              ),
              Expanded(
                child: PishroButton(
                  label: 'قرارداد',
                  variant: PishroButtonVariant.ghost,
                  onPressed: () => context.push(Routes.terms),
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.s5),
          const NoticeBanner(
            message: 'اعداد برآورد است و تعهد سود قطعی ایجاد نمی‌کند.',
            tone: NoticeTone.warning,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.page),
          child: PishroButton(
            label: 'بررسی شرایط سرمایه‌گذاری',
            onPressed: () {
              ref.read(investmentFlowProvider.notifier).start(plan);
              context.push(Routes.amountEntry);
            },
          ),
        ),
      ),
    );
  }
}

/// A «برچسب … مقدار» row from the deck's plan spec table.
class _Spec extends StatelessWidget {
  const _Spec({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.s2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.text.caption.copyWith(color: c.textMuted)),
          const SizedBox(width: Space.s3),
          Expanded(
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
