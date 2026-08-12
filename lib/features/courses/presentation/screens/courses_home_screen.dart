import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_chip.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/courses_repository.dart';
import '../widgets/course_widgets.dart';

/// Screen/Courses/Home — «دوره‌ها (خانه)».
///
/// Foundations + Courses Part 1: greeting, chips, featured row, latest list.
/// States: Default / Skeleton / Empty.
class CoursesHomeScreen extends ConsumerStatefulWidget {
  const CoursesHomeScreen({super.key});

  @override
  ConsumerState<CoursesHomeScreen> createState() => _CoursesHomeScreenState();
}

class _CoursesHomeScreenState extends ConsumerState<CoursesHomeScreen> {
  int _chip = 0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final catalog = ref.watch(courseCatalogProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: Space.s5,
        title: Text(
          'دوره‌ها',
          style: context.text.h2.copyWith(color: c.textPrimary),
        ),
        actions: [
          IconButton(
            tooltip: 'جست‌وجو',
            onPressed: () => context.push(Routes.courseSearch),
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            tooltip: 'دسته‌بندی‌ها',
            onPressed: () => context.push(Routes.courseCategories),
            icon: const Icon(Icons.grid_view_rounded),
          ),
          IconButton(
            tooltip: 'دوره‌های من',
            onPressed: () => context.push(Routes.myCourses),
            icon: const Icon(Icons.menu_book_rounded),
          ),
        ],
      ),
      body: catalog.when(
        loading: () => const _HomeSkeleton(),
        error: (e, _) => ErrorStateView(
          message: e is ApiException ? e.message : 'خطا در دریافت دوره‌ها',
          onRetry: () => ref.invalidate(courseCatalogProvider),
        ),
        data: (courses) {
          if (courses.isEmpty) {
            return const EmptyState(
              title: 'هنوز دوره‌ای نیست',
              message: 'به‌زودی دوره‌های جدید اضافه می‌شوند.',
              icon: Icons.school_outlined,
            );
          }

          final featured =
              (courses.where((x) => x.featured).toList().isEmpty
                      ? courses
                      : courses.where((x) => x.featured).toList())
                  .take(8)
                  .toList();
          final vip = courses.where((x) => x.vipPrice != null).take(8).toList();
          final latest = courses.take(20).toList();

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(courseCatalogProvider),
            child: ListView(
              padding: const EdgeInsets.only(bottom: Space.s8),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Space.page,
                    Space.s4,
                    Space.page,
                    Space.s2,
                  ),
                  child: Text(
                    'مسیر یادگیری شما',
                    style: context.text.bodyMedium.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
                ),
                PishroChipBar(
                  labels: const ['پیشنهادی', 'محبوب', 'VIP'],
                  selectedIndex: _chip,
                  onSelected: (i) => setState(() => _chip = i),
                ),
                SectionHeader(
                  title: 'دوره‌های پیشنهادی',
                  onSeeAll: () => context.push(Routes.courseCategories),
                ),
                SizedBox(
                  height: 268,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: Space.page),
                    itemCount: featured.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: Space.s3),
                    itemBuilder: (_, i) {
                      final course = featured[i];
                      return CourseCard(
                        course: course,
                        onTap: () =>
                            context.push(Routes.courseDetails(course.id)),
                      );
                    },
                  ),
                ),
                if (vip.isNotEmpty) ...[
                  SectionHeader(
                    title: 'دوره‌های VIP',
                    trailingIcon: Icon(
                      Icons.star_rounded,
                      size: 18,
                      color: c.premium,
                    ),
                    onSeeAll: () => context.push(Routes.courseCategories),
                  ),
                  SizedBox(
                    height: 268,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: Space.page,
                      ),
                      itemCount: vip.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: Space.s3),
                      itemBuilder: (_, i) {
                        final course = vip[i];
                        return CourseCard(
                          course: course,
                          onTap: () =>
                              context.push(Routes.courseDetails(course.id)),
                        );
                      },
                    ),
                  ),
                ],
                SectionHeader(
                  title: 'آخرین دوره‌ها',
                  onSeeAll: () => context.push(Routes.courseSearchResults),
                ),
                ...latest.map(
                  (course) => Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Space.page,
                      0,
                      Space.page,
                      Space.s3,
                    ),
                    child: CourseListRow(
                      course: course,
                      onTap: () =>
                          context.push(Routes.courseDetails(course.id)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(Space.page),
      children: const [
        Skeleton.line(width: 160, height: 18),
        SizedBox(height: Space.s4),
        Skeleton.line(width: double.infinity, height: 36),
        SizedBox(height: Space.s5),
        Skeleton.cover(),
        SizedBox(height: Space.s4),
        Skeleton.line(width: double.infinity),
        SizedBox(height: Space.s2),
        Skeleton.line(width: 220),
      ],
    );
  }
}
