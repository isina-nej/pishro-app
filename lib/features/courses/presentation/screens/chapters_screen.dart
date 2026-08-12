import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_button.dart';

/// Screen/Course/Chapters — «سرفصل‌های دوره».
///
/// Source: `../desighn/_capture/03-04-courses-part-2.dc.html` · Android 390dp · RTL.
class ChaptersScreen extends ConsumerWidget {
  const ChaptersScreen({super.key, this.id = ''});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: Space.s5,
        title: Text(
          'سرفصل‌های دوره',
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
            'سرفصل‌های دوره',
            style: context.text.h2.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: Space.s2),
          Text(
            'پیاده‌سازی بر اساس دک طراحی · Screen/Course/Chapters',
            style: context.text.bodySmall.copyWith(color: c.textMuted),
          ),
          const SizedBox(height: Space.s5),
          PishroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DeckRow(
                  text: r'مقدمه‌ای بر ساختار بازارهای مالی و بازیگران اصلی آن',
                ),
                _DeckRow(text: r'۸ دقیقه'),
                _DeckRow(text: r'عرضه و تقاضا و تأثیر آن بر قیمت'),
                _DeckRow(text: r'در حال پخش'),
                _DeckRow(text: r'آشنایی با کارگزاری‌ها و انواع حساب معاملاتی'),
                _DeckRow(text: r'۱۱ دقیقه'),
                _DeckRow(text: r'تمرین شناسایی روند بازار'),
                _DeckRow(text: r'دانلودشده'),
                _DeckRow(text: r'جلسه جمع‌بندی فصل اول'),
                _DeckRow(text: r'دانلود ناموفق بود — تلاش دوباره'),
                _DeckRow(text: r'فصل ۲ — الگوهای قیمتی'),
                _DeckRow(text: r'آشنایی با الگوهای بازگشتی و ادامه‌دهنده'),
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
