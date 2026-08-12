import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/pishro_badge.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/investment_models.dart';
import '../../data/investment_repository.dart';

/// Screen/Investment/ActiveInvestmentDetails.
class ActiveInvestmentDetailsScreen extends ConsumerWidget {
  const ActiveInvestmentDetailsScreen({super.key, this.id = ''});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final tx = ref.watch(transactionProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'جزئیات سرمایه‌گذاری',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: tx.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ErrorStateView(
          onRetry: () => ref.invalidate(transactionProvider(id)),
        ),
        data: (t) {
          if (t == null) {
            return const EmptyState(title: 'این رکورد یافت نشد');
          }
          return ListView(
            padding: const EdgeInsets.all(Space.page),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t.title,
                      style: context.text.h3.copyWith(color: c.textPrimary),
                    ),
                  ),
                  PishroBadge(
                    label: t.investmentStatusLabel,
                    tone: switch (t.status) {
                      TxStatus.success => PishroBadgeTone.success,
                      TxStatus.pending => PishroBadgeTone.warning,
                      TxStatus.failed => PishroBadgeTone.danger,
                    },
                    icon: switch (t.status) {
                      TxStatus.success => Icons.check_rounded,
                      TxStatus.pending => Icons.hourglass_top_rounded,
                      TxStatus.failed => Icons.error_outline_rounded,
                    },
                  ),
                ],
              ),
              const SizedBox(height: Space.s4),
              Text(
                Fmt.toman(t.amount),
                style: context.text.h2.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: Space.s2),
              Text(
                Fmt.jalaliLong(t.createdAt),
                style: context.text.caption.copyWith(color: c.textMuted),
              ),
              if (t.refNumber != null) ...[
                const SizedBox(height: Space.s2),
                Text(
                  'پیگیری: ${t.refNumber}',
                  style: context.text.caption.copyWith(color: c.textMuted),
                ),
              ],
              const SizedBox(height: Space.s4),
              const NoticeBanner(
                message:
                    'API طرح، مدت یا جدول اقساط را روی تراکنش نمی‌فرستد؛ جزئیات فقط طبق داده موجود است.',
                tone: NoticeTone.info,
              ),
              const SizedBox(height: Space.s5),
              PishroButton(
                label: 'برنامه پرداخت',
                variant: PishroButtonVariant.secondary,
                onPressed: () => context.push(Routes.paymentSchedule(id)),
              ),
            ],
          );
        },
      ),
    );
  }
}
