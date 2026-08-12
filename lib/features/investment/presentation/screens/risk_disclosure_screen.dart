import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_button.dart';

/// Screen/Investment/RiskDisclosure — «اطلاع‌رسانی ریسک».
///
/// Source: `../desighn/_capture/06-06-investment-part-1.dc.html` · Android 390dp · RTL.
class RiskDisclosureScreen extends ConsumerWidget {
  const RiskDisclosureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: Space.s5,
        title: Text(
          'اطلاع‌رسانی ریسک',
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
            'اطلاع‌رسانی ریسک',
            style: context.text.h2.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: Space.s2),
          Text(
            'پیاده‌سازی بر اساس دک طراحی · Screen/Investment/RiskDisclosure',
            style: context.text.bodySmall.copyWith(color: c.textMuted),
          ),
          const SizedBox(height: Space.s5),
          PishroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DeckRow(text: r'شرایط و قرارداد'),
                _DeckRow(text: r'قرارداد طرح دریافت ماهیانه ۸٪'),
                _DeckRow(
                  text:
                      r'نسخه ۱٫۲ · انتشار: ۱ خرداد ۱۴۰۵ · آخرین به‌روزرسانی: ۱ تیر ۱۴۰۵',
                ),
                _DeckRow(
                  text: r'متن نمونه — نیازمند جایگزینی با نسخه حقوقی تأییدشده',
                ),
                _DeckRow(text: r'فهرست مطالب'),
                _DeckRow(text: r'۱. شرایط کلی طرح'),
                _DeckRow(text: r'۲. جدول کارمزدها'),
                _DeckRow(text: r'۳. شرایط برداشت و خروج زودهنگام'),
                _DeckRow(text: r'۴. پشتیبانی و رسیدگی به اختلاف'),
                _DeckRow(text: r'دانلود نسخه PDF'),
                _DeckRow(text: r'قرارداد و شرایط طرح را مطالعه کرده‌ام.'),
                _DeckRow(text: r'ادامه پس از مطالعه'),
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
