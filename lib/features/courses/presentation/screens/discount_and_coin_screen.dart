import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_badge.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/pishro_text_field.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/checkout_repository.dart';

/// Screen/Checkout/DiscountAndCoin — کلید کوین؛ بدون نرخ تبدیل.
class DiscountAndCoinScreen extends ConsumerStatefulWidget {
  const DiscountAndCoinScreen({super.key});

  @override
  ConsumerState<DiscountAndCoinScreen> createState() =>
      _DiscountAndCoinScreenState();
}

class _DiscountAndCoinScreenState extends ConsumerState<DiscountAndCoinScreen> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final draft = ref.watch(checkoutProvider);
    final coin = ref.watch(coinBalanceProvider);
    if (draft == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(title: 'سفارشی در جریان نیست'),
      );
    }
    final totals = draft.totals;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'کد تخفیف و کوین پیشرو',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          PishroTextField(
            controller: _code,
            label: 'کد تخفیف',
            hint: 'مثال: PSX10',
            errorText: draft.discountError,
            onChanged: (_) {},
          ),
          const SizedBox(height: Space.s3),
          PishroButton(
            label: draft.discount == null ? 'اعمال' : 'حذف کد',
            variant: PishroButtonVariant.secondary,
            loading: draft.applyingDiscount,
            onPressed: () {
              if (draft.discount != null) {
                ref.read(checkoutProvider.notifier).removeDiscount();
                _code.clear();
                return;
              }
              ref.read(checkoutProvider.notifier).applyDiscount(_code.text);
            },
          ),
          const SizedBox(height: Space.s6),
          PishroCard(
            child: coin.when(
              loading: () => const Skeleton.line(width: 160),
              error: (_, __) => Text(
                'موجودی کوین در دسترس نیست.',
                style: context.text.bodySmall.copyWith(color: c.textMuted),
              ),
              data: (b) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'کوین پیشرو',
                          style: context.text.bodyMedium.copyWith(
                            color: c.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const PishroBadge(
                        label: 'غیرقابل برداشت',
                        tone: PishroBadgeTone.premium,
                        icon: Icons.lock_outline_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: Space.s2),
                  Text(
                    'موجودی: ${Fmt.fa('${b.amount}')} کوین',
                    style: context.text.bodySmall.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
                  Text(
                    'قابل استفاده برای تخفیف',
                    style: context.text.caption.copyWith(color: c.textMuted),
                  ),
                  const SizedBox(height: Space.s3),
                  Text(
                    'در صورت فعال‌سازی، میزان تخفیف طبق قوانین فعال کوین محاسبه و در مرحله تأیید نهایی نمایش داده می‌شود.',
                    style: context.text.caption.copyWith(color: c.textMuted),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'استفاده از کوین در این خرید',
                      style: context.text.bodySmall.copyWith(
                        color: c.textPrimary,
                      ),
                    ),
                    value: draft.useCoin,
                    onChanged: (v) =>
                        ref.read(checkoutProvider.notifier).toggleCoin(v),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Space.s5),
          PishroCard(
            child: Column(
              children: [
                _SumRow('مبلغ دوره', Fmt.toman(totals.base)),
                _SumRow(
                  'تخفیف کد',
                  totals.discount == 0
                      ? Fmt.toman(0)
                      : '− ${Fmt.toman(totals.discount)}',
                ),
                _SumRow(
                  'کوین پیشرو',
                  draft.useCoin
                      ? (totals.coinDiscount == null
                            ? 'طبق قوانین محاسبه می‌شود'
                            : '− ${Fmt.toman(totals.coinDiscount!)}')
                      : '۰ تومان',
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.page),
          child: PishroButton(
            label: 'ادامه به تأیید نهایی',
            onPressed: () => context.pop(),
          ),
        ),
      ),
    );
  }
}

class _SumRow extends StatelessWidget {
  const _SumRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.s2),
      child: Row(
        children: [
          Text(
            label,
            style: context.text.bodySmall.copyWith(color: c.textMuted),
          ),
          const Spacer(),
          Text(
            value,
            style: context.text.bodySmall.copyWith(
              color: c.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
