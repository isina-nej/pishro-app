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
import '../../../auth/presentation/widgets/consent_checkbox.dart';
import '../../data/investment_flow.dart';

/// Screen/Investment/RiskDisclosure — «۰۷ · اطلاع‌رسانی ریسک».
///
/// Three named risks, then four separate acknowledgements. The deck marks this
/// screen «بدون پیش‌انتخاب»: nothing starts ticked and the CTA stays inert
/// until all four are.
class RiskDisclosureScreen extends ConsumerWidget {
  const RiskDisclosureScreen({super.key});

  static const _risks = [
    (
      icon: Icons.trending_down_rounded,
      title: 'ریسک بازار',
      body: 'ارزش دارایی‌ها ممکن است کاهش یابد.',
    ),
    (
      icon: Icons.water_drop_outlined,
      title: 'ریسک نقدشوندگی',
      body: 'برداشت زودهنگام ممکن است محدود یا مشمول شرایط باشد.',
    ),
    (
      icon: Icons.description_outlined,
      title: 'ریسک قرارداد و عملیاتی',
      body: 'تأخیر یا تغییر شرایط طبق مفاد قرارداد ممکن است رخ دهد.',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final draft = ref.watch(investmentFlowProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'اطلاع‌رسانی ریسک',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          Text(
            'سرمایه‌گذاری می‌تواند با کاهش ارزش، تأخیر در پرداخت یا محدودیت '
            'برداشت همراه باشد. پیش از ادامه، شرایط و ریسک‌های طرح را با دقت '
            'بررسی کنید.',
            style: context.text.bodySmall.copyWith(
              color: c.textSecondary,
              height: 1.9,
            ),
          ),
          const SizedBox(height: Space.s5),
          for (final r in _risks) ...[
            PishroCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(r.icon, size: 20, color: c.danger),
                  const SizedBox(width: Space.s3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.title,
                          style: context.text.bodyMedium.copyWith(
                            color: c.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: Space.s1),
                        Text(
                          r.body,
                          style: context.text.bodySmall.copyWith(
                            color: c.textSecondary,
                            height: 1.8,
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
          const SizedBox(height: Space.s2),
          for (var i = 0; i < kRiskAcknowledgements.length; i++) ...[
            ConsentCheckbox(
              value: draft.riskChecks.contains(i),
              showRequired:
                  draft.showConsentError && !draft.riskChecks.contains(i),
              onChanged: (v) => ref
                  .read(investmentFlowProvider.notifier)
                  .toggleRiskCheck(i, v),
              label: kRiskAcknowledgements[i],
            ),
            const SizedBox(height: Space.s2),
          ],
          if (draft.showConsentError && !draft.riskAccepted) ...[
            const SizedBox(height: Space.s2),
            const NoticeBanner(
              message: 'ابتدا موارد بالا را تأیید کنید.',
              tone: NoticeTone.danger,
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.page),
          child: PishroButton(
            label: 'تأیید مطالعه و ادامه',
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
