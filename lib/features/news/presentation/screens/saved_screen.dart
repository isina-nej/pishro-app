import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_button.dart';

/// Screen/News/Saved — «ذخیره‌شده‌ها».
///
/// Source: `../desighn/_capture/05-05-news.dc.html` · Android 390dp · RTL.
class NewsSavedScreen extends ConsumerWidget {
  const NewsSavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: Space.s5,
        title: Text(
          'ذخیره‌شده‌ها',
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
            'ذخیره‌شده‌ها',
            style: context.text.h2.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: Space.s2),
          Text(
            'پیاده‌سازی بر اساس دک طراحی · Screen/News/Saved',
            style: context.text.bodySmall.copyWith(color: c.textMuted),
          ),
          const SizedBox(height: Space.s5),
          PishroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DeckRow(text: r'اخبار ذخیره‌شده'),
                _DeckRow(text: r'جدیدترین ذخیره‌شده'),
                _DeckRow(text: r'جدیدترین خبر'),
                _DeckRow(
                  text: r'قیمت بیت‌کوین در معاملات امروز نوسان محدودی داشت',
                ),
                _DeckRow(text: r'ذخیره‌شده: ۲ روز پیش · انتشار: ۳ روز پیش'),
                _DeckRow(
                  text: r'جمع‌بندی هفتگی بازارهای جهانی و شاخص‌های اصلی',
                ),
                _DeckRow(text: r'ذخیره‌شده: ۵ روز پیش · انتشار: ۶ روز پیش'),
                _DeckRow(text: r'۱۰ · ذخیره‌شده‌ها'),
                _DeckRow(
                  text: r'Overlay — ثبت دیدگاه، اشتراک‌گذاری و گزارش محتوا',
                ),
                _DeckRow(text: r'ثبت دیدگاه'),
                _DeckRow(text: r'دیدگاه خود را بنویسید…'),
                _DeckRow(text: r'۰ از ۳۰۰ نویسه'),
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
