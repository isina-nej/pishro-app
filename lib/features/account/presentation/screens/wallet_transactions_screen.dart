import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/states.dart';

import '../../../../core/utils/formatters.dart';
import '../../../investment/data/investment_repository.dart';

class WalletTransactionsScreen extends ConsumerWidget {
  const WalletTransactionsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final txs = ref.watch(transactionsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تراکنش‌های کیف پول',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: txs.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(Space.page),
          child: Skeleton.box(height: 80),
        ),
        error: (_, __) =>
            ErrorStateView(onRetry: () => ref.invalidate(transactionsProvider)),
        data: (items) => items.isEmpty
            ? const EmptyState(title: 'تراکنشی نیست')
            : ListView.separated(
                padding: const EdgeInsets.all(Space.page),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: Space.s3),
                itemBuilder: (_, i) {
                  final t = items[i];
                  return PishroCard(
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
                                Fmt.jalaliDate(t.createdAt),
                                style: context.text.caption.copyWith(
                                  color: c.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          Fmt.toman(t.amount),
                          style: context.text.bodySmall.copyWith(
                            color: c.textPrimary,
                            fontWeight: FontWeight.w700,
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
