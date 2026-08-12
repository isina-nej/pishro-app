import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_button.dart';

/// Screen/News/Search — «جستجو».
///
/// Source: `../desighn/_capture/05-05-news.dc.html` · Android 390dp · RTL.
class NewsSearchScreen extends ConsumerWidget {
  const NewsSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: Space.s5,
        title: Text(
          'جستجو',
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
          Text('جستجو', style: context.text.h2.copyWith(color: c.textPrimary)),
          const SizedBox(height: Space.s2),
          Text(
            'پیاده‌سازی بر اساس دک طراحی · Screen/News/Search',
            style: context.text.bodySmall.copyWith(color: c.textMuted),
          ),
          const SizedBox(height: Space.s5),
          PishroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DeckRow(text: r'نتایج اخبار'),
                _DeckRow(text: r'«بیت‌کوین» · ۲۴ نتیجه'),
                _DeckRow(text: r'فیلتر'),
                _DeckRow(text: r'جدیدترین'),
                _DeckRow(text: r'ارز دیجیتال ✕'),
                _DeckRow(text: r'تحلیل روند بیت‌کوین در معاملات هفته جاری'),
                _DeckRow(text: r'ارز دیجیتال · ۳ ساعت پیش · ۱۸ دیدگاه'),
                _DeckRow(
                  text: r'مقایسه عملکرد بیت‌کوین و اتریوم در سه ماه اخیر',
                ),
                _DeckRow(text: r'ارز دیجیتال · دیروز · ۷ دیدگاه'),
                _DeckRow(text: r'واکنش بازار به تصمیمات اخیر تنظیم‌گران'),
                _DeckRow(text: r'ارز دیجیتال · ۲ روز پیش · ۴ دیدگاه'),
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
