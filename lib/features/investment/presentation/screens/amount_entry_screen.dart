import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/pishro_chip.dart';
import '../../../../shared/widgets/pishro_text_field.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/investment_flow.dart';

/// Screen/Investment/AmountEntry.
class AmountEntryScreen extends ConsumerStatefulWidget {
  const AmountEntryScreen({super.key});

  @override
  ConsumerState<AmountEntryScreen> createState() => _AmountEntryScreenState();
}

class _AmountEntryScreenState extends ConsumerState<AmountEntryScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final amount = ref.read(investmentFlowProvider).amount;
    _controller = TextEditingController(text: amount == 0 ? '' : '$amount');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final draft = ref.watch(investmentFlowProvider);
    final plan = draft.plan;
    if (plan == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(
          title: 'طرحی انتخاب نشده',
          actionLabel: 'فهرست طرح‌ها',
          onAction: () => context.go(Routes.planCatalog),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'مبلغ و مدت',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          PishroTextField.amount(
            label: 'مبلغ',
            helper:
                'حداقل ${Fmt.toman(plan.minAmount)} · حداکثر ${Fmt.toman(plan.maxAmount)}',
            controller: _controller,
            errorText: draft.amount == 0 || draft.amountValid
                ? null
                : 'مبلغ در بازه طرح نیست.',
            onChanged: (v) {
              final n =
                  int.tryParse(Fmt.toAscii(v).replaceAll(RegExp(r'\D'), '')) ??
                  0;
              ref.read(investmentFlowProvider.notifier).setAmount(n);
            },
          ),
          const SizedBox(height: Space.s5),
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
                  selected: draft.durationMonths == m,
                  onTap: () =>
                      ref.read(investmentFlowProvider.notifier).setDuration(m),
                ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.page),
          child: PishroButton(
            label: 'ادامه',
            onPressed: !draft.amountValid
                ? null
                : () => context.push(Routes.fundingSource),
          ),
        ),
      ),
    );
  }
}
