import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/courses_repository.dart';
import '../widgets/course_widgets.dart';

/// Screen/Courses/SearchResults — فهرست پس از جست‌وجو و فیلتر.
class CoursesSearchResultsScreen extends ConsumerWidget {
  const CoursesSearchResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final query = ref.watch(courseQueryProvider);
    final filters = ref.watch(courseFiltersProvider);
    final results = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          query.isEmpty ? 'نتایج' : query,
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
        actions: [
          IconButton(
            tooltip: 'فیلترها',
            onPressed: () => context.push(Routes.courseFilters),
            icon: Badge(
              isLabelVisible: !filters.isEmpty,
              label: Text(Fmt.fa('${filters.selectedCount}')),
              child: const Icon(Icons.tune_rounded),
            ),
          ),
        ],
      ),
      body: results.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(Space.page),
          children: const [
            Skeleton.box(height: 96),
            SizedBox(height: Space.s3),
            Skeleton.box(height: 96),
            SizedBox(height: Space.s3),
            Skeleton.box(height: 96),
          ],
        ),
        error: (e, _) => ErrorStateView(
          message: e is ApiException ? e.message : 'نتایج بارگذاری نشد.',
          onRetry: () => ref.invalidate(searchResultsProvider),
        ),
        data: (courses) {
          if (courses.isEmpty) {
            return EmptyState(
              title: 'دوره‌ای مطابق جست‌وجو پیدا نشد',
              message: query.isEmpty
                  ? 'فیلترها را تغییر دهید یا جست‌وجوی تازه‌ای بزنید.'
                  : 'برای «$query» نتیجه‌ای نبود.',
              icon: Icons.search_off_rounded,
              actionLabel: 'تغییر فیلتر',
              onAction: () => context.push(Routes.courseFilters),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              Space.page,
              Space.s3,
              Space.page,
              Space.s8,
            ),
            itemCount: courses.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: Space.s3),
            itemBuilder: (context, i) {
              if (i == 0) {
                return Text(
                  '${Fmt.fa('${courses.length}')} دوره',
                  style: context.text.caption.copyWith(color: c.textMuted),
                );
              }
              final course = courses[i - 1];
              return CourseListRow(
                course: course,
                onTap: () => context.push(Routes.courseDetails(course.id)),
              );
            },
          );
        },
      ),
    );
  }
}
