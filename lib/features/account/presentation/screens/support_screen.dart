import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/states.dart';

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
          const NoticeBanner(
            message: 'پاسخگویی معمولاً تا یک روز کاری است.',
            tone: NoticeTone.info,
          ),
          const SizedBox(height: Space.s4),
          PishroCard(
            child: Text(
              'برای پیگیری سفارش، شناسه پرداخت را در پیام ذکر کنید.',
              style: context.text.bodySmall.copyWith(color: c.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
