import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/states.dart';

class KYCVerificationScreen extends StatelessWidget {
  const KYCVerificationScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ارسال مدارک',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          const NoticeBanner(
            message: 'بارگذاری مدارک هنوز به API وصل نیست.',
            tone: NoticeTone.info,
          ),
          const SizedBox(height: Space.s5),
          PishroButton(
            label: 'بازگشت',
            variant: PishroButtonVariant.secondary,
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }
}
