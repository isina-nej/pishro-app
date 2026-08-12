import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/routes.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/pishro_badge.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/states.dart';
import '../../../account/data/account_repository.dart';
import '../../data/courses_repository.dart';

/// Screen/Course/Certificate — قاب سبز + طلا کم‌مصرف.
class CertificateScreen extends ConsumerWidget {
  const CertificateScreen({super.key, this.id = ''});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final enrollment = ref.watch(enrollmentProvider(id));
    final profile = ref.watch(accountProfileProvider);
    final e = enrollment.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'گواهی پایان دوره',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: e == null
          ? const EmptyState(title: 'گواهی در دسترس نیست')
          : !e.isCompleted
          ? EmptyState(
              title: 'برای دریافت گواهی، ابتدا همه جلسات را تکمیل کنید',
              message: e.lessonProgressLabel,
              actionLabel: 'ادامه یادگیری',
              onAction: () => context.go(Routes.learningDashboard(id)),
            )
          : ListView(
              padding: const EdgeInsets.all(Space.page),
              children: [
                Container(
                  padding: const EdgeInsets.all(Space.s6),
                  decoration: BoxDecoration(
                    color: c.surfacePrimary,
                    borderRadius: BorderRadius.circular(Radii.card),
                    border: Border.all(color: c.actionPrimary, width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'پیشرو سرمایه',
                        style: context.text.caption.copyWith(
                          color: c.actionPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: Space.s2),
                      const PishroBadge(
                        label: 'گواهی پایان دوره',
                        tone: PishroBadgeTone.premium,
                        icon: Icons.workspace_premium_rounded,
                      ),
                      const SizedBox(height: Space.s5),
                      Text(
                        'این گواهی تقدیم می‌شود به',
                        style: context.text.caption.copyWith(
                          color: c.textMuted,
                        ),
                      ),
                      const SizedBox(height: Space.s2),
                      Text(
                        profile.valueOrNull?.displayName ?? 'نام کاربر نمونه',
                        textAlign: TextAlign.center,
                        style: context.text.h2.copyWith(color: c.textPrimary),
                      ),
                      const SizedBox(height: Space.s3),
                      Text(
                        'برای گذراندن موفق دوره',
                        style: context.text.caption.copyWith(
                          color: c.textMuted,
                        ),
                      ),
                      const SizedBox(height: Space.s2),
                      Text(
                        e.course.title,
                        textAlign: TextAlign.center,
                        style: context.text.h3.copyWith(color: c.textPrimary),
                      ),
                      const SizedBox(height: Space.s4),
                      Text(
                        'این گواهی از طریق شناسه گواهی در وب‌سایت پیشرو سرمایه قابل استعلام است.',
                        textAlign: TextAlign.center,
                        style: context.text.caption.copyWith(
                          color: c.textMuted,
                        ),
                      ),
                      const SizedBox(height: Space.s4),
                      _Meta(
                        'تاریخ صدور',
                        e.completedAt == null
                            ? Fmt.jalaliLong(DateTime.now())
                            : Fmt.jalaliLong(e.completedAt!),
                      ),
                      _Meta(
                        'شناسه گواهی',
                        'PS-CERT-${Fmt.fa(e.enrollmentId.padLeft(4, '0'))}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Space.s5),
                PishroButton(
                  label: 'دانلود گواهی',
                  variant: PishroButtonVariant.secondary,
                  onPressed: () {},
                ),
              ],
            ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.s2),
      child: Row(
        children: [
          Text(label, style: context.text.caption.copyWith(color: c.textMuted)),
          const Spacer(),
          Text(
            value,
            style: context.text.bodySmall.copyWith(
              color: c.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
