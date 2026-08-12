import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/pishro_chip.dart';
import '../../../../shared/widgets/pishro_text_field.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/investment_flow.dart';

/// Screen/Investment/AmountEntry — حداقل/گام طرح.
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

    final suggestions = <int>{
      plan.minAmount,
      if (plan.minAmount * 2 <= plan.maxAmount) plan.minAmount * 2,
      if (plan.maxAmount > plan.minAmount) plan.maxAmount,
    }.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'مبلغ سرمایه‌گذاری',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          Text(
            'طرح: ${plan.name} · حداقل ${Fmt.toman(plan.minAmount)}',
            style: context.text.bodySmall.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: Space.s4),
          PishroTextField.amount(
            label: 'مبلغ',
            helper:
                'حداقل ${Fmt.toman(plan.minAmount)} · حداکثر ${Fmt.toman(plan.maxAmount)}'
                '${plan.amountStep > 1 ? ' · گام ${Fmt.toman(plan.amountStep)}' : ''}',
            controller: _controller,
            errorText: draft.amount == 0 || draft.amountValid
                ? null
                : 'مبلغ واردشده کمتر از حداقل مجاز طرح است یا با گام طرح هم‌خوان نیست.',
            onChanged: (v) {
              final n =
                  int.tryParse(Fmt.toAscii(v).replaceAll(RegExp(r'\D'), '')) ??
                  0;
              ref.read(investmentFlowProvider.notifier).setAmount(n);
            },
          ),
          const SizedBox(height: Space.s4),
          Wrap(
            spacing: Space.s2,
            runSpacing: Space.s2,
            children: [
              for (final a in suggestions)
                PishroChip(
                  label: Fmt.toman(a),
                  selected: draft.amount == a,
                  onTap: () {
                    _controller.text = '$a';
                    ref.read(investmentFlowProvider.notifier).setAmount(a);
                  },
                ),
            ],
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
          const SizedBox(height: Space.s5),
          PishroCard(
            child: Column(
              children: [
                _Row('کارمزد برآوردی', Fmt.toman(0)),
                _Row(
                  'مبلغ خالص سرمایه‌گذاری',
                  draft.amount == 0 ? '—' : Fmt.toman(draft.amount),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.s3),
          TextButton(
            onPressed: () => context.push(Routes.calculator),
            child: Text(
              'مشاهده در محاسبه‌گر',
              style: context.text.bodySmall.copyWith(color: c.actionPrimary),
            ),
          ),
          const NoticeBanner(
            message: 'پیش از ادامه، ریسک‌های این طرح را بازبینی کنید.',
            tone: NoticeTone.warning,
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
