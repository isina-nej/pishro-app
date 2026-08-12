import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_chip.dart';
import '../../../../shared/widgets/pishro_text_field.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/investment_models.dart';
import '../../data/investment_repository.dart';

/// Screen/Investment/Calculator — فقط برآورد؛ بدون تضمین.
class InvestmentCalculatorScreen extends ConsumerStatefulWidget {
  const InvestmentCalculatorScreen({super.key});

  @override
  ConsumerState<InvestmentCalculatorScreen> createState() =>
      _InvestmentCalculatorScreenState();
}

class _InvestmentCalculatorScreenState
    extends ConsumerState<InvestmentCalculatorScreen> {
  InvestmentPlan? _plan;
  var _amount = 0;
  var _months = 1;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final plans = ref.watch(plansProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ماشین‌حساب برآورد',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: plans.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            ErrorStateView(onRetry: () => ref.invalidate(plansProvider)),
        data: (items) {
          _plan ??= items.isEmpty ? null : items.first;
          final plan = _plan;
          if (plan == null) {
            return const EmptyState(title: 'طرحی برای محاسبه نیست');
          }
          if (_amount == 0) _amount = plan.minAmount;
          if (!plan.durationOptions.contains(_months)) {
            _months = plan.durationOptions.first;
          }
          final monthly = plan.monthlyEstimate(_amount);
          final total = plan.totalEstimate(_amount, _months);

          return ListView(
            padding: const EdgeInsets.all(Space.page),
            children: [
              Wrap(
                spacing: Space.s2,
                runSpacing: Space.s2,
                children: [
                  for (final p in items)
                    PishroChip(
                      label: p.name,
                      selected: plan.id == p.id,
                      onTap: () => setState(() {
                        _plan = p;
                        _amount = p.minAmount;
                        _months = p.durationOptions.first;
                      }),
                    ),
                ],
              ),
              const SizedBox(height: Space.s5),
              PishroTextField.amount(
                label: 'مبلغ سرمایه‌گذاری',
                helper: 'حداقل ${Fmt.toman(plan.minAmount)}',
                onChanged: (v) => setState(
                  () => _amount =
                      int.tryParse(
                        Fmt.toAscii(v).replaceAll(RegExp(r'\D'), ''),
                      ) ??
                      0,
                ),
              ),
              const SizedBox(height: Space.s4),
              Text(
                'مدت (ماه)',
                style: context.text.bodySmall.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: Space.s2),
              Wrap(
                spacing: Space.s2,
                children: [
                  for (final m in plan.durationOptions)
                    PishroChip(
                      label: Fmt.fa('$m'),
                      selected: _months == m,
                      onTap: () => setState(() => _months = m),
                    ),
                ],
              ),
              const SizedBox(height: Space.s5),
              PishroCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.isDynamic || monthly == null
                          ? 'برآورد ماهانه: $kPerContract'
                          : 'برآورد ماهانه: ${Fmt.toman(monthly)}',
                      style: context.text.bodyMedium.copyWith(
                        color: c.textPrimary,
                      ),
                    ),
                    const SizedBox(height: Space.s2),
                    Text(
                      total == null
                          ? 'برآورد کل دوره: $kPerContract'
                          : 'برآورد کل دوره: ${Fmt.toman(total)}',
                      style: context.text.bodySmall.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Space.s4),
              const NoticeBanner(
                message: 'این اعداد برآورد است و تضمین سود نیست.',
                tone: NoticeTone.warning,
              ),
            ],
          );
        },
      ),
    );
  }
}
