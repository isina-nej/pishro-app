import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/states.dart';

import '../../../../core/utils/formatters.dart';
import '../../../courses/data/checkout_repository.dart';

class AccountWalletScreen extends ConsumerWidget {
  const AccountWalletScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final orders = ref.watch(orderHistoryProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'کیف پول',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          PishroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'موجودی قابل برداشت',
                  style: context.text.caption.copyWith(color: c.textMuted),
                ),
                const SizedBox(height: Space.s2),
                Text(
                  'مقدار نمونه',
                  style: context.text.h2.copyWith(color: c.textPrimary),
                ),
                const SizedBox(height: Space.s2),
                const NoticeBanner(
                  message: 'موجودی کیف پول endpoint مستقل ندارد.',
                  tone: NoticeTone.info,
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.s4),
          PishroButton(
            label: 'تراکنش‌ها',
            variant: PishroButtonVariant.secondary,
            onPressed: () => context.push(Routes.walletTransactions),
          ),
          const SizedBox(height: Space.s4),
          Text(
            'آخرین سفارش‌ها',
            style: context.text.h3.copyWith(color: c.textPrimary),
          ),
          orders.when(
            loading: () => const Skeleton.box(height: 64),
            error: (_, __) => ErrorStateView(
              onRetry: () => ref.invalidate(orderHistoryProvider),
            ),
            data: (items) => items.isEmpty
                ? const EmptyState(title: 'سفارشی نیست')
                : Column(
                    children: [
                      for (final o in items.take(5))
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            o.titles.isEmpty ? 'سفارش' : o.titles.first,
                          ),
                          subtitle: Text(Fmt.toman(o.total)),
                          trailing: Text(
                            o.status,
                            style: context.text.caption.copyWith(
                              color: c.textMuted,
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
