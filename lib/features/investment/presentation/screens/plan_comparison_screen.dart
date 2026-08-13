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

/// Screen/Investment/PlanComparison — «۰۵ · مقایسه طرح‌ها».
///
/// Row-per-attribute table, exactly the six the deck lists. No «بهترین انتخاب»
/// badge and no invented percentage: a plan without a stated rate shows
/// [kPerContract].
class PlanComparisonScreen extends ConsumerWidget {
  const PlanComparisonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final plans = ref.watch(plansProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'مقایسه طرح‌ها',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: plans.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(Space.page),
          child: Skeleton.box(height: 260),
        ),
        error: (_, __) =>
            ErrorStateView(onRetry: () => ref.invalidate(plansProvider)),
        data: (items) {
          if (items.length < 2) {
            return const EmptyState(title: 'برای مقایسه حداقل دو طرح لازم است');
          }
          // The deck compares two plans side by side; more than that stops
          // fitting a phone column, so compare the first two.
          final compared = items.take(2).toList();

          return ListView(
            padding: const EdgeInsets.all(Space.page),
            children: [
              PishroCard(
                child: Column(
                  children: [
                    _HeaderRow(plans: compared),
                    for (final row in _rows(compared)) ...[
                      Divider(height: Space.s5, color: c.borderDefault),
                      _AttributeRow(label: row.label, cells: row.cells),
                    ],
                    Divider(height: Space.s5, color: c.borderDefault),
                    _RiskRow(plans: compared),
                  ],
                ),
              ),
              const SizedBox(height: Space.s4),
              const NoticeBanner(
                message:
                    'مقایسه بر اساس شرایط اعلام‌شده طرح است و بازده تضمین‌شده '
                    'محسوب نمی‌شود.',
                tone: NoticeTone.info,
              ),
              const SizedBox(height: Space.s4),
              for (final p in compared) ...[
                PishroButton(
                  label: p.isDynamic
                      ? 'مشاهده جزئیات داینامیک'
                      : 'مشاهده جزئیات ماهیانه',
                  variant: PishroButtonVariant.secondary,
                  onPressed: () => context.push(Routes.planDetails(p.id)),
                ),
                const SizedBox(height: Space.s3),
              ],
            ],
          );
        },
      ),
    );
  }

  /// The deck's attribute rows. Payment cadence, liquidity and the required
  /// KYC tier are properties of the return model itself — they are read off
  /// [InvestmentPlan.isDynamic], never invented per plan.
  static List<({String label, List<String> cells})> _rows(
    List<InvestmentPlan> plans,
  ) => [
    (
      label: 'نوع بازده',
      cells: [for (final p in plans) p.isDynamic ? 'داینامیک' : 'اعلام‌شده'],
    ),
    (
      label: 'حداقل مبلغ',
      cells: [for (final p in plans) Fmt.toman(p.minAmount)],
    ),
    (
      label: 'نحوه پرداخت',
      cells: [for (final p in plans) p.isDynamic ? 'در سررسید' : 'دوره‌ای'],
    ),
    (
      label: 'نقدشوندگی',
      cells: [for (final p in plans) p.isDynamic ? 'پایین‌تر' : 'محدود'],
    ),
    (
      label: 'احراز هویت',
      cells: [for (final p in plans) p.isDynamic ? 'پیشرفته' : 'پایه'],
    ),
  ];
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.plans});

  final List<InvestmentPlan> plans;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(flex: 4, child: SizedBox.shrink()),
        for (final p in plans)
          Expanded(
            flex: 5,
            child: Text(
              p.name,
              style: context.text.bodySmall.copyWith(
                color: c.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

class _AttributeRow extends StatelessWidget {
  const _AttributeRow({required this.label, required this.cells});

  final String label;
  final List<String> cells;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: context.text.caption.copyWith(color: c.textMuted),
          ),
        ),
        for (final v in cells)
          Expanded(
            flex: 5,
            child: Text(
              v,
              style: context.text.bodySmall.copyWith(color: c.textPrimary),
            ),
          ),
      ],
    );
  }
}

/// Risk keeps its badge — icon + label + colour, never colour alone.
class _RiskRow extends StatelessWidget {
  const _RiskRow({required this.plans});

  final List<InvestmentPlan> plans;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            'سطح ریسک',
            style: context.text.caption.copyWith(color: c.textMuted),
          ),
        ),
        for (final p in plans)
          Expanded(
            flex: 5,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: RiskBadge(p.riskLevel),
            ),
          ),
      ],
    );
  }
}
