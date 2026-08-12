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
import '../../data/checkout_repository.dart';
import '../../data/courses_models.dart';

/// Screen/Checkout/PaymentSuccess — بدون کانفتی.
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
                'پرداخت با موفقیت انجام شد',
                textAlign: TextAlign.center,
                style: context.text.h2.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: Space.s2),
              Text(
                'دسترسی به دوره برای شما فعال شد.',
                textAlign: TextAlign.center,
                style: context.text.bodySmall.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: Space.s5),
              PishroCard(
                child: Column(
                  children: [
                    _Row('دوره', draft?.course.title ?? '—'),
                    _Row('شماره پیگیری', refId),
                    if (draft != null)
                      _Row('مبلغ پرداخت‌شده', Fmt.toman(draft.totals.payable)),
                    _Row('تاریخ', Fmt.jalaliLong(DateTime.now())),
                  ],
                ),
              ),
              if (draft?.package == PackageType.vip) ...[
                const SizedBox(height: Space.s4),
                Text(
                  'اگر بسته VIP خریداری کرده‌اید، دسترسی به گفت‌وگوی مدرس پس از تأیید نهایی و فعال‌سازی حساب نمایش داده می‌شود.',
                  textAlign: TextAlign.center,
                  style: context.text.caption.copyWith(color: c.textMuted),
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
                label: 'مشاهده رسید',
                variant: PishroButtonVariant.secondary,
                onPressed: () {
                  ref.read(checkoutProvider.notifier).clear();
                  context.go(Routes.purchaseHistory);
                },
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
      padding: const EdgeInsets.only(bottom: Space.s2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.text.caption.copyWith(color: c.textMuted)),
          const SizedBox(width: Space.s3),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: context.text.bodySmall.copyWith(
                color: c.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
