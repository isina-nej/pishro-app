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

/// Screen/Investment/FinalReview — فقط برآورد.
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

    final rateLabel = plan.monthlyRatePercent == null
        ? kPerContract
        : '${Fmt.fa(plan.monthlyRatePercent!.toStringAsFixed(0))}٪ ماهیانه';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'مرور نهایی سرمایه‌گذاری',
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
                _EditableRow(label: 'طرح', value: plan.name, action: null),
                _EditableRow(
                  label: 'مبلغ سرمایه‌گذاری',
                  value: Fmt.toman(draft.amount),
                  action: 'ویرایش',
                  onAction: () => context.push(Routes.amountEntry),
                ),
                _EditableRow(
                  label: 'منبع تأمین وجه',
                  value: draft.funding.title,
                  action: 'تغییر',
                  onAction: () => context.push(Routes.fundingSource),
                ),
                _EditableRow(label: 'نرخ اعلام‌شده', value: rateLabel),
                _EditableRow(
                  label: 'برآورد پرداخت ماهانه',
                  value: draft.monthlyEstimate == null
                      ? kPerContract
                      : Fmt.toman(draft.monthlyEstimate!),
                ),
                _EditableRow(label: 'کارمزد', value: Fmt.toman(0)),
                const SizedBox(height: Space.s2),
                RiskBadge(plan.riskLevel),
              ],
            ),
          ),
          const SizedBox(height: Space.s4),
          const NoticeBanner(
            message:
                'نرخ اعلام‌شده به معنای تضمین پرداخت نیست. تمامی مقادیر برآورد است.',
            tone: NoticeTone.warning,
          ),
          const SizedBox(height: Space.s3),
          TextButton(
            onPressed: () => context.push(Routes.riskDisclosure),
            child: Text(
              'مشاهده ریسک‌ها',
              style: context.text.bodySmall.copyWith(color: c.actionPrimary),
            ),
          ),
          TextButton(
            onPressed: () => context.push(Routes.terms),
            child: Text(
              'مشاهده قرارداد',
              style: context.text.bodySmall.copyWith(color: c.actionPrimary),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.page),
          child: PishroButton(
            label: 'ادامه برای تأیید قرارداد',
            onPressed: () => context.push(Routes.contractConfirmation),
          ),
        ),
      ),
    );
  }
}

class _EditableRow extends StatelessWidget {
  const _EditableRow({
    required this.label,
    required this.value,
    this.action,
    this.onAction,
  });

  final String label;
  final String value;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.s3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.text.caption.copyWith(color: c.textMuted),
                ),
                Text(
                  value,
                  style: context.text.bodySmall.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (action != null && onAction != null)
            TextButton(onPressed: onAction, child: Text(action!)),
        ],
      ),
    );
  }
}
