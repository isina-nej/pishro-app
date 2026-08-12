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
import '../../../../shared/widgets/pishro_badge.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/investment_models.dart';
import '../../data/investment_repository.dart';

/// Screen/Investment/ActiveInvestments — از تراکنش‌ها؛ بدون طرح جعلی.
class ActiveInvestmentsScreen extends ConsumerWidget {
  const ActiveInvestmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final txs = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'سرمایه‌گذاری‌های فعال',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: txs.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(Space.page),
          child: Skeleton.box(height: 80),
        ),
        error: (e, _) => ErrorStateView(
          message: e is ApiException ? e.message : 'فهرست بارگذاری نشد.',
          onRetry: () => ref.invalidate(transactionsProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              title: 'هنوز سرمایه‌گذاری ثبت نشده',
              actionLabel: 'مشاهده طرح‌ها',
              onAction: () => context.push(Routes.planCatalog),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(Space.page),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: Space.s3),
            itemBuilder: (_, i) {
              final t = items[i];
              return PishroCard(
                onTap: () => context.push(Routes.investmentDetails(t.id)),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.title,
                            style: context.text.bodyMedium.copyWith(
                              color: c.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: Space.s1),
                          Text(
                            '${Fmt.toman(t.amount)} · ${Fmt.jalaliDate(t.createdAt)}',
                            style: context.text.caption.copyWith(
                              color: c.textMuted,
                            ),
                          ),
                        ],
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
              );
            },
          );
        },
      ),
    );
  }
}
