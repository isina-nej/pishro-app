import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/common.dart';

class LegalDocumentsScreen extends StatelessWidget {
  const LegalDocumentsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'اسناد حقوقی',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          PishroCard(
            child: Text(
              'قوانین استفاده',
              style: context.text.bodyMedium.copyWith(color: c.textPrimary),
            ),
          ),
          const SizedBox(height: Space.s3),
          PishroCard(
            child: Text(
              'سیاست حریم خصوصی',
              style: context.text.bodyMedium.copyWith(color: c.textPrimary),
            ),
          ),
          const SizedBox(height: Space.s3),
          PishroCard(
            child: Text(
              'شرایط سرمایه‌گذاری',
              style: context.text.bodyMedium.copyWith(color: c.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
