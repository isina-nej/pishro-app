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
import '../../../../shared/widgets/states.dart';
import '../../data/investment_models.dart';
import '../../data/investment_repository.dart';

/// Screen/Investment/PlanComparison.
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
          child: Skeleton.box(height: 160),
        ),
        error: (_, __) =>
            ErrorStateView(onRetry: () => ref.invalidate(plansProvider)),
        data: (items) {
          if (items.length < 2) {
            return const EmptyState(title: 'برای مقایسه حداقل دو طرح لازم است');
          }
          return ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(Space.page),
            children: [
              for (final p in items)
                SizedBox(
                  width: 260,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: Space.s3),
                    child: PishroCard(
                      onTap: () => context.push(Routes.planDetails(p.id)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RiskBadge(p.riskLevel),
                          const SizedBox(height: Space.s3),
                          Text(
                            p.name,
                            style: context.text.h3.copyWith(
                              color: c.textPrimary,
                            ),
                          ),
                          const SizedBox(height: Space.s3),
                          Text(
                            p.isDynamic
                                ? 'بازده: $kPerContract'
                                : (p.monthlyRatePercent == null
                                      ? kSampleValue
                                      : 'برآورد ماهانه ${Fmt.fa(p.monthlyRatePercent!.toStringAsFixed(0))}٪'),
                            style: context.text.bodySmall.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                          const SizedBox(height: Space.s2),
                          Text(
                            'حداقل ${Fmt.toman(p.minAmount)}',
                            style: context.text.caption.copyWith(
                              color: c.textMuted,
                            ),
                          ),
                          Text(
                            '${Fmt.fa('${p.minDurationMonths}')}–${Fmt.fa('${p.maxDurationMonths}')} ماه',
                            style: context.text.caption.copyWith(
                              color: c.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
