import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/pishro_text_field.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/checkout_repository.dart';

/// Screen/Checkout/DiscountAndCoin — کد تخفیف + کوین غیرقابل برداشت.
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تخفیف و پیشرو کوین',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          PishroTextField(
            controller: _code,
            label: 'کد تخفیف',
            hint: 'مثلاً PSX10',
            errorText: draft.discountError,
            onChanged: (_) {},
          ),
          const SizedBox(height: Space.s3),
          PishroButton(
            label: draft.discount == null ? 'اعمال کد' : 'حذف کد',
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
          if (draft.discount != null) ...[
            const SizedBox(height: Space.s3),
            NoticeBanner(
              message:
                  'کد ${draft.discount!.code} · ${Fmt.fa('${draft.discount!.percent}')}٪ تخفیف',
              tone: NoticeTone.success,
            ),
          ],
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
                  Text(
                    'پیشرو کوین',
                    style: context.text.bodyMedium.copyWith(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: Space.s2),
                  Text(
                    'موجودی: ${Fmt.fa('${b.amount}')} کوین',
                    style: context.text.bodySmall.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
                  const SizedBox(height: Space.s2),
                  const NoticeBanner(
                    message:
                        'پیشرو کوین غیرقابل برداشت است و نرخ تبدیل ثابتی ندارد.',
                    tone: NoticeTone.info,
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
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.page),
          child: PishroButton(
            label: 'بازگشت به خلاصه',
            onPressed: () => context.pop(),
          ),
        ),
      ),
    );
  }
}
