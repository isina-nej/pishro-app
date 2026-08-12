import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_button.dart';

/// Screen/Community/RecommendedAnalysts — «تحلیلگران پیشنهادی».
///
/// Source: `../desighn/_capture/09-08-community.dc.html` · Android 390dp · RTL.
class RecommendedAnalystsScreen extends ConsumerWidget {
  const RecommendedAnalystsScreen({super.key, this.id = ''});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: Space.s5,
        title: Text(
          'تحلیلگران پیشنهادی',
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
            'تحلیلگران پیشنهادی',
            style: context.text.h2.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: Space.s2),
          Text(
            'پیاده‌سازی بر اساس دک طراحی · Screen/Community/RecommendedAnalysts',
            style: context.text.bodySmall.copyWith(color: c.textMuted),
          ),
          const SizedBox(height: Space.s5),
          PishroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DeckRow(text: r'رتبه‌بندی تحلیلگران'),
                _DeckRow(text: r'این ماه'),
                _DeckRow(text: r'این هفته'),
                _DeckRow(text: r'همه دوره‌ها'),
                _DeckRow(text: r'امتیاز کاربران'),
                _DeckRow(text: r'مشارکت جامعه'),
                _DeckRow(text: r'تحلیلگر نمونه ۴'),
                _DeckRow(text: r'۲۱ تحلیل · ۸۴ نظر'),
                _DeckRow(text: r'★ ۴٫۶'),
                _DeckRow(text: r'تحلیلگر نمونه ۱'),
                _DeckRow(text: r'۱۵ تحلیل · ۶۲ نظر'),
                _DeckRow(text: r'★ ۴٫۵'),
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
