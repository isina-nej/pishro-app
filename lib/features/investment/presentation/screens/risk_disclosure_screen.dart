import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/states.dart';
import '../../../auth/presentation/widgets/consent_checkbox.dart';
import '../../data/investment_flow.dart';

/// Screen/Investment/RiskDisclosure.
class RiskDisclosureScreen extends ConsumerWidget {
  const RiskDisclosureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final draft = ref.watch(investmentFlowProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'افشای ریسک',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          const NoticeBanner(
            message: 'سرمایه‌گذاری با ریسک از دست رفتن اصل سرمایه همراه است.',
            tone: NoticeTone.danger,
          ),
          const SizedBox(height: Space.s4),
          Text(
            'بازده گذشته تضمین آینده نیست. طرح‌های داینامیک درصد ثابتی ندارند و هر برآورد فقط برای تصمیم‌گیری است، نه تعهد پرداخت.',
            style: context.text.bodySmall.copyWith(
              color: c.textSecondary,
              height: 1.9,
            ),
          ),
          const SizedBox(height: Space.s5),
          ConsentCheckbox(
            value: draft.riskAccepted,
            showRequired: draft.showConsentError && !draft.riskAccepted,
            onChanged: (v) =>
                ref.read(investmentFlowProvider.notifier).setRiskAccepted(v),
            label: 'ریسک‌های سرمایه‌گذاری را خوانده و می‌پذیرم.',
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.page),
          child: PishroButton(
            label: 'ادامه',
            onPressed: () {
              if (!draft.riskAccepted) {
                ref.read(investmentFlowProvider.notifier).flagConsentMissing();
                return;
              }
              context.push(Routes.terms);
            },
          ),
        ),
      ),
    );
  }
}
