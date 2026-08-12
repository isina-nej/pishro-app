import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/checkout_repository.dart';

/// Screen/Checkout/PaymentFailure — متمایز از وضعیت نامشخص.
class PaymentFailureScreen extends ConsumerWidget {
  const PaymentFailureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final draft = ref.watch(checkoutProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.page),
          child: Column(
            children: [
              const Spacer(),
              Icon(Icons.error_outline_rounded, size: 56, color: c.danger),
              const SizedBox(height: Space.s4),
              Text(
                'پرداخت ناموفق',
                style: context.text.h2.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: Space.s2),
              Text(
                'مبلغ از حساب شما کسر نشده یا در حال برگشت است. می‌توانید دوباره تلاش کنید.',
                textAlign: TextAlign.center,
                style: context.text.bodySmall.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: Space.s4),
              const NoticeBanner(
                message:
                    'وضعیت نامشخص با پرداخت ناموفق یکی نیست. اگر پیام درگاه مبهم بود، از پشتیبانی پیگیری کنید.',
                tone: NoticeTone.warning,
              ),
              const Spacer(),
              PishroButton(
                label: 'تلاش دوباره',
                onPressed: draft == null
                    ? null
                    : () => context.go(Routes.checkout),
              ),
              const SizedBox(height: Space.s3),
              PishroButton(
                label: 'بازگشت به دوره',
                variant: PishroButtonVariant.secondary,
                onPressed: () {
                  final id = draft?.course.id;
                  if (id == null) {
                    context.go(Routes.courses);
                  } else {
                    context.go(Routes.courseDetails(id));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
