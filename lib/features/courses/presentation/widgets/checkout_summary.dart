import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_badge.dart';
import '../../data/checkout_repository.dart';
import '../../data/courses_models.dart';

class CheckoutSummaryCard extends StatelessWidget {
  const CheckoutSummaryCard({super.key, required this.draft});

  final CheckoutDraft draft;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = draft.totals;
    return PishroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  draft.course.title,
                  style: context.text.bodyMedium.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              draft.package == PackageType.vip
                  ? const PishroBadge.vip()
                  : const PishroBadge.regular(),
            ],
          ),
          const SizedBox(height: Space.s4),
          _Row('مبلغ بسته', Fmt.toman(t.base)),
          if (t.discount > 0) _Row('تخفیف کد', '− ${Fmt.toman(t.discount)}'),
          if (draft.useCoin)
            _Row(
              'پیشرو کوین',
              t.coinDiscount == null
                  ? 'طبق قوانین محاسبه می‌شود'
                  : '− ${Fmt.toman(t.coinDiscount!)}',
            ),
          const Divider(height: Space.s6),
          _Row('قابل پرداخت', Fmt.toman(t.payable), emphasize: true),
          const SizedBox(height: Space.s3),
          TextButton(
            onPressed: () => context.push(Routes.checkoutDiscount),
            child: Text(
              draft.discount == null
                  ? 'کد تخفیف یا پیشرو کوین'
                  : 'کد ${draft.discount!.code} · ویرایش',
              style: context.text.bodySmall.copyWith(color: c.actionPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.emphasize = false});

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.s2),
      child: Row(
        children: [
          Text(
            label,
            style: context.text.bodySmall.copyWith(
              color: emphasize ? c.textPrimary : c.textMuted,
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: context.text.bodySmall.copyWith(
              color: c.textPrimary,
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
