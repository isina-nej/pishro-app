import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../auth/presentation/widgets/consent_checkbox.dart';
import '../../data/investment_flow.dart';

/// Screen/Investment/TermsAndContract.
class TermsAndContractScreen extends ConsumerWidget {
  const TermsAndContractScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final draft = ref.watch(investmentFlowProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'شرایط قرارداد',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          Text(
            'مدت قرارداد، نحوه تسویه و شرایط فسخ طبق متن قرارداد نهایی است. هر رقم برآوردی در ماشین‌حساب جایگزین قرارداد نمی‌شود.',
            style: context.text.bodySmall.copyWith(
              color: c.textSecondary,
              height: 1.9,
            ),
          ),
          const SizedBox(height: Space.s5),
          ConsentCheckbox(
            value: draft.termsAccepted,
            showRequired: draft.showConsentError && !draft.termsAccepted,
            onChanged: (v) =>
                ref.read(investmentFlowProvider.notifier).setTermsAccepted(v),
            label: 'متن شرایط قرارداد را می‌پذیرم.',
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.page),
          child: PishroButton(
            label: 'ادامه',
            onPressed: () {
              if (!draft.termsAccepted) {
                ref.read(investmentFlowProvider.notifier).flagConsentMissing();
                return;
              }
              context.push(Routes.kyc);
            },
          ),
        ),
      ),
    );
  }
}
