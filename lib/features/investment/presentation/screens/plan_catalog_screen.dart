import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_button.dart';

/// Screen/Investment/PlanCatalog — «فهرست طرح‌ها».
///
/// Source: `../desighn/_capture/06-06-investment-part-1.dc.html` · Android 390dp · RTL.
class PlanCatalogScreen extends ConsumerWidget {
  const PlanCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: Space.s5,
        title: Text(
          'فهرست طرح‌ها',
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
            'فهرست طرح‌ها',
            style: context.text.h2.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: Space.s2),
          Text(
            'پیاده‌سازی بر اساس دک طراحی · Screen/Investment/PlanCatalog',
            style: context.text.bodySmall.copyWith(color: c.textMuted),
          ),
          const SizedBox(height: Space.s5),
          PishroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DeckRow(text: r'طرح دریافت ماهیانه ۸٪'),
                _DeckRow(text: r'نرخ اعلام‌شده طرح'),
                _DeckRow(text: r'۸٪'),
                _DeckRow(text: r'ماهیانه'),
                _DeckRow(text: r'طبق شرایط و نحوه محاسبه قرارداد'),
                _DeckRow(
                  text:
                      r'این نرخ به‌تنهایی به معنای تضمین پرداخت یا نبود ریسک نیست.',
                ),
                _DeckRow(text: r'سطح ریسک: متوسط — مشاهده جزئیات ریسک'),
                _DeckRow(text: r'مدت طرح'),
                _DeckRow(text: r'مقدار نمونه'),
                _DeckRow(text: r'حداقل / حداکثر مبلغ'),
                _DeckRow(text: r'۱۰٬۰۰۰٬۰۰۰ تا مقدار نمونه'),
                _DeckRow(text: r'شرایط برداشت'),
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
