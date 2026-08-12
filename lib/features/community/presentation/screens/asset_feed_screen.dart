import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_button.dart';

/// Screen/Community/AssetFeed — «فید دارایی در جامعه».
///
/// Source: `../desighn/_capture/08-07-market.dc.html` · Android 390dp · RTL.
class AssetFeedScreen extends ConsumerWidget {
  const AssetFeedScreen({super.key, this.id = ''});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: Space.s5,
        title: Text(
          'فید دارایی در جامعه',
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
            'فید دارایی در جامعه',
            style: context.text.h2.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: Space.s2),
          Text(
            'پیاده‌سازی بر اساس دک طراحی · Screen/Community/AssetFeed',
            style: context.text.bodySmall.copyWith(color: c.textMuted),
          ),
          const SizedBox(height: Space.s5),
          PishroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DeckRow(text: r'Change = علامت+آیکون+رنگ سمانتیک'),
                _DeckRow(text: r'زنده فقط با تأیید بک‌اند'),
                _DeckRow(text: r'بدون دکمه خرید/فروش'),
                _DeckRow(text: r'خلاصه متنی برای دسترسی‌پذیری'),
                _DeckRow(text: r'«داده در دسترس نیست» نه صفر'),
                _DeckRow(text: r'کارت پشته‌ای موبایل، نه جدول فشرده'),
                _DeckRow(text: r'اتصالات این تحویل'),
                _DeckRow(text: r'تب بازار'),
                _DeckRow(text: r'زیرصفحات خانه'),
                _DeckRow(text: r'ردیف دارایی'),
                _DeckRow(text: r'هر جا → CoinDetails'),
                _DeckRow(text: r'جزئیات ارز'),
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
