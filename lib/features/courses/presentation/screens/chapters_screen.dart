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
import '../../../../shared/widgets/states.dart';
import '../../data/courses_models.dart';
import '../../data/courses_repository.dart';

/// Screen/Course/Chapters — ۷ حالت درس = آیکون + برچسب.
class ChaptersScreen extends ConsumerWidget {
  const ChaptersScreen({super.key, this.id = ''});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final curriculum = ref.watch(curriculumProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'سرفصل‌های دوره',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: curriculum.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(Space.page),
          children: const [
            Skeleton.line(width: 180),
            SizedBox(height: Space.s3),
            Skeleton.box(height: 64),
            SizedBox(height: Space.s2),
            Skeleton.box(height: 64),
          ],
        ),
        error: (e, _) => ErrorStateView(
          message: e is ApiException ? e.message : 'سرفصل‌ها بارگذاری نشد.',
          onRetry: () => ref.invalidate(curriculumProvider(id)),
        ),
        data: (curr) {
          if (curr.chapters.isEmpty) {
            return const EmptyState(title: 'سرفصلی برای این دوره نیست');
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              Space.page,
              Space.s3,
              Space.page,
              Space.s8,
            ),
            itemCount: curr.chapters.length,
            itemBuilder: (_, i) {
              final ch = curr.chapters[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: Space.s5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ch.title,
                      style: context.text.bodyMedium.copyWith(
                        color: c.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: Space.s1),
                    Text(
                      ch.summary,
                      style: context.text.caption.copyWith(color: c.textMuted),
                    ),
                    const SizedBox(height: Space.s3),
                    for (final lesson in ch.lessons)
                      Padding(
                        padding: const EdgeInsets.only(bottom: Space.s2),
                        child: _LessonTile(
                          lesson: lesson,
                          onTap: lesson.state.isPlayable
                              ? () => context.push(Routes.lesson(id, lesson.id))
                              : null,
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({required this.lesson, this.onTap});

  final Lesson lesson;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (icon, color, label) = switch (lesson.state) {
      LessonState.completed => (
        Icons.check_circle_rounded,
        c.success,
        'تکمیل‌شده',
      ),
      LessonState.current => (
        Icons.play_circle_fill_rounded,
        c.actionPrimary,
        'در حال پخش',
      ),
      LessonState.available => (
        Icons.play_circle_outline_rounded,
        c.textSecondary,
        Fmt.duration(lesson.duration),
      ),
      LessonState.downloaded => (
        Icons.download_done_rounded,
        c.info,
        'دانلودشده',
      ),
      LessonState.locked => (Icons.lock_outline_rounded, c.textMuted, 'قفل'),
      LessonState.preview => (Icons.visibility_outlined, c.info, 'پیش‌نمایش'),
      LessonState.downloadFailed => (
        Icons.error_outline_rounded,
        c.danger,
        'دانلود ناموفق بود — تلاش دوباره',
      ),
    };
    return PishroCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: Space.s3,
        vertical: Space.s3,
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: Space.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.title,
                  style: context.text.bodySmall.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(label, style: context.text.caption.copyWith(color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
