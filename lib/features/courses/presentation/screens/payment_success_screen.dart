import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../data/checkout_repository.dart';

/// Screen/Checkout/PaymentSuccess — بدون کانفتی؛ فقط تأیید + شناسه.
class PaymentSuccessScreen extends ConsumerWidget {
  const PaymentSuccessScreen({super.key});

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
              Icon(Icons.check_circle_rounded, size: 56, color: c.success),
              const SizedBox(height: Space.s4),
              Text(
                'پرداخت موفق',
                style: context.text.h2.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: Space.s2),
              Text(
                'سفارش شما ثبت شد. دسترسی دوره به‌زودی فعال می‌شود.',
                textAlign: TextAlign.center,
                style: context.text.bodySmall.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: Space.s4),
              Text(
                'شناسه پیگیری: $refId',
                style: context.text.caption.copyWith(color: c.textMuted),
              ),
              if (draft != null) ...[
                const SizedBox(height: Space.s2),
                Text(
                  draft.course.title,
                  textAlign: TextAlign.center,
                  style: context.text.bodyMedium.copyWith(color: c.textPrimary),
                ),
              ],
              const Spacer(),
              PishroButton(
                label: 'شروع یادگیری',
                onPressed: () {
                  final id = draft?.course.id;
                  ref.read(checkoutProvider.notifier).clear();
                  if (id == null) {
                    context.go(Routes.myCourses);
                  } else {
                    context.go(Routes.learningDashboard(id));
                  }
                },
              ),
              const SizedBox(height: Space.s3),
              PishroButton(
                label: 'دوره‌های من',
                variant: PishroButtonVariant.secondary,
                onPressed: () {
                  ref.read(checkoutProvider.notifier).clear();
                  context.go(Routes.myCourses);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
