import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_badge.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/courses_repository.dart';

/// Screen/Course/LearningDashboard — گفت‌وگو فقط برای VIP.
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
          final curr = curriculum.valueOrNull;
          final current = curr?.currentLesson;
          final downloaded = curr?.downloadedCount ?? 0;
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
                  enrolled.hasInstructorChat
                      ? const PishroBadge.vip()
                      : const PishroBadge.regular(),
                ],
              ),
              const SizedBox(height: Space.s4),
              PishroProgress(
                value: enrolled.progress,
                label: enrolled.lessonsTotal == 0
                    ? null
                    : '${Fmt.fa('${enrolled.lessonsCompleted}')} از ${Fmt.fa('${enrolled.lessonsTotal}')} جلسه تکمیل‌شده',
              ),
              if (enrolled.timeSpent.inMinutes > 0) ...[
                const SizedBox(height: Space.s2),
                Text(
                  'زمان صرف‌شده: ${Fmt.duration(enrolled.timeSpent)}',
                  style: context.text.caption.copyWith(color: c.textMuted),
                ),
              ],
              const SizedBox(height: Space.s5),
              if (current != null)
                PishroCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ادامه یادگیری — ${current.title}',
                        style: context.text.bodyMedium.copyWith(
                          color: c.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: Space.s4),
                      PishroButton(
                        label: 'ادامه یادگیری',
                        onPressed: () =>
                            context.push(Routes.lesson(id, current.id)),
                      ),
                    ],
                  ),
                ),
              if (downloaded > 0) ...[
                const SizedBox(height: Space.s3),
                NoticeBanner(
                  message:
                      '${Fmt.fa('$downloaded')} جلسه برای مشاهده آفلاین دانلود شده است.',
                  tone: NoticeTone.info,
                ),
              ],
              const SizedBox(height: Space.s5),
              _Shortcut(
                icon: Icons.view_list_rounded,
                label: 'سرفصل‌های دوره',
                onTap: () => context.push(Routes.chapters(id)),
              ),
              _Shortcut(
                icon: Icons.folder_outlined,
                label: 'منابع و فایل‌های دوره',
                onTap: () => context.push(Routes.downloads(id)),
              ),
              if (enrolled.hasInstructorChat)
                _Shortcut(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'گفت‌وگو با مدرس',
                  trailing: const PishroBadge.vip(),
                  onTap: () => context.push(Routes.instructorChat(id)),
                ),
              if (enrolled.isCompleted)
                _Shortcut(
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

class _Shortcut extends StatelessWidget {
  const _Shortcut({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return PishroCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: Space.s3,
        vertical: Space.s3,
      ),
      child: Row(
        children: [
          Icon(icon, color: c.actionPrimary),
          const SizedBox(width: Space.s3),
          Expanded(
            child: Text(
              label,
              style: context.text.bodyMedium.copyWith(color: c.textPrimary),
            ),
          ),
          if (trailing != null) ...[trailing!, const SizedBox(width: Space.s2)],
          Icon(Icons.chevron_left_rounded, color: c.textMuted),
        ],
      ),
    );
  }
}
