import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_button.dart';

/// Screen/Investment/ActiveInvestments — «سرمایه‌گذاری‌های من».
///
/// Source: `../desighn/_capture/07-06-investment-part-2.dc.html` · Android 390dp · RTL.
class ActiveInvestmentsScreen extends ConsumerWidget {
  const ActiveInvestmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: Space.s5,
        title: Text(
          'سرمایه‌گذاری‌های من',
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
            'سرمایه‌گذاری‌های من',
            style: context.text.h2.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: Space.s2),
          Text(
            'پیاده‌سازی بر اساس دک طراحی · Screen/Investment/ActiveInvestments',
            style: context.text.bodySmall.copyWith(color: c.textMuted),
          ),
          const SizedBox(height: Space.s5),
          PishroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DeckRow(text: r'دریافت ماهیانه ۸٪'),
                _DeckRow(text: r'فعال'),
                _DeckRow(text: r'مبلغ سرمایه‌گذاری'),
                _DeckRow(text: r'۵۰٬۰۰۰٬۰۰۰ تومان'),
                _DeckRow(text: r'تاریخ فعال‌سازی'),
                _DeckRow(text: r'۶ مرداد ۱۴۰۵'),
                _DeckRow(text: r'نرخ اعلام‌شده'),
                _DeckRow(text: r'۸٪ ماهیانه'),
                _DeckRow(text: r'دریافتی تاکنون'),
                _DeckRow(text: r'۴٬۰۰۰٬۰۰۰ تومان'),
                _DeckRow(text: r'پرداخت بعدی'),
                _DeckRow(text: r'۱ شهریور ۱۴۰۵'),
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
