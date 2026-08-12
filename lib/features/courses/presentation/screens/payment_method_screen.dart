import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/checkout_repository.dart';

/// Screen/Checkout/PaymentMethod — فقط درگاه مستقیم فعال است.
class PaymentMethodScreen extends ConsumerWidget {
  const PaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final draft = ref.watch(checkoutProvider);
    if (draft == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(title: 'سفارشی در جریان نیست'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'روش پرداخت',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          for (final m in PaymentMethod.values) ...[
            PishroCard(
              selected: draft.method == m,
              onTap: m.available
                  ? () => ref.read(checkoutProvider.notifier).setMethod(m)
                  : null,
              child: Row(
                children: [
                  Icon(
                    m.available
                        ? Icons.account_balance_rounded
                        : Icons.schedule_rounded,
                    color: m.available ? c.actionPrimary : c.textMuted,
                  ),
                  const SizedBox(width: Space.s3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.label,
                          style: context.text.bodyMedium.copyWith(
                            color: c.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          m.hint,
                          style: context.text.caption.copyWith(
                            color: c.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    draft.method == m
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: draft.method == m ? c.actionPrimary : c.textMuted,
                  ),
                ],
              ),
            ),
            const SizedBox(height: Space.s3),
          ],
          const NoticeBanner(
            message: 'کیف پول بانکی و اقساط هنوز فعال نشده‌اند.',
            tone: NoticeTone.info,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.page),
          child: PishroButton(
            label: 'تأیید روش پرداخت',
            onPressed: () => context.pop(),
          ),
        ),
      ),
    );
  }
}
