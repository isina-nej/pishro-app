import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/pishro_badge.dart';
import '../../../../shared/widgets/states.dart';

import '../../../../core/utils/formatters.dart';
import '../../../courses/data/checkout_repository.dart';
import '../../data/account_repository.dart';

class PishroCoinScreen extends ConsumerWidget {
  const PishroCoinScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final coin = ref.watch(coinBalanceProvider);
    final ledger = ref.watch(coinLedgerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'پیشرو کوین',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
        actions: const [
          Padding(
            padding: EdgeInsetsDirectional.only(end: Space.s4),
            child: PishroBadge(
              label: 'کوین',
              tone: PishroBadgeTone.premium,
              icon: Icons.star_rounded,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          coin.when(
            loading: () => const Skeleton.line(width: 120),
            error: (_, __) => const Text('موجودی در دسترس نیست'),
            data: (b) => Text(
              '${Fmt.fa('${b.amount}')} کوین',
              style: context.text.h2.copyWith(color: c.textPrimary),
            ),
          ),
          const SizedBox(height: Space.s3),
          const NoticeBanner(
            message: 'پیشرو کوین غیرقابل برداشت است و نرخ تبدیل ثابتی ندارد.',
            tone: NoticeTone.info,
          ),
          const SizedBox(height: Space.s5),
          Text(
            'گردش حساب',
            style: context.text.h3.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: Space.s3),
          ledger.when(
            loading: () => const Skeleton.box(height: 64),
            error: (_, __) => ErrorStateView(
              onRetry: () => ref.invalidate(coinLedgerProvider),
            ),
            data: (items) => Column(
              children: [
                for (final e in items)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(e.title),
                    subtitle: Text(Fmt.jalaliDate(e.at)),
                    trailing: Text(
                      '${e.delta > 0 ? '+' : ''}${Fmt.fa('${e.delta}')}',
                      style: context.text.bodySmall.copyWith(
                        color: e.delta >= 0 ? c.success : c.danger,
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
