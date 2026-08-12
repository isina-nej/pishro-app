import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_button.dart';

/// Screen/Investment/Success — «موفقیت (فعال‌شده)».
///
/// Source: `../desighn/_capture/07-06-investment-part-2.dc.html` · Android 390dp · RTL.
class InvestmentSuccessScreen extends ConsumerWidget {
  const InvestmentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: Space.s5,
        title: Text(
          'موفقیت (فعال‌شده)',
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
            'موفقیت (فعال‌شده)',
            style: context.text.h2.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: Space.s2),
          Text(
            'پیاده‌سازی بر اساس دک طراحی · Screen/Investment/Success',
            style: context.text.bodySmall.copyWith(color: c.textMuted),
          ),
          const SizedBox(height: Space.s5),
          PishroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DeckRow(text: r'سرمایه‌گذاری‌های من'),
                _DeckRow(text: r'فعال'),
                _DeckRow(text: r'در انتظار'),
                _DeckRow(text: r'پایان‌یافته'),
                _DeckRow(text: r'همه'),
                _DeckRow(text: r'دریافت ماهیانه ۸٪'),
                _DeckRow(text: r'فعال'),
                _DeckRow(text: r'۵۰٬۰۰۰٬۰۰۰'),
                _DeckRow(text: r'تومان'),
                _DeckRow(text: r'پرداخت بعدی: ۱ شهریور ۱۴۰۵'),
                _DeckRow(text: r'هولد داینامیک'),
                _DeckRow(text: r'در انتظار فعال‌سازی'),
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
