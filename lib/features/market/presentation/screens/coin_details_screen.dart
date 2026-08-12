import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_button.dart';

/// Screen/Market/CoinDetails — «جزئیات ارز».
///
/// Source: `../desighn/_capture/08-07-market.dc.html` · Android 390dp · RTL.
class CoinDetailsScreen extends ConsumerWidget {
  const CoinDetailsScreen({super.key, this.id = ''});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: Space.s5,
        title: Text(
          'جزئیات ارز',
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
            'جزئیات ارز',
            style: context.text.h2.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: Space.s2),
          Text(
            'پیاده‌سازی بر اساس دک طراحی · Screen/Market/CoinDetails',
            style: context.text.bodySmall.copyWith(color: c.textMuted),
          ),
          const SizedBox(height: Space.s5),
          PishroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DeckRow(text: r'۳٬۴۲۰٬۰۰۰٬۰۰۰'),
                _DeckRow(text: r'+۲٫۴۸٪'),
                _DeckRow(
                  text:
                      r'داده‌ها با تأخیر نمایش داده می‌شوند · به‌روزرسانی: ۲ دقیقه پیش',
                ),
                _DeckRow(text: r'۶ تیر'),
                _DeckRow(text: r'۱۳ تیر'),
                _DeckRow(text: r'۲۰ تیر'),
                _DeckRow(text: r'امروز'),
                _DeckRow(text: r'بیشترین'),
                _DeckRow(text: r'۳٬۴۵۰٬۰۰۰٬۰۰۰'),
                _DeckRow(text: r'کمترین'),
                _DeckRow(text: r'۳٬۳۶۰٬۰۰۰٬۰۰۰'),
                _DeckRow(text: r'شروع دوره'),
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
