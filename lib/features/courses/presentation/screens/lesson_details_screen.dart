import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/courses_repository.dart';

/// Screen/Course/LessonDetails — پخش‌نما + توضیح جلسه.
class LessonDetailsScreen extends ConsumerWidget {
  const LessonDetailsScreen({super.key, this.id = '', this.lessonId = ''});

  final String id;
  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final curriculum = ref.watch(curriculumProvider(id));

    return curriculum.when(
      loading: () => const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(Space.page),
          child: Skeleton.cover(),
        ),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorStateView(
          message: e is ApiException ? e.message : 'جلسه بارگذاری نشد.',
          onRetry: () => ref.invalidate(curriculumProvider(id)),
        ),
      ),
      data: (curr) {
        final lesson = curr.lessonById(lessonId) ?? curr.currentLesson;
        if (lesson == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyState(title: 'این جلسه یافت نشد'),
          );
        }
        if (!lesson.state.isPlayable) {
          return Scaffold(
            appBar: AppBar(title: Text(lesson.title, style: context.text.h3)),
            body: const EmptyState(
              title: 'این جلسه قفل است',
              message: 'پس از خرید یا تکمیل جلسه قبلی باز می‌شود.',
              icon: Icons.lock_outline_rounded,
            ),
          );
        }
        final chapter = curr.chapterOf(lesson.id);
        return Scaffold(
          appBar: AppBar(
            title: Text(
              lesson.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.h3.copyWith(color: c.textPrimary),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(Space.page),
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    color: c.surfaceSecondary,
                    borderRadius: BorderRadius.circular(Radii.card),
                    border: Border.all(color: c.borderDefault),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.play_circle_fill_rounded,
                          size: 56,
                          color: c.actionPrimary,
                        ),
                        const SizedBox(height: Space.s2),
                        Text(
                          'پخش جلسه · ${Fmt.duration(lesson.duration)}',
                          style: context.text.caption.copyWith(
                            color: c.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Space.s4),
              if (chapter != null)
                Text(
                  chapter.title,
                  style: context.text.caption.copyWith(color: c.textMuted),
                ),
              const SizedBox(height: Space.s2),
              Text(
                lesson.title,
                style: context.text.h3.copyWith(color: c.textPrimary),
              ),
              if (lesson.description != null) ...[
                const SizedBox(height: Space.s3),
                Text(
                  lesson.description!,
                  style: context.text.bodySmall.copyWith(
                    color: c.textSecondary,
                    height: 1.8,
                  ),
                ),
              ],
              const SizedBox(height: Space.s6),
              PishroButton(
                label: 'بازگشت به فصل‌ها',
                variant: PishroButtonVariant.secondary,
                onPressed: () => context.push(Routes.chapters(id)),
              ),
            ],
          ),
        );
      },
    );
  }
}
