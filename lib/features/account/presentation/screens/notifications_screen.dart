import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_button.dart';

/// Screen/Account/Notifications — «اعلان‌ها».
///
/// Source: `../desighn/_capture/11-09-account-part-2.dc.html` · Android 390dp · RTL.
class AccountNotificationsScreen extends ConsumerWidget {
  const AccountNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: Space.s5,
        title: Text(
          'اعلان‌ها',
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
            'اعلان‌ها',
            style: context.text.h2.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: Space.s2),
          Text(
            'پیاده‌سازی بر اساس دک طراحی · Screen/Account/Notifications',
            style: context.text.bodySmall.copyWith(color: c.textMuted),
          ),
          const SizedBox(height: Space.s5),
          PishroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DeckRow(text: r'امنیت حساب'),
                _DeckRow(text: r'رمز عبور'),
                _DeckRow(text: r'۴۰ روز پیش'),
                _DeckRow(text: r'تأیید دومرحله‌ای'),
                _DeckRow(text: r'غیرفعال'),
                _DeckRow(text: r'ورود با اثر انگشت'),
                _DeckRow(text: r'فعال'),
                _DeckRow(text: r'نشست‌های فعال'),
                _DeckRow(text: r'۲ دستگاه'),
                _DeckRow(text: r'توصیه‌های امنیتی'),
                _DeckRow(
                  text:
                      r'فعال‌سازی تأیید دومرحله‌ای امنیت حساب را افزایش می‌دهد.',
                ),
                _DeckRow(text: r'خروج از همه دستگاه‌ها'),
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
