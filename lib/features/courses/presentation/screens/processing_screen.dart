import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_button.dart';

/// Screen/Checkout/Processing — «پرداخت — پردازش (شبکه)».
///
/// Source: `../desighn/_capture/02-04-courses-part-1.dc.html` · Android 390dp · RTL.
class CheckoutProcessingScreen extends ConsumerWidget {
  const CheckoutProcessingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: Space.s5,
        title: Text(
          'پرداخت — پردازش (شبکه)',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Space.page,
          Space.s4,
          Space.page,
          Space.s8,
        ),
        children: [
          Text(
            'پرداخت — پردازش (شبکه)',
            style: context.text.h2.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: Space.s2),
          Text(
            'پیاده‌سازی بر اساس دک طراحی · Screen/Checkout/Processing',
            style: context.text.bodySmall.copyWith(color: c.textMuted),
          ),
          const SizedBox(height: Space.s5),
          PishroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DeckRow(text: r'فعال'),
                _DeckRow(text: r'مبلغ دوره'),
                _DeckRow(text: r'۲٬۴۹۰٬۰۰۰ تومان'),
                _DeckRow(text: r'تخفیف (PSX10)'),
                _DeckRow(text: r'−۲۴۹٬۰۰۰ تومان'),
                _DeckRow(text: r'مبلغ قابل پرداخت'),
                _DeckRow(text: r'۲٬۲۴۱٬۰۰۰ تومان'),
                _DeckRow(text: r'پرداخت ۲٬۲۴۱٬۰۰۰ تومان'),
                _DeckRow(text: r'کد تخفیف اعمال‌شده'),
                _DeckRow(text: r'روش پرداخت'),
                _DeckRow(text: r'درگاه بانکی مستقیم'),
                _DeckRow(text: r'استفاده از کوین پیشرو'),
              ],
            ),
          ),
          const SizedBox(height: Space.s5),
          PishroButton(
            label: 'ادامه',
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _DeckRow extends StatelessWidget {
  const _DeckRow({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.s2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 6, color: c.actionPrimary),
          const SizedBox(width: Space.s3),
          Expanded(
            child: Text(
              text,
              style: context.text.bodyMedium.copyWith(color: c.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
