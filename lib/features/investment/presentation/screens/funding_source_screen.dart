import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/investment_flow.dart';
import '../../data/investment_models.dart';

/// Screen/Investment/FundingSource — موجودی = مقدار نمونه.
class FundingSourceScreen extends ConsumerWidget {
  const FundingSourceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final draft = ref.watch(investmentFlowProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'منبع تأمین وجه',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          for (final k in FundingSourceKind.values) ...[
            PishroCard(
              selected: draft.funding == k,
              onTap: () =>
                  ref.read(investmentFlowProvider.notifier).setFunding(k),
              child: Row(
                children: [
                  Icon(
                    draft.funding == k
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: draft.funding == k ? c.actionPrimary : c.textMuted,
                  ),
                  const SizedBox(width: Space.s3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          k.title,
                          style: context.text.bodyMedium.copyWith(
                            color: c.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          k.subtitle,
                          style: context.text.caption.copyWith(
                            color: c.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Space.s3),
          ],
          const NoticeBanner(
            message: 'همه تراکنش‌ها از طریق مسیر امن پرداخت انجام می‌شود.',
            tone: NoticeTone.info,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.page),
          child: PishroButton(
            label: 'ادامه با روش انتخاب‌شده',
            onPressed: () => context.push(Routes.finalReview),
          ),
        ),
      ),
    );
  }
}
