import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_badge.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/courses_models.dart';
import '../../data/courses_repository.dart';

/// Screen/Course/LearningDashboard — پیشرفت + ادامه از آخرین جلسه.
class LearningDashboardScreen extends ConsumerWidget {
  const LearningDashboardScreen({super.key, this.id = ''});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final enrollment = ref.watch(enrollmentProvider(id));
    final curriculum = ref.watch(curriculumProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'داشبورد یادگیری',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: enrollment.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(Space.page),
          child: Column(
            children: [
              Skeleton.line(width: 200),
              SizedBox(height: Space.s4),
              Skeleton.box(height: 80),
            ],
          ),
        ),
        error: (e, _) => ErrorStateView(
          message: e is ApiException ? e.message : 'داشبورد بارگذاری نشد.',
          onRetry: () => ref.invalidate(enrollmentProvider(id)),
        ),
        data: (enrolled) {
          if (enrolled == null) {
            return EmptyState(
              title: 'در این دوره ثبت‌نام نشده‌اید',
              actionLabel: 'مشاهده دوره',
              onAction: () => context.go(Routes.courseDetails(id)),
            );
          }
          final current = curriculum.valueOrNull?.currentLesson;
          return ListView(
            padding: const EdgeInsets.all(Space.page),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      enrolled.course.title,
                      style: context.text.h3.copyWith(color: c.textPrimary),
                    ),
                  ),
                  enrolled.packageType == PackageType.vip
                      ? const PishroBadge.vip()
                      : const PishroBadge.regular(),
                ],
              ),
              const SizedBox(height: Space.s4),
              PishroProgress(
                value: enrolled.progress,
                label: enrolled.lessonProgressLabel,
              ),
              const SizedBox(height: Space.s5),
              if (current != null)
                PishroCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ادامه از آخرین جلسه',
                        style: context.text.caption.copyWith(
                          color: c.textMuted,
                        ),
                      ),
                      const SizedBox(height: Space.s2),
                      Text(
                        current.title,
                        style: context.text.bodyMedium.copyWith(
                          color: c.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: Space.s4),
                      PishroButton(
                        label: 'پخش جلسه',
                        onPressed: () =>
                            context.push(Routes.lesson(id, current.id)),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: Space.s4),
              _NavRow(
                icon: Icons.view_list_rounded,
                label: 'فصل‌ها و جلسات',
                onTap: () => context.push(Routes.chapters(id)),
              ),
              _NavRow(
                icon: Icons.download_rounded,
                label: 'دانلودها و منابع',
                onTap: () => context.push(Routes.downloads(id)),
              ),
              _NavRow(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'گفت‌وگو با مدرس',
                onTap: () => context.push(Routes.instructorChat(id)),
              ),
              if (enrolled.isCompleted)
                _NavRow(
                  icon: Icons.workspace_premium_rounded,
                  label: 'گواهی پایان دوره',
                  onTap: () => context.push(Routes.certificate(id)),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: c.textSecondary),
      title: Text(
        label,
        style: context.text.bodyMedium.copyWith(color: c.textPrimary),
      ),
      trailing: Icon(Icons.chevron_left_rounded, color: c.textMuted),
      onTap: onTap,
    );
  }
}
