import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_button.dart';

/// Screen/Course/Certificate — «گواهی».
///
/// Source: `../desighn/_capture/04-04-courses-part-3.dc.html` · Android 390dp · RTL.
class CertificateScreen extends ConsumerWidget {
  const CertificateScreen({super.key, this.id = ''});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: Space.s5,
        title: Text(
          'گواهی',
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
          Text('گواهی', style: context.text.h2.copyWith(color: c.textPrimary)),
          const SizedBox(height: Space.s2),
          Text(
            'پیاده‌سازی بر اساس دک طراحی · Screen/Course/Certificate',
            style: context.text.bodySmall.copyWith(color: c.textMuted),
          ),
          const SizedBox(height: Space.s5),
          PishroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DeckRow(text: r'گواهی پایان دوره'),
                _DeckRow(text: r'پیشرو سرمایه'),
                _DeckRow(text: r'این گواهی تقدیم می‌شود به'),
                _DeckRow(text: r'نام کاربر نمونه'),
                _DeckRow(text: r'برای گذراندن موفق دوره'),
                _DeckRow(text: r'تحلیل تکنیکال از صفر تا معامله‌گری'),
                _DeckRow(text: r'تاریخ صدور'),
                _DeckRow(text: r'۶ مرداد ۱۴۰۵'),
                _DeckRow(text: r'شناسه گواهی'),
                _DeckRow(text: r'دانلود گواهی'),
                _DeckRow(text: r'۰۵ · گواهی'),
                _DeckRow(
                  text:
                      r'Screen/Course/Certificate · قاب سبز، تزئین طلایی کم‌مصرف',
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
