import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_badge.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/investment_models.dart';
import '../../data/investment_repository.dart';

/// Screen/Investment/PaymentSchedule — فقط وضعیت تراکنش؛ بدون اقساط جعلی.
class PaymentScheduleScreen extends ConsumerWidget {
  const PaymentScheduleScreen({super.key, this.id = ''});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final tx = ref.watch(transactionProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'برنامه پرداخت',
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
            return const EmptyState(title: 'رکوردی یافت نشد');
          }
          return ListView(
            padding: const EdgeInsets.all(Space.page),
            children: [
              const NoticeBanner(
                message:
                    'جدول اقساط از سرور نمی‌آید؛ فقط وضعیت همین پرداخت نمایش داده می‌شود.',
                tone: NoticeTone.info,
              ),
              const SizedBox(height: Space.s4),
              PishroCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Fmt.toman(t.amount),
                            style: context.text.bodyMedium.copyWith(
                              color: c.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            Fmt.jalaliLong(t.createdAt),
                            style: context.text.caption.copyWith(
                              color: c.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PishroBadge(
                      label: t.scheduleStatusLabel,
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
              ),
              const SizedBox(height: Space.s3),
              Text(
                'پرداخت بعدی: $kPerContractSchedule',
                style: context.text.caption.copyWith(color: c.textMuted),
              ),
            ],
          );
        },
      ),
    );
  }
}
