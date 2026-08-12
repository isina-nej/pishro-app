import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../data/checkout_repository.dart';

/// Screen/Checkout/PaymentProcessing — ارسال یک‌باره، بدون ثبت تکراری.
class PaymentProcessingScreen extends ConsumerStatefulWidget {
  const PaymentProcessingScreen({super.key});

  @override
  ConsumerState<PaymentProcessingScreen> createState() =>
      _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState
    extends ConsumerState<PaymentProcessingScreen> {
  var _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    if (_started) return;
    _started = true;
    final draft = ref.read(checkoutProvider);
    if (draft == null) {
      if (mounted) context.go(Routes.courses);
      return;
    }
    try {
      await ref.read(checkoutProvider.notifier).submit();
      if (!mounted) return;
      context.go(Routes.checkoutSuccess);
    } on NetworkException {
      if (!mounted) return;
      context.go(Routes.checkoutNetworkError);
    } on UnauthorizedException {
      if (!mounted) return;
      context.go(Routes.login);
    } catch (_) {
      if (!mounted) return;
      context.go(Routes.checkoutFailure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(Space.s8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: c.actionPrimary),
              const SizedBox(height: Space.s5),
              Text(
                'در حال اتصال به درگاه…',
                style: context.text.h3.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: Space.s2),
              Text(
                'لطفاً صفحه را نبندید. ارسال مجدد مسدود است.',
                textAlign: TextAlign.center,
                style: context.text.bodySmall.copyWith(color: c.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
