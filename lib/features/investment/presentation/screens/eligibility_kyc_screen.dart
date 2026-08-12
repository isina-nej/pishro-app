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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'احراز صلاحیت',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          const NoticeBanner(
            message: 'وضعیت احراز هویت فعلاً نمونه است تا سرویس KYC وصل شود.',
            tone: NoticeTone.info,
          ),
          const SizedBox(height: Space.s4),
          for (final check in eligibility.checks) ...[
            PishroCard(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      check.title,
                      style: context.text.bodyMedium.copyWith(
                        color: c.textPrimary,
                      ),
                    ),
                  ),
                  PishroBadge(
                    label: check.status.label,
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
            label: eligibility.isEligible ? 'ادامه' : 'تکمیل احراز هویت',
            onPressed: () {
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
