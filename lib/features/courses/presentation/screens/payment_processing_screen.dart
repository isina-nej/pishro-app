import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/common.dart';
import '../../data/checkout_repository.dart';

/// Screen/Checkout/PaymentProcessing — ارسال مجدد مسدود است.
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
    final draft = ref.watch(checkoutProvider);
    final refId = draft?.orderId == null
        ? 'TXN-••••'
        : Fmt.fa(draft!.orderId!.toUpperCase());

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.page),
          child: Column(
            children: [
              const Spacer(),
              CircularProgressIndicator(color: c.actionPrimary),
              const SizedBox(height: Space.s5),
              Text(
                'در حال پردازش پرداخت',
                textAlign: TextAlign.center,
                style: context.text.h2.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: Space.s2),
              Text(
                'لطفاً از این صفحه خارج نشوید و روی دکمه پرداخت دوباره ضربه نزنید.',
                textAlign: TextAlign.center,
                style: context.text.bodySmall.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: Space.s6),
              PishroCard(
                child: Column(
                  children: [
                    _Row('شناسه پیگیری', refId),
                    if (draft != null)
                      _Row('مبلغ', Fmt.toman(draft.totals.payable)),
                  ],
                ),
              ),
              const Spacer(),
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
