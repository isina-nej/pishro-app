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
import '../../../../shared/widgets/pishro_chip.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/investment_models.dart';
import '../../data/investment_repository.dart';

enum _InvTab { active, pending, ended, all }

extension on _InvTab {
  String get label => switch (this) {
    _InvTab.active => 'فعال',
    _InvTab.pending => 'در انتظار',
    _InvTab.ended => 'پایان‌یافته',
    _InvTab.all => 'همه',
  };

  bool accepts(InvestmentTransaction t) => switch (this) {
    _InvTab.active => t.status == TxStatus.success,
    _InvTab.pending => t.status == TxStatus.pending,
    _InvTab.ended => t.status == TxStatus.failed,
    _InvTab.all => true,
  };
}

/// Screen/Investment/ActiveInvestments — از تراکنش واقعی.
class ActiveInvestmentsScreen extends ConsumerStatefulWidget {
  const ActiveInvestmentsScreen({super.key});

  @override
  ConsumerState<ActiveInvestmentsScreen> createState() =>
      _ActiveInvestmentsScreenState();
}

class _ActiveInvestmentsScreenState
    extends ConsumerState<ActiveInvestmentsScreen> {
  var _tab = _InvTab.active;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final txs = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'سرمایه‌گذاری‌های من',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: Column(
        children: [
          PishroChipBar(
            labels: [for (final t in _InvTab.values) t.label],
            selectedIndex: _tab.index,
            onSelected: (i) => setState(() => _tab = _InvTab.values[i]),
          ),
          Expanded(
            child: txs.when(
              loading: () => ListView(
                padding: const EdgeInsets.all(Space.page),
                children: const [
                  Skeleton.box(height: 96),
                  SizedBox(height: Space.s3),
                  Skeleton.box(height: 96),
                ],
              ),
              error: (e, _) => ErrorStateView(
                message: e is ApiException ? e.message : 'فهرست بارگذاری نشد.',
                onRetry: () => ref.invalidate(transactionsProvider),
              ),
              data: (all) {
                final items = [
                  for (final t in all)
                    if (_tab.accepts(t)) t,
                ];
                if (items.isEmpty) {
                  return EmptyState(
                    title: 'هنوز سرمایه‌گذاری فعالی ندارید',
                    message: 'از میان طرح‌های موجود شروع کنید.',
                    actionLabel: 'مشاهده طرح‌ها',
                    onAction: () => context.push(Routes.planCatalog),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(transactionsProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(Space.page),
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: Space.s3),
                    itemBuilder: (_, i) {
                      final t = items[i];
                      return PishroCard(
                        onTap: () =>
                            context.push(Routes.investmentDetails(t.id)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    t.title,
                                    style: context.text.bodyMedium.copyWith(
                                      color: c.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
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
                                    TxStatus.pending =>
                                      Icons.hourglass_top_rounded,
                                    TxStatus.failed =>
                                      Icons.error_outline_rounded,
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: Space.s3),
                            Text(
                              Fmt.toman(t.amount),
                              style: context.text.h3.copyWith(
                                color: c.textPrimary,
                              ),
                            ),
                            const SizedBox(height: Space.s1),
                            Text(
                              t.status == TxStatus.pending
                                  ? 'ثبت‌شده: ${Fmt.relative(t.createdAt)}'
                                  : 'پرداخت بعدی: $kPerContractSchedule',
                              style: context.text.caption.copyWith(
                                color: c.textMuted,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
