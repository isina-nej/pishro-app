import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/pishro_button.dart';

class AccountPrivacyScreen extends StatelessWidget {
  const AccountPrivacyScreen({super.key});
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
          Text(
            'داده‌های حساب فقط برای ارائه خدمات پیشرو سرمایه استفاده می‌شود. جزئیات در اسناد حقوقی آمده است.',
            style: context.text.bodySmall.copyWith(
              color: c.textSecondary,
              height: 1.9,
            ),
          ),
          const SizedBox(height: Space.s4),
          PishroButton(
            label: 'اسناد حقوقی',
            variant: PishroButtonVariant.secondary,
            onPressed: () => context.push(Routes.legalDocuments),
          ),
        ],
      ),
    );
  }
}
