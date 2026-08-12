import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_button.dart';

/// Screen/Market/Favorites — «علاقه‌مندی‌ها».
///
/// Source: `../desighn/_capture/08-07-market.dc.html` · Android 390dp · RTL.
class MarketFavoritesScreen extends ConsumerWidget {
  const MarketFavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: Space.s5,
        title: Text(
          'علاقه‌مندی‌ها',
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
            'علاقه‌مندی‌ها',
            style: context.text.h2.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: Space.s2),
          Text(
            'پیاده‌سازی بر اساس دک طراحی · Screen/Market/Favorites',
            style: context.text.bodySmall.copyWith(color: c.textMuted),
          ),
          const SizedBox(height: Space.s5),
          PishroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DeckRow(text: r'ارزهای پرطرفدار'),
                _DeckRow(text: r'امروز'),
                _DeckRow(text: r'۷ روز'),
                _DeckRow(text: r'۳۰ روز'),
                _DeckRow(text: r'علاقه‌مندی نمونه در حال افزایش'),
                _DeckRow(text: r'+۲٫۴۸٪'),
                _DeckRow(text: r'حجم معاملات نمونه بالا'),
                _DeckRow(text: r'+۵٫۱۲٪'),
                _DeckRow(text: r'جستجوی نمونه رو به رشد'),
                _DeckRow(text: r'+۱٫۰۳٪'),
                _DeckRow(
                  text: r'معیار پرطرفداربودن از سرویس داده دریافت می‌شود.',
                ),
                _DeckRow(text: r'۰۴ · پرطرفدار'),
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
