import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/courses_repository.dart';
import '../widgets/course_widgets.dart';

/// Screen/Courses/Categories — «۰۱ · دسته‌بندی‌ها».
class CoursesCategoriesScreen extends ConsumerWidget {
  const CoursesCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final cats = ref.watch(courseCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'دسته‌بندی دوره‌ها',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
        actions: [
          IconButton(
            tooltip: 'جست‌وجو',
            onPressed: () => context.push(Routes.courseSearch),
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
      body: cats.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(Space.page),
          children: const [
            Skeleton.line(width: 180),
            SizedBox(height: Space.s4),
            Skeleton.box(height: 72),
            SizedBox(height: Space.s3),
            Skeleton.box(height: 72),
            SizedBox(height: Space.s3),
            Skeleton.box(height: 72),
          ],
        ),
        error: (e, _) => ErrorStateView(
          message: e is ApiException ? e.message : 'دسته‌بندی‌ها بارگذاری نشد.',
          onRetry: () => ref.invalidate(courseCategoriesProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyState(
              title: 'دسته‌بندی‌ای برای نمایش نیست',
              icon: Icons.category_outlined,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(courseCategoriesProvider),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                Space.page,
                Space.s3,
                Space.page,
                Space.s8,
              ),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: Space.s3),
              itemBuilder: (_, i) {
                final cat = items[i];
                return CategoryCard(
                  category: cat,
                  onTap: () {
                    ref.read(courseFiltersProvider.notifier).state = ref
                        .read(courseFiltersProvider)
                        .copyWith(categoryId: cat.id);
                    ref.read(courseQueryProvider.notifier).state = '';
                    context.push(Routes.courseSearchResults);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
