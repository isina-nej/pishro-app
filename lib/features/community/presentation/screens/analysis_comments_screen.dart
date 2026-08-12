import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_button.dart';

/// Screen/AnalysisComments — «دیدگاه‌های تحلیل».
///
/// Source: `../desighn/_capture/09-08-community.dc.html` · Android 390dp · RTL.
class AnalysisCommentsScreen extends ConsumerWidget {
  const AnalysisCommentsScreen({super.key, this.id = ''});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: Space.s5,
        title: Text(
          'دیدگاه‌های تحلیل',
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
            'دیدگاه‌های تحلیل',
            style: context.text.h2.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: Space.s2),
          Text(
            'پیاده‌سازی بر اساس دک طراحی · Screen/AnalysisComments',
            style: context.text.bodySmall.copyWith(color: c.textMuted),
          ),
          const SizedBox(height: Space.s5),
          PishroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DeckRow(text: r'انتشار — در انتظار بررسی'),
                _DeckRow(text: r'انتشار تحلیل ناموفق بود'),
                _DeckRow(text: r'پیش‌نویس شما حفظ شده است'),
                _DeckRow(text: r'تلاش دوباره'),
                _DeckRow(text: r'انتشار — ناموفق'),
                _DeckRow(
                  text:
                      r'داده عملکرد تأییدشده برای این رتبه‌بندی در دسترس نیست',
                ),
                _DeckRow(text: r'رتبه‌بندی — بدون داده'),
                _DeckRow(
                  text: r'داده دارایی مرتبط به‌روزرسانی نشده — نسخه ذخیره‌شده',
                ),
                _DeckRow(text: r'جزئیات تحلیل — داده قدیمی'),
                _DeckRow(text: r'اتصال اینترنت برقرار نیست'),
                _DeckRow(text: r'خانه — آفلاین/خطا'),
                _DeckRow(
                  text:
                      r'حالت‌ها و Overlay باقی‌مانده — مستندشده، الگو از تحویل‌های پیشین',
                ),
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
