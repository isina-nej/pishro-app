import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../routing/routes.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/checkout_repository.dart';

/// Screen/Checkout/NetworkError.
class CheckoutNetworkErrorScreen extends ConsumerWidget {
  const CheckoutNetworkErrorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final draft = ref.watch(checkoutProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'خطای اتصال شبکه',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ErrorStateView(
              message:
                  'ارتباط با سرویس پرداخت برقرار نشد. اگر مبلغ کسر شده، وضعیت '
                  'را از سفارش‌ها پیگیری کنید.',
              onRetry: () => context.go(
                draft == null ? Routes.courses : Routes.checkoutProcessing,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Space.page),
            child: PishroButton(
              label: 'بازگشت به جزئیات خرید',
              variant: PishroButtonVariant.secondary,
              onPressed: () =>
                  context.go(draft == null ? Routes.courses : Routes.checkout),
            ),
          ),
        ],
      ),
    );
  }
}
