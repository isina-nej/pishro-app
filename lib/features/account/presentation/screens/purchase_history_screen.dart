import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/states.dart';

import '../../../../core/utils/formatters.dart';
import '../../../courses/data/checkout_repository.dart';

class PurchaseHistoryScreen extends ConsumerWidget {
  const PurchaseHistoryScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final orders = ref.watch(orderHistoryProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'سوابق خرید',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: orders.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(Space.page),
          child: Skeleton.box(height: 80),
        ),
        error: (_, __) =>
            ErrorStateView(onRetry: () => ref.invalidate(orderHistoryProvider)),
        data: (items) => items.isEmpty
            ? const EmptyState(title: 'خریدی ثبت نشده')
            : ListView.separated(
                padding: const EdgeInsets.all(Space.page),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: Space.s3),
                itemBuilder: (_, i) {
                  final o = items[i];
                  return PishroCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          o.titles.isEmpty ? 'سفارش' : o.titles.join('، '),
                          style: context.text.bodyMedium.copyWith(
                            color: c.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: Space.s2),
                        Text(
                          '${Fmt.toman(o.total)} · ${o.status}',
                          style: context.text.caption.copyWith(
                            color: c.textMuted,
                          ),
                        ),
                        const SizedBox(height: Space.s2),
                        Text(
                          // Access is a separate fact from payment: a settled
                          // order can still be awaiting activation, and a
                          // failed one is never going to activate.
                          switch (o.status) {
                            'PAID' => 'دسترسی: فعال',
                            'FAILED' || 'CANCELLED' => 'دسترسی: فعال نشد',
                            _ => 'دسترسی: در انتظار فعال‌سازی',
                          },
                          style: context.text.caption.copyWith(
                            color: c.textMuted,
                          ),
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
