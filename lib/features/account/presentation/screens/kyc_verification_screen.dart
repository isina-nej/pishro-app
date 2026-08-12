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
import '../../../auth/presentation/widgets/consent_checkbox.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/account_repository.dart';

/// Screen/Account/KYCVerification — mock؛ رضایت پیش‌فرض نه.
class KYCVerificationScreen extends ConsumerStatefulWidget {
  const KYCVerificationScreen({super.key});

  @override
  ConsumerState<KYCVerificationScreen> createState() =>
      _KYCVerificationScreenState();
}

class _KYCVerificationScreenState extends ConsumerState<KYCVerificationScreen> {
  var _consent = false;
  var _showRequired = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final kyc = ref.watch(kycSnapshotProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تکمیل احراز هویت',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: kyc.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            ErrorStateView(onRetry: () => ref.invalidate(kycSnapshotProvider)),
        data: (snap) => ListView(
          padding: const EdgeInsets.all(Space.page),
          children: [
            const NoticeBanner(
              message:
                  'بارگذاری مدارک هنوز به API وصل نیست. وضعیت‌ها نمونه است.',
              tone: NoticeTone.info,
            ),
            const SizedBox(height: Space.s4),
            Builder(
              builder: (context) {
                final steps = [
                  snap.identity,
                  snap.iban,
                  snap.address,
                  snap.selfie,
                ];
                final done = steps.where((s) => s == KycStatus.verified).length;
                return Text(
                  'مرحله ${Fmt.fa('${done + 1 > steps.length ? steps.length : done + 1}')} از ${Fmt.fa('${steps.length}')}',
                  style: context.text.caption.copyWith(color: c.textMuted),
                );
              },
            ),
            const SizedBox(height: Space.s3),
            _Step('اطلاعات هویتی', snap.identity),
            _Step('شماره شبا', snap.iban),
            _Step('نشانی محل سکونت', snap.address),
            _Step('تصویر سلفی', snap.selfie),
            const SizedBox(height: Space.s4),
            Text(
              'تصویر باید واضح و بدون انعکاس نور باشد. فرمت‌های JPG و PNG تا '
              '۵ مگابایت پشتیبانی می‌شود.',
              style: context.text.caption.copyWith(
                color: c.textMuted,
                height: 1.8,
              ),
            ),
            const SizedBox(height: Space.s4),
            ConsentCheckbox(
              value: _consent,
              showRequired: _showRequired,
              onChanged: (v) => setState(() {
                _consent = v;
                if (v) _showRequired = false;
              }),
              label:
                  'صحت مدارک و اجازه پردازش آن‌ها برای احراز هویت را می‌پذیرم.',
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.page),
          child: PishroButton(
            label: 'ارسال برای بررسی',
            onPressed: () {
              if (!_consent) {
                setState(() => _showRequired = true);
                return;
              }
              context.go(Routes.kycOverview);
            },
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step(this.title, this.status);
  final String title;
  final KycStatus status;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.s3),
      child: PishroCard(
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
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
                KycStatus.missing => Icons.upload_outlined,
              },
            ),
          ],
        ),
      ),
    );
  }
}
