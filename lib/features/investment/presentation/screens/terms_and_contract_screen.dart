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
import '../../../../shared/widgets/states.dart';
import '../../../auth/presentation/widgets/consent_checkbox.dart';
import '../../data/investment_flow.dart';

/// Screen/Investment/TermsAndContract — «۰۸ · شرایط و قرارداد».
///
/// Contract header, the deck's sample-text warning, the four-article table of
/// contents and the PDF action. Version, publish date and the article bodies
/// come from the contract service, which does not exist yet — the deck's
/// sample values are never faked here.
class TermsAndContractScreen extends ConsumerWidget {
  const TermsAndContractScreen({super.key});

  static const _articles = [
    'شرایط کلی طرح',
    'جدول کارمزدها',
    'شرایط برداشت و خروج زودهنگام',
    'پشتیبانی و رسیدگی به اختلاف',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final draft = ref.watch(investmentFlowProvider);
    final planName = draft.plan?.name;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'شرایط و قرارداد',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          Text(
            planName == null ? 'قرارداد طرح' : 'قرارداد $planName',
            style: context.text.h3.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: Space.s1),
          Text(
            'نسخه و تاریخ انتشار قرارداد از سرویس حقوقی دریافت می‌شود.',
            style: context.text.caption.copyWith(color: c.textMuted),
          ),
          const SizedBox(height: Space.s4),
          const NoticeBanner(
            message: 'متن نمونه — نیازمند جایگزینی با نسخه حقوقی تأییدشده',
            tone: NoticeTone.warning,
          ),
          const SizedBox(height: Space.s5),
          Text(
            'فهرست مطالب',
            style: context.text.bodyMedium.copyWith(
              color: c.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: Space.s3),
          PishroCard(
            child: Column(
              children: [
                for (var i = 0; i < _articles.length; i++) ...[
                  if (i > 0) Divider(height: Space.s4, color: c.borderDefault),
                  Row(
                    children: [
                      Text(
                        '${Fmt.fa('${i + 1}')}.',
                        style: context.text.caption.copyWith(
                          color: c.textMuted,
                        ),
                      ),
                      const SizedBox(width: Space.s2),
                      Expanded(
                        child: Text(
                          _articles[i],
                          style: context.text.bodySmall.copyWith(
                            color: c.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: Space.s4),
          PishroButton(
            label: 'دانلود نسخه PDF',
            variant: PishroButtonVariant.secondary,
            // No contract-document endpoint yet; a button that silently does
            // nothing is worse than one that says why.
            onPressed: null,
          ),
          const SizedBox(height: Space.s2),
          Text(
            'دانلود PDF پس از اتصال سرویس قرارداد فعال می‌شود.',
            style: context.text.caption.copyWith(color: c.textMuted),
          ),
          const SizedBox(height: Space.s5),
          ConsentCheckbox(
            value: draft.termsAccepted,
            showRequired: draft.showConsentError && !draft.termsAccepted,
            onChanged: (v) =>
                ref.read(investmentFlowProvider.notifier).setTermsAccepted(v),
            label: 'قرارداد و شرایط طرح را مطالعه کرده‌ام.',
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.page),
          child: PishroButton(
            label: 'ادامه پس از مطالعه',
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
