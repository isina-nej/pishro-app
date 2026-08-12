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

/// Screen/Checkout/Processing — انتظار بازگشت از درگاه (وضعیت نامشخص).
class CheckoutProcessingScreen extends ConsumerWidget {
  const CheckoutProcessingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'در انتظار تأیید درگاه',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(Space.page),
        child: Column(
          children: [
            const Spacer(),
            CircularProgressIndicator(color: c.actionPrimary),
            const SizedBox(height: Space.s5),
            Text(
              'وضعیت پرداخت هنوز مشخص نیست',
              textAlign: TextAlign.center,
              style: context.text.h3.copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: Space.s2),
            Text(
              'نامشخص هرگز به‌عنوان ناموفق نمایش داده نمی‌شود. چند لحظه صبر کنید یا سفارش‌ها را بررسی کنید.',
              textAlign: TextAlign.center,
              style: context.text.bodySmall.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: Space.s4),
            const NoticeBanner(
              message: 'از بستن برنامه تا بازگشت درگاه خودداری کنید.',
              tone: NoticeTone.info,
            ),
            const Spacer(),
            PishroButton(
              label: 'بررسی دوباره',
              onPressed: () => context.go(Routes.checkoutProcessing),
            ),
            const SizedBox(height: Space.s3),
            PishroButton(
              label: 'سفارش‌های من',
              variant: PishroButtonVariant.secondary,
              onPressed: () {
                ref.read(checkoutProvider.notifier).clear();
                context.go(Routes.purchaseHistory);
              },
            ),
          ],
        ),
      ),
    );
  }
}
