import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_button.dart';

/// Screen/Checkout/PaymentProcessing — «در حال پردازش».
///
/// Source: `../desighn/_capture/03-04-courses-part-2.dc.html` · Android 390dp · RTL.
class PaymentProcessingScreen extends ConsumerWidget {
  const PaymentProcessingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: Space.s5,
        title: Text(
          'در حال پردازش',
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
            'در حال پردازش',
            style: context.text.h2.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: Space.s2),
          Text(
            'پیاده‌سازی بر اساس دک طراحی · Screen/Checkout/PaymentProcessing',
            style: context.text.bodySmall.copyWith(color: c.textMuted),
          ),
          const SizedBox(height: Space.s5),
          PishroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DeckRow(text: r'پرداخت با موفقیت انجام شد'),
                _DeckRow(text: r'دسترسی به دوره برای شما فعال شد.'),
                _DeckRow(text: r'دوره'),
                _DeckRow(text: r'تحلیل تکنیکال از صفر تا معامله‌گری'),
                _DeckRow(text: r'شماره پیگیری'),
                _DeckRow(text: r'TXN-2K9-۸۸۲۱'),
                _DeckRow(text: r'مبلغ پرداخت‌شده'),
                _DeckRow(text: r'۲٬۴۹۰٬۰۰۰ تومان'),
                _DeckRow(text: r'تاریخ'),
                _DeckRow(text: r'۶ مرداد ۱۴۰۵'),
                _DeckRow(text: r'شروع یادگیری'),
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
