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

/// Screen/Course/Chapters — هفت حالت درس با آیکون + متن.
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
          'فصل‌ها',
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
                padding: const EdgeInsets.only(bottom: Space.s4),
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
                      _LessonTile(
                        lesson: lesson,
                        onTap: lesson.state.isPlayable
                            ? () => context.push(Routes.lesson(id, lesson.id))
                            : null,
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
    final (icon, color) = switch (lesson.state) {
      LessonState.completed => (Icons.check_circle_rounded, c.success),
      LessonState.current => (Icons.play_circle_fill_rounded, c.actionPrimary),
      LessonState.available => (
        Icons.play_circle_outline_rounded,
        c.textSecondary,
      ),
      LessonState.downloaded => (Icons.download_done_rounded, c.info),
      LessonState.locked => (Icons.lock_outline_rounded, c.textMuted),
      LessonState.preview => (Icons.visibility_outlined, c.info),
      LessonState.downloadFailed => (Icons.error_outline_rounded, c.danger),
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
                Text(
                  [
                    Fmt.duration(lesson.duration),
                    if (lesson.state.label.isNotEmpty) lesson.state.label,
                  ].join(' · '),
                  style: context.text.caption.copyWith(color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
