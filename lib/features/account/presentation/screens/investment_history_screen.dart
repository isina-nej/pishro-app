import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_badge.dart';
import '../../../../shared/widgets/states.dart';

import '../../../../core/utils/formatters.dart';
import '../../../investment/data/investment_models.dart';
import '../../../investment/data/investment_repository.dart';

class InvestmentHistoryScreen extends ConsumerWidget {
  const InvestmentHistoryScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final txs = ref.watch(transactionsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'سوابق سرمایه‌گذاری',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: txs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            ErrorStateView(onRetry: () => ref.invalidate(transactionsProvider)),
        data: (items) => items.isEmpty
            ? EmptyState(
                title: 'رکوردی نیست',
                actionLabel: 'طرح‌ها',
                onAction: () => context.push(Routes.planCatalog),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(Space.page),
                // One extra row for the deck's closing note about returns.
                itemCount: items.length + 1,
                separatorBuilder: (_, __) => const SizedBox(height: Space.s3),
                itemBuilder: (_, i) {
                  if (i == items.length) {
                    return const NoticeBanner(
                      message: 'داده بازده ثبت‌شده در دسترس نیست.',
                      tone: NoticeTone.info,
                    );
                  }
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
                          // The deck calls a failed record «نیازمند پیگیری»:
                          // the user's action, not the system's verdict.
                          label: t.status == TxStatus.failed
                              ? 'نیازمند پیگیری'
                              : t.investmentStatusLabel,
                          tone: switch (t.status) {
                            TxStatus.success => PishroBadgeTone.success,
                            TxStatus.pending => PishroBadgeTone.warning,
                            TxStatus.failed => PishroBadgeTone.danger,
                          },
                          icon: switch (t.status) {
                            TxStatus.success => Icons.check_rounded,
                            TxStatus.pending => Icons.hourglass_top_rounded,
                            TxStatus.failed => Icons.flag_outlined,
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
