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

/// Screen/Checkout/Processing — وضعیت نامشخص؛ جدا از ناموفق.
class CheckoutProcessingScreen extends ConsumerWidget {
  const CheckoutProcessingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'وضعیت پرداخت نامشخص',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(Space.page),
        child: Column(
          children: [
            const Spacer(),
            Icon(Icons.hourglass_top_rounded, size: 48, color: c.warning),
            const SizedBox(height: Space.s4),
            Text(
              'وضعیت پرداخت نامشخص است',
              textAlign: TextAlign.center,
              style: context.text.h3.copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: Space.s2),
            Text(
              'نتیجه پرداخت هنوز از بانک دریافت نشده. در صورت کسر مبلغ، دوره به‌صورت خودکار فعال می‌شود.',
              textAlign: TextAlign.center,
              style: context.text.bodySmall.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: Space.s4),
            const NoticeBanner(
              message: 'نامشخص هرگز به‌عنوان ناموفق نمایش داده نمی‌شود.',
              tone: NoticeTone.info,
            ),
            const Spacer(),
            PishroButton(
              label: 'بررسی وضعیت',
              onPressed: () => context.go(Routes.checkoutProcessing),
            ),
            const SizedBox(height: Space.s3),
            PishroButton(
              label: 'بازگشت به دوره‌های من',
              variant: PishroButtonVariant.secondary,
              onPressed: () {
                ref.read(checkoutProvider.notifier).clear();
                context.go(Routes.myCourses);
              },
            ),
          ],
        ),
      ),
    );
  }
}
