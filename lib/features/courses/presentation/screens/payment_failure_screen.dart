import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_badge.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../data/checkout_repository.dart';

/// Screen/Checkout/PaymentFailure — متمایز از حالت نامشخص.
class PaymentFailureScreen extends ConsumerWidget {
  const PaymentFailureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final draft = ref.watch(checkoutProvider);
    final refId = draft?.orderId == null
        ? '—'
        : Fmt.fa(draft!.orderId!.toUpperCase());

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
                'پرداخت ناموفق بود',
                textAlign: TextAlign.center,
                style: context.text.h2.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: Space.s2),
              Text(
                'مبلغ از حساب شما کسر نشد. تراکنش توسط بانک تأیید نگردید.',
                textAlign: TextAlign.center,
                style: context.text.bodySmall.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: Space.s5),
              PishroCard(
                child: Column(
                  children: [
                    _Row('شماره پیگیری', refId),
                    const Row(
                      children: [
                        Text('وضعیت'),
                        Spacer(),
                        PishroBadge(
                          label: 'ناموفق',
                          tone: PishroBadgeTone.danger,
                          icon: Icons.error_outline_rounded,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              PishroButton(
                label: 'تلاش دوباره',
                onPressed: draft == null
                    ? null
                    : () => context.go(Routes.checkoutPaymentMethod),
              ),
              const SizedBox(height: Space.s3),
              PishroButton(
                label: 'بازگشت به روش پرداخت',
                variant: PishroButtonVariant.secondary,
                onPressed: () => context.go(Routes.checkoutPaymentMethod),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.s3),
      child: Row(
        children: [
          Text(label, style: context.text.caption.copyWith(color: c.textMuted)),
          const Spacer(),
          Text(
            value,
            style: context.text.bodySmall.copyWith(
              color: c.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
