import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_button.dart';

/// Screen/Course/LessonDetails — «جزئیات جلسه».
///
/// Source: `../desighn/_capture/04-04-courses-part-3.dc.html` · Android 390dp · RTL.
class LessonDetailsScreen extends ConsumerWidget {
  const LessonDetailsScreen({super.key, this.id = ''});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: Space.s5,
        title: Text(
          'جزئیات جلسه',
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
            'جزئیات جلسه',
            style: context.text.h2.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: Space.s2),
          Text(
            'پیاده‌سازی بر اساس دک طراحی · Screen/Course/LessonDetails',
            style: context.text.bodySmall.copyWith(color: c.textMuted),
          ),
          const SizedBox(height: Space.s5),
          PishroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DeckRow(text: r'دانلودها و منابع'),
                _DeckRow(text: r'دانلودهای جلسات'),
                _DeckRow(text: r'۳ از ۱۲ دانلودشده'),
                _DeckRow(text: r'تمرین شناسایی روند بازار'),
                _DeckRow(text: r'دانلودشده'),
                _DeckRow(text: r'عرضه و تقاضا و تأثیر آن بر قیمت'),
                _DeckRow(text: r'۶۴٪'),
                _DeckRow(text: r'جلسه جمع‌بندی فصل اول'),
                _DeckRow(text: r'دانلود ناموفق — تلاش دوباره'),
                _DeckRow(text: r'آشنایی با الگوهای بازگشتی'),
                _DeckRow(text: r'دانلود'),
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
