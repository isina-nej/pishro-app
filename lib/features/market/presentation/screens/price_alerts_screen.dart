import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_button.dart';

/// Screen/Market/PriceAlerts — «هشدارهای قیمت».
///
/// Source: `../desighn/_capture/08-07-market.dc.html` · Android 390dp · RTL.
class PriceAlertsScreen extends ConsumerWidget {
  const PriceAlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: Space.s5,
        title: Text(
          'هشدارهای قیمت',
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
            'هشدارهای قیمت',
            style: context.text.h2.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: Space.s2),
          Text(
            'پیاده‌سازی بر اساس دک طراحی · Screen/Market/PriceAlerts',
            style: context.text.bodySmall.copyWith(color: c.textMuted),
          ),
          const SizedBox(height: Space.s5),
          PishroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DeckRow(text: r'هشدارهای قیمت'),
                _DeckRow(text: r'Bitcoin — بیشتر از ۳٬۵۰۰٬۰۰۰٬۰۰۰ تومان'),
                _DeckRow(text: r'فعلی: ۳٬۴۲۰٬۰۰۰٬۰۰۰ · ایجاد: ۳ روز پیش'),
                _DeckRow(text: r'Ethereum — کمتر از ۱۸۰٬۰۰۰٬۰۰۰ تومان'),
                _DeckRow(text: r'غیرفعال · ایجاد: ۱ هفته پیش'),
                _DeckRow(
                  text: r'هشدار قیمت به معنای انجام خودکار معامله نیست.',
                ),
                _DeckRow(text: r'ساخت هشدار'),
                _DeckRow(text: r'۱۲ · هشدارهای قیمت'),
                _DeckRow(text: r'Overlay مصور'),
                _DeckRow(text: r'ساخت هشدار قیمت'),
                _DeckRow(text: r'بیشتر از'),
                _DeckRow(text: r'کمتر از'),
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
