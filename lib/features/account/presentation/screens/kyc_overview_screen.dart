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

import '../../data/account_repository.dart';

class KYCOverviewScreen extends ConsumerWidget {
  const KYCOverviewScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final kyc = ref.watch(kycSnapshotProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'احراز هویت',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: kyc.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            ErrorStateView(onRetry: () => ref.invalidate(kycSnapshotProvider)),
        data: (s) => ListView(
          padding: const EdgeInsets.all(Space.page),
          children: [
            const NoticeBanner(
              message: 'KYC هنوز endpoint ندارد؛ وضعیت نمونه است.',
              tone: NoticeTone.info,
            ),
            const SizedBox(height: Space.s4),
            _row(context, 'هویت', s.identity),
            _row(context, 'شماره شبا', s.iban),
            _row(context, 'نشانی', s.address),
            _row(context, 'تصویر چهره', s.selfie),
            const SizedBox(height: Space.s5),
            PishroButton(
              label: 'ادامه احراز',
              onPressed: () => context.push(Routes.kycVerification),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _row(BuildContext context, String label, KycStatus status) {
  final c = context.colors;
  return Padding(
    padding: const EdgeInsets.only(bottom: Space.s3),
    child: PishroCard(
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: context.text.bodyMedium.copyWith(color: c.textPrimary),
            ),
          ),
          PishroBadge(
            label: status.label,
            tone: switch (status) {
              KycStatus.verified => PishroBadgeTone.success,
              KycStatus.pending => PishroBadgeTone.warning,
              KycStatus.missing => PishroBadgeTone.danger,
            },
            icon: switch (status) {
              KycStatus.verified => Icons.check_rounded,
              KycStatus.pending => Icons.hourglass_top_rounded,
              KycStatus.missing => Icons.error_outline_rounded,
            },
          ),
        ],
      ),
    ),
  );
}
