import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/states.dart';
import '../../../account/data/account_repository.dart';
import '../../../auth/presentation/widgets/consent_checkbox.dart';
import '../../data/investment_flow.dart';

/// Screen/Investment/ContractConfirmation — بدون پیش‌تیک.
class ContractConfirmationScreen extends ConsumerWidget {
  const ContractConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final draft = ref.watch(investmentFlowProvider);
    final profile = ref.watch(accountProfileProvider);
    final plan = draft.plan;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تأیید قرارداد',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          Text(
            'قرارداد طرح ${plan?.name ?? 'انتخاب‌شده'} — نسخه ۱٫۲',
            style: context.text.bodyMedium.copyWith(
              color: c.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: Space.s2),
          Text(
            'کاربر: ${profile.valueOrNull?.displayName ?? 'نام کاربر نمونه'} · مبلغ: ${Fmt.toman(draft.amount)}',
            style: context.text.bodySmall.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: Space.s4),
          PishroButton(
            label: 'دانلود قرارداد',
            variant: PishroButtonVariant.secondary,
            onPressed: () {},
          ),
          const SizedBox(height: Space.s4),
          const NoticeBanner(
            message:
                'ثبت درخواست به معنای فعال‌شدن فوری سرمایه‌گذاری نیست. وضعیت نهایی پس از تأیید پرداخت، قرارداد و ایجاد رکورد سرمایه‌گذاری مشخص می‌شود.',
            tone: NoticeTone.info,
          ),
          const SizedBox(height: Space.s5),
          ConsentCheckbox(
            value: draft.riskAccepted && draft.termsAccepted,
            showRequired: draft.showConsentError,
            onChanged: (v) {
              ref.read(investmentFlowProvider.notifier).setAllRiskChecks(v);
              ref.read(investmentFlowProvider.notifier).setTermsAccepted(v);
            },
            label:
                'قرارداد، شرایط طرح و اطلاع‌رسانی ریسک را مطالعه کرده‌ام و با ثبت این درخواست موافقم.',
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.page),
          child: PishroButton(
            label: 'ثبت درخواست سرمایه‌گذاری',
            loading: draft.submitting,
            onPressed: () {
              if (!draft.consentsOk) {
                ref.read(investmentFlowProvider.notifier).flagConsentMissing();
                return;
              }
              context.push(Routes.investmentProcessing);
            },
          ),
        ),
      ),
    );
  }
}
