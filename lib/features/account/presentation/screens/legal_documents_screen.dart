import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_badge.dart';
import '../../../../shared/widgets/states.dart';

/// Screen/Account/LegalDocuments.
class LegalDocumentsScreen extends StatelessWidget {
  const LegalDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'اسناد و قوانین',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          const _Doc(
            title: 'قوانین و شرایط استفاده',
            meta: 'نسخه ۲٫۱ · ۱ تیر ۱۴۰۵',
            accepted: true,
          ),
          const SizedBox(height: Space.s3),
          const _Doc(
            title: 'شرایط طرح سرمایه‌گذاری و ریسک',
            meta: 'نسخه جدید نیازمند بررسی و تأیید است.',
            accepted: false,
          ),
          const SizedBox(height: Space.s3),
          const _Doc(
            title: 'سیاست حریم خصوصی',
            meta: 'نسخه ۱٫۴ · ۱۵ خرداد ۱۴۰۵',
            accepted: true,
          ),
          const SizedBox(height: Space.s3),
          const _Doc(
            title: 'قوانین کوین پیشرو',
            meta: 'نسخه ۱٫۰',
            accepted: true,
          ),
          const SizedBox(height: Space.s4),
          const NoticeBanner(
            message: 'هیچ سندی به‌صورت خودکار تأیید نمی‌شود.',
            tone: NoticeTone.info,
          ),
        ],
      ),
    );
  }
}

class _Doc extends StatelessWidget {
  const _Doc({required this.title, required this.meta, required this.accepted});

  final String title;
  final String meta;
  final bool accepted;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return PishroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: context.text.bodyMedium.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              PishroBadge(
                label: accepted ? 'پذیرفته‌شده' : 'نیازمند تأیید',
                tone: accepted
                    ? PishroBadgeTone.success
                    : PishroBadgeTone.warning,
                icon: accepted
                    ? Icons.check_rounded
                    : Icons.info_outline_rounded,
              ),
            ],
          ),
          const SizedBox(height: Space.s2),
          Text(meta, style: context.text.caption.copyWith(color: c.textMuted)),
        ],
      ),
    );
  }
}
