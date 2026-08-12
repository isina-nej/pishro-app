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

/// Screen/Investment/DynamicHoldPlanDetails — بدون درصد اختراعی.
class DynamicHoldPlanDetailsScreen extends ConsumerWidget {
  const DynamicHoldPlanDetailsScreen({super.key, this.id = ''});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final plan = ref.watch(planProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'طرح هولد داینامیک',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: plan.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            ErrorStateView(onRetry: () => ref.invalidate(planProvider(id))),
        data: (p) {
          if (p == null) {
            return const EmptyState(title: 'این طرح یافت نشد');
          }
          return ListView(
            padding: const EdgeInsets.all(Space.page),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      p.name,
                      style: context.text.h2.copyWith(color: c.textPrimary),
                    ),
                  ),
                  RiskBadge(p.riskLevel),
                ],
              ),
              const SizedBox(height: Space.s3),
              Text(
                'مدل بازده: داینامیک · $kPerContract',
                style: context.text.bodyMedium.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: Space.s3),
              Text(
                p.description ??
                    'بازده این طرح متغیر است و درصد ثابتی اعلام نمی‌شود.',
                style: context.text.bodySmall.copyWith(
                  color: c.textSecondary,
                  height: 1.8,
                ),
              ),
              const SizedBox(height: Space.s4),
              Text(
                'حداقل ${Fmt.toman(p.minAmount)} · مدت ${Fmt.fa('${p.minDurationMonths}')} تا ${Fmt.fa('${p.maxDurationMonths}')} ماه',
                style: context.text.caption.copyWith(color: c.textMuted),
              ),
              const SizedBox(height: Space.s5),
              const NoticeBanner(
                message:
                    'هیچ درصد یا سود تضمینی برای طرح هولد نمایش داده نمی‌شود.',
                tone: NoticeTone.warning,
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: plan.maybeWhen(
        data: (p) => p == null
            ? null
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(Space.page),
                  child: PishroButton(
                    label: 'ادامه با این طرح',
                    onPressed: () {
                      ref.read(investmentFlowProvider.notifier).start(p);
                      context.push(Routes.riskDisclosure);
                    },
                  ),
                ),
              ),
        orElse: () => null,
      ),
    );
  }
}
