import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../data/courses_repository.dart';

/// Screen/Course/Completion — بدون کانفتی.
class CompletionScreen extends ConsumerWidget {
  const CompletionScreen({super.key, this.id = ''});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final enrollment = ref.watch(enrollmentProvider(id));
    final e = enrollment.valueOrNull;
    final curriculum = ref.watch(curriculumProvider(id)).valueOrNull;

    if (e != null && !e.isCompleted) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'تکمیل دوره',
            style: context.text.h3.copyWith(color: c.textPrimary),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(Space.page),
          child: Column(
            children: [
              const Spacer(),
              Icon(Icons.flag_outlined, size: 48, color: c.warning),
              const SizedBox(height: Space.s4),
              Text(
                'برای دریافت گواهی، ابتدا همه جلسات را تکمیل کنید',
                textAlign: TextAlign.center,
                style: context.text.h3.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: Space.s2),
              Text(
                e.lessonProgressLabel,
                style: context.text.bodySmall.copyWith(color: c.textMuted),
              ),
              const Spacer(),
              PishroButton(
                label: 'ادامه یادگیری',
                onPressed: () => context.go(Routes.learningDashboard(id)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تکمیل دوره',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          Icon(Icons.check_circle_rounded, size: 56, color: c.success),
          const SizedBox(height: Space.s4),
          Text(
            'دوره را با موفقیت به پایان رساندید',
            textAlign: TextAlign.center,
            style: context.text.h2.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: Space.s2),
          Text(
            e?.course.title ?? 'دوره',
            textAlign: TextAlign.center,
            style: context.text.bodyMedium.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: Space.s5),
          PishroCard(
            child: Column(
              children: [
                _Row(
                  'جلسات تکمیل‌شده',
                  e == null || e.lessonsTotal == 0
                      ? '—'
                      : '${Fmt.fa('${e.lessonsCompleted}')} از ${Fmt.fa('${e.lessonsTotal}')}',
                ),
                _Row(
                  'زمان کل صرف‌شده',
                  e == null || e.timeSpent.inMinutes == 0
                      ? '—'
                      : Fmt.duration(e.timeSpent),
                ),
                _Row(
                  'تاریخ تکمیل',
                  e?.completedAt == null
                      ? '—'
                      : Fmt.jalaliLong(e!.completedAt!),
                ),
                _Row(
                  'فایل‌های دانلودشده',
                  curriculum == null
                      ? '—'
                      : '${Fmt.fa('${curriculum.downloadedCount}')} فایل',
                ),
                // Lesson notes have no endpoint; the row stays but never
                // shows a fabricated count.
                const _Row('یادداشت‌های ثبت‌شده', 'داده در دسترس نیست'),
              ],
            ),
          ),
          const SizedBox(height: Space.s4),
          PishroButton(
            label: 'ثبت نظر درباره این دوره',
            variant: PishroButtonVariant.ghost,
            onPressed: () => context.push(Routes.courseDetails(id)),
          ),
          const SizedBox(height: Space.s6),
          PishroButton(
            label: 'مشاهده گواهی',
            onPressed: () => context.push(Routes.certificate(id)),
          ),
          const SizedBox(height: Space.s3),
          PishroButton(
            label: 'بازگشت به دوره‌های من',
            variant: PishroButtonVariant.secondary,
            onPressed: () => context.go(Routes.myCourses),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
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
