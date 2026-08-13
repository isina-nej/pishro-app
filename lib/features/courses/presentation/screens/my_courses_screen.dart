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
import '../../../../shared/widgets/pishro_chip.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/courses_models.dart';
import '../../data/courses_repository.dart';

/// Screen/Courses/MyCourses — تب‌ها؛ گفت‌وگوی مدرس فقط روی VIP.
class MyCoursesScreen extends ConsumerStatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  ConsumerState<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends ConsumerState<MyCoursesScreen> {
  var _tab = MyCoursesTab.inProgress;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enrolled = ref.watch(enrolledCoursesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'دوره‌های من',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: Column(
        children: [
          PishroChipBar(
            labels: [for (final t in MyCoursesTab.values) t.label],
            selectedIndex: _tab.index,
            onSelected: (i) => setState(() => _tab = MyCoursesTab.values[i]),
          ),
          Expanded(
            child: enrolled.when(
              loading: () => ListView(
                padding: const EdgeInsets.all(Space.page),
                children: const [
                  Skeleton.box(height: 110),
                  SizedBox(height: Space.s3),
                  Skeleton.box(height: 110),
                ],
              ),
              error: (e, _) => ErrorStateView(
                message: e is ApiException
                    ? e.message
                    : 'دوره‌های شما بارگذاری نشد.',
                onRetry: () => ref.invalidate(enrolledCoursesProvider),
              ),
              data: (all) {
                final items = [
                  for (final e in all)
                    if (_tab.accepts(e)) e,
                ];
                if (items.isEmpty) {
                  return EmptyState(
                    title: _tab == MyCoursesTab.completed
                        ? 'هنوز دوره‌ای را تمام نکرده‌اید'
                        : 'هنوز دوره‌ای شروع نکرده‌اید',
                    message: 'از میان دوره‌های پیشنهادی شروع کنید.',
                    actionLabel: 'مشاهده دوره‌ها',
                    onAction: () => context.go(Routes.courses),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(enrolledCoursesProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(Space.page),
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: Space.s3),
                    itemBuilder: (_, i) {
                      final e = items[i];
                      return PishroCard(
                        onTap: () =>
                            context.push(Routes.learningDashboard(e.course.id)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    e.course.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.text.bodyMedium.copyWith(
                                      color: c.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (e.hasInstructorChat)
                                  const PishroBadge.vip()
                                else
                                  const PishroBadge.regular(),
                              ],
                            ),
                            const SizedBox(height: Space.s3),
                            Text(
                              '${Fmt.fa('${e.progressPercent}')}٪',
                              style: context.text.h3.copyWith(
                                color: c.textPrimary,
                              ),
                            ),
                            const SizedBox(height: Space.s1),
                            Text(
                              e.lessonProgressLabel,
                              style: context.text.caption.copyWith(
                                color: c.textMuted,
                              ),
                            ),
                            const SizedBox(height: Space.s3),
                            PishroProgress(
                              value: e.progress,
                              showPercent: false,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
