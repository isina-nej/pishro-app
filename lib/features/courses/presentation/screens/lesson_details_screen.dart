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
import '../../data/courses_models.dart';
import '../../data/courses_repository.dart';
import '../widgets/course_widgets.dart';

/// Screen/Course/LessonDetails — دانلود + تکمیل.
class LessonDetailsScreen extends ConsumerStatefulWidget {
  const LessonDetailsScreen({super.key, this.id = '', this.lessonId = ''});

  final String id;
  final String lessonId;

  @override
  ConsumerState<LessonDetailsScreen> createState() =>
      _LessonDetailsScreenState();
}

class _LessonDetailsScreenState extends ConsumerState<LessonDetailsScreen> {
  var _downloaded = false;
  var _completed = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final curriculum = ref.watch(curriculumProvider(widget.id));

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
          onRetry: () => ref.invalidate(curriculumProvider(widget.id)),
        ),
      ),
      data: (curr) {
        final lesson = curr.lessonById(widget.lessonId) ?? curr.currentLesson;
        if (lesson == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyState(title: 'این جلسه یافت نشد'),
          );
        }
        if (!lesson.state.isPlayable) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                lesson.title,
                style: context.text.h3.copyWith(color: c.textPrimary),
              ),
            ),
            body: EmptyState(
              title: 'این جلسه قفل است',
              message: 'پس از تکمیل جلسات قبلی فصل، این جلسه باز می‌شود.',
              icon: Icons.lock_outline_rounded,
              actionLabel: 'ادامه از جلسه فعلی',
              onAction: () {
                final current = curr.currentLesson;
                if (current == null) return;
                context.push(Routes.lesson(widget.id, current.id));
              },
            ),
          );
        }
        final chapter = curr.chapterOf(lesson.id);
        final chapterIndex = chapter == null
            ? 0
            : curr.chapters.indexOf(chapter) + 1;
        final lessonIndex = chapter == null
            ? 0
            : chapter.lessons.indexWhere((l) => l.id == lesson.id) + 1;
        final next = _nextPlayable(curr, lesson.id);

        return Scaffold(
          appBar: AppBar(
            title: Text(
              chapter == null
                  ? lesson.title
                  : 'فصل ${Fmt.fa('$chapterIndex')} · جلسه ${Fmt.fa('$lessonIndex')}',
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
                          '${Fmt.duration(lesson.duration)} · سرعت ۱x · زیرنویس',
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
              const SizedBox(height: Space.s5),
              Row(
                children: [
                  Expanded(
                    child: PishroButton(
                      label: _downloaded ? 'دانلودشده' : 'دانلود جلسه',
                      variant: PishroButtonVariant.secondary,
                      icon: _downloaded
                          ? Icons.download_done_rounded
                          : Icons.download_rounded,
                      onPressed: _downloaded
                          ? null
                          : () => setState(() => _downloaded = true),
                    ),
                  ),
                  const SizedBox(width: Space.s3),
                  Expanded(
                    child: PishroButton(
                      label: _completed || lesson.state == LessonState.completed
                          ? 'تکمیل‌شده'
                          : 'علامت تکمیل',
                      icon: Icons.check_rounded,
                      onPressed:
                          _completed || lesson.state == LessonState.completed
                          ? null
                          : () => setState(() => _completed = true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Space.s6),
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: c.surfaceSecondary,
                    child: Icon(Icons.school_outlined, color: c.actionPrimary),
                  ),
                  const SizedBox(width: Space.s3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ref
                                  .watch(courseProvider(widget.id))
                                  .valueOrNull
                                  ?.instructorName ??
                              'مدرس این دوره',
                          style: context.text.bodySmall.copyWith(
                            color: c.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'مدرس این دوره',
                          style: context.text.caption.copyWith(
                            color: c.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Space.s5),
              Text(
                'نظرات دانشجویان',
                style: context.text.bodyMedium.copyWith(
                  color: c.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: Space.s2),
              const RatingLabel(4.8, count: 310),
              const SizedBox(height: Space.s6),
              if (next != null)
                PishroButton(
                  label: 'جلسه بعدی',
                  onPressed: () =>
                      context.push(Routes.lesson(widget.id, next.id)),
                )
              else
                PishroButton(
                  label: 'بازگشت به سرفصل‌ها',
                  variant: PishroButtonVariant.secondary,
                  onPressed: () => context.push(Routes.chapters(widget.id)),
                ),
            ],
          ),
        );
      },
    );
  }

  Lesson? _nextPlayable(Curriculum curr, String currentId) {
    final all = curr.lessons;
    final i = all.indexWhere((l) => l.id == currentId);
    if (i < 0) return null;
    for (var j = i + 1; j < all.length; j++) {
      if (all[j].state.isPlayable) return all[j];
    }
    return null;
  }
}
