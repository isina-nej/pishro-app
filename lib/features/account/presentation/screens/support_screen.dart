import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_badge.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/pishro_text_field.dart';
import '../../../../shared/widgets/states.dart';

/// Screen/Account/Support.
class AccountSupportScreen extends StatelessWidget {
  const AccountSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'پشتیبانی',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          const PishroTextField(
            label: 'جستجو در مقالات راهنما',
            hint: 'احراز هویت، پرداخت، دوره‌ها…',
          ),
          const SizedBox(height: Space.s4),
          PishroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مسائل امنیتی فوری',
                  style: context.text.bodyMedium.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'اگر ورود مشکوک دیدید، از امنیت حساب اقدام کنید.',
                  style: context.text.caption.copyWith(color: c.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.s5),
          Text(
            'تیکت‌های من',
            style: context.text.bodyMedium.copyWith(
              color: c.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: Space.s3),
          PishroCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مشکل در پرداخت سرمایه‌گذاری',
                        style: context.text.bodySmall.copyWith(
                          color: c.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'TCK-2291 · ۲ روز پیش',
                        style: context.text.caption.copyWith(
                          color: c.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const PishroBadge(
                  label: 'در حال بررسی',
                  tone: PishroBadgeTone.warning,
                  icon: Icons.hourglass_top_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.s4),
          const NoticeBanner(
            message:
                'پاسخگویی معمولاً تا یک روز کاری است. ساعت یا شماره تماس اختراعی نمایش داده نمی‌شود.',
            tone: NoticeTone.info,
          ),
          const SizedBox(height: Space.s4),
          PishroButton(label: 'ثبت درخواست جدید', onPressed: () {}),
        ],
      ),
    );
  }
}
