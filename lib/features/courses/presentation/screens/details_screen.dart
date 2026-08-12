import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_button.dart';

/// Screen/Course/Details — «جزئیات دوره».
///
/// Source: `../desighn/_capture/02-04-courses-part-1.dc.html` · Android 390dp · RTL.
class CourseDetailsScreen extends ConsumerWidget {
  const CourseDetailsScreen({super.key, this.id = ''});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: Space.s5,
        title: Text(
          'جزئیات دوره',
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
            'جزئیات دوره',
            style: context.text.h2.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: Space.s2),
          Text(
            'پیاده‌سازی بر اساس دک طراحی · Screen/Course/Details',
            style: context.text.bodySmall.copyWith(color: c.textMuted),
          ),
          const SizedBox(height: Space.s5),
          PishroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DeckRow(text: r'انتخاب بسته دوره'),
                _DeckRow(text: r'تحلیل تکنیکال از صفر تا معامله‌گری'),
                _DeckRow(text: r'بسته عادی'),
                _DeckRow(text: r'۲٬۴۹۰٬۰۰۰'),
                _DeckRow(text: r'تومان'),
                _DeckRow(text: r'دسترسی کامل به ویدیوهای دوره'),
                _DeckRow(text: r'فایل‌ها و منابع آموزشی'),
                _DeckRow(text: r'گواهی پایان دوره، در صورت ارائه'),
                _DeckRow(text: r'بدون گفت‌وگوی مستقیم با مدرس'),
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
