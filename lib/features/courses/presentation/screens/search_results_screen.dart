import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_button.dart';

/// Screen/Courses/SearchResults — «نتایج جست‌وجو».
///
/// Source: `../desighn/_capture/02-04-courses-part-1.dc.html` · Android 390dp · RTL.
class CoursesSearchResultsScreen extends ConsumerWidget {
  const CoursesSearchResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: Space.s5,
        title: Text(
          'نتایج جست‌وجو',
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
            'نتایج جست‌وجو',
            style: context.text.h2.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: Space.s2),
          Text(
            'پیاده‌سازی بر اساس دک طراحی · Screen/Courses/SearchResults',
            style: context.text.bodySmall.copyWith(color: c.textMuted),
          ),
          const SizedBox(height: Space.s5),
          PishroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DeckRow(text: r'عادی'),
                _DeckRow(text: r'★ VIP موجود'),
                _DeckRow(text: r'تحلیل تکنیکال از صفر تا معامله‌گری'),
                _DeckRow(text: r'تیم آموزشی پیشرو سرمایه'),
                _DeckRow(text: r'★ ۴٫۸ (۳۱۰)'),
                _DeckRow(text: r'۱٬۲۴۰ دانشجو'),
                _DeckRow(text: r'مدت'),
                _DeckRow(text: r'۱۲ ساعت'),
                _DeckRow(text: r'سطح'),
                _DeckRow(text: r'مقدماتی'),
                _DeckRow(text: r'به‌روزرسانی'),
                _DeckRow(text: r'تیر ۱۴۰۵'),
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
