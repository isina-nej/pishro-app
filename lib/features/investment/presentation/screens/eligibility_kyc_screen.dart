import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_badge.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/investment_flow.dart';
import '../../data/investment_models.dart';

/// Screen/Investment/EligibilityAndKYC — mock تا endpoint بیاید.
class EligibilityAndKYCScreen extends ConsumerWidget {
  const EligibilityAndKYCScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final eligibility = ref.watch(eligibilityProvider);
    final plan = ref.watch(investmentFlowProvider).plan;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'بررسی شرایط سرمایه‌گذاری',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          if (plan != null) ...[
            Text(
              'طرح انتخابی: ${plan.name}',
              style: context.text.bodySmall.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: Space.s3),
          ],
          PishroBadge(
            label: eligibility.isEligible
                ? 'واجد شرایط'
                : eligibility.isPending
                ? 'در حال بررسی'
                : 'ناقص',
            tone: eligibility.isEligible
                ? PishroBadgeTone.success
                : eligibility.isPending
                ? PishroBadgeTone.warning
                : PishroBadgeTone.danger,
            icon: eligibility.isEligible
                ? Icons.check_rounded
                : eligibility.isPending
                ? Icons.hourglass_top_rounded
                : Icons.error_outline_rounded,
          ),
          const SizedBox(height: Space.s4),
          const NoticeBanner(
            message: 'وضعیت احراز هویت فعلاً نمونه است تا سرویس KYC وصل شود.',
            tone: NoticeTone.info,
          ),
          const SizedBox(height: Space.s4),
          for (final check in eligibility.checks) ...[
            PishroCard(
              child: Row(
                children: [
                  Icon(
                    switch (check.status) {
                      CheckStatus.verified => Icons.check_circle_rounded,
                      CheckStatus.pending => Icons.hourglass_top_rounded,
                      CheckStatus.missing => Icons.error_outline_rounded,
                    },
                    color: switch (check.status) {
                      CheckStatus.verified => c.success,
                      CheckStatus.pending => c.warning,
                      CheckStatus.missing => c.danger,
                    },
                  ),
                  const SizedBox(width: Space.s3),
                  Expanded(
                    child: Text(
                      check.title,
                      style: context.text.bodyMedium.copyWith(
                        color: c.textPrimary,
                      ),
                    ),
                  ),
                  PishroBadge(
                    label:
                        check.status == CheckStatus.verified &&
                            (check.title.contains('ریسک') ||
                                check.title.contains('قرارداد'))
                        ? 'تکمیل‌شده'
                        : check.status.label,
                    tone: switch (check.status) {
                      CheckStatus.verified => PishroBadgeTone.success,
                      CheckStatus.pending => PishroBadgeTone.warning,
                      CheckStatus.missing => PishroBadgeTone.danger,
                    },
                    icon: switch (check.status) {
                      CheckStatus.verified => Icons.check_rounded,
                      CheckStatus.pending => Icons.hourglass_top_rounded,
                      CheckStatus.missing => Icons.error_outline_rounded,
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: Space.s3),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.page),
          child: PishroButton(
            label: eligibility.isEligible
                ? 'ادامه فرایند'
                : eligibility.isPending
                ? 'در انتظار بررسی'
                : 'تکمیل اطلاعات',
            onPressed: eligibility.isPending
                ? null
                : () {
                    if (eligibility.isEligible) {
                      context.push(Routes.amountEntry);
                    } else {
                      context.push(Routes.kycOverview);
                    }
                  },
          ),
        ),
      ),
    );
  }
}
