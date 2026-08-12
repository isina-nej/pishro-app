import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/states.dart';
import '../../../auth/presentation/widgets/consent_checkbox.dart';

/// Screen/Account/Privacy.
class AccountPrivacyScreen extends StatefulWidget {
  const AccountPrivacyScreen({super.key});

  @override
  State<AccountPrivacyScreen> createState() => _AccountPrivacyScreenState();
}

class _AccountPrivacyScreenState extends State<AccountPrivacyScreen> {
  var _personalization = false;
  var _analytics = false;
  var _marketing = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'حریم خصوصی',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          PishroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'پردازش ضروری',
                  style: context.text.bodyMedium.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'ارتباطات امنیتی · ضروری',
                  style: context.text.caption.copyWith(color: c.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.s4),
          Text(
            'اختیاری',
            style: context.text.bodySmall.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: Space.s2),
          ConsentCheckbox(
            value: _personalization,
            onChanged: (v) => setState(() => _personalization = v),
            label: 'پیشنهادهای شخصی‌سازی‌شده',
          ),
          ConsentCheckbox(
            value: _analytics,
            onChanged: (v) => setState(() => _analytics = v),
            label: 'تحلیل رفتار کاربری',
          ),
          ConsentCheckbox(
            value: _marketing,
            onChanged: (v) => setState(() => _marketing = v),
            label: 'پیام‌های بازاریابی',
          ),
          const SizedBox(height: Space.s4),
          PishroButton(
            label: 'دریافت خروجی داده‌های من',
            variant: PishroButtonVariant.secondary,
            onPressed: () {},
          ),
          const SizedBox(height: Space.s3),
          PishroButton(
            label: 'اسناد حقوقی',
            variant: PishroButtonVariant.ghost,
            onPressed: () => context.push(Routes.legalDocuments),
          ),
          const SizedBox(height: Space.s4),
          const NoticeBanner(
            message:
                'درخواست حذف حساب بلافاصله انجام نمی‌شود و نیازمند بررسی خدمات فعال است.',
            tone: NoticeTone.warning,
          ),
        ],
      ),
    );
  }
}
