import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/pishro_chip.dart';
import '../../data/courses_models.dart';
import '../../data/courses_repository.dart';

/// Screen/Courses/Filters — «نوع بسته · سطح · بازه قیمت · مرتب‌سازی».
class CoursesFiltersScreen extends ConsumerWidget {
  const CoursesFiltersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final filters = ref.watch(courseFiltersProvider);
    final notifier = ref.read(courseFiltersProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'فیلترها',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
        actions: [
          if (!filters.isEmpty)
            TextButton(
              onPressed: () => notifier.state = const CourseFilters(),
              child: const Text('حذف همه'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Space.page,
          Space.s4,
          Space.page,
          Space.s16,
        ),
        children: [
          _Label('نوع بسته'),
          Wrap(
            spacing: Space.s2,
            runSpacing: Space.s2,
            children: [
              PishroChip(
                label: 'همه',
                selected: filters.packageType == null,
                onTap: () =>
                    notifier.state = filters.copyWith(clearPackageType: true),
              ),
              for (final p in PackageType.values)
                PishroChip(
                  label: p.label,
                  selected: filters.packageType == p,
                  onTap: () =>
                      notifier.state = filters.copyWith(packageType: p),
                ),
            ],
          ),
          const SizedBox(height: Space.s6),
          _Label('سطح'),
          Wrap(
            spacing: Space.s2,
            runSpacing: Space.s2,
            children: [
              PishroChip(
                label: 'همه',
                selected: filters.level == null,
                onTap: () =>
                    notifier.state = filters.copyWith(clearLevel: true),
              ),
              for (final l in [
                CourseLevel.beginner,
                CourseLevel.intermediate,
                CourseLevel.advanced,
              ])
                PishroChip(
                  label: l.label,
                  selected: filters.level == l,
                  onTap: () => notifier.state = filters.copyWith(level: l),
                ),
            ],
          ),
          const SizedBox(height: Space.s6),
          _Label('بازه قیمت'),
          Wrap(
            spacing: Space.s2,
            runSpacing: Space.s2,
            children: [
              for (final b in PriceBand.values)
                PishroChip(
                  label: b.label,
                  selected: filters.priceBand == b,
                  onTap: () => notifier.state = filters.copyWith(priceBand: b),
                ),
            ],
          ),
          const SizedBox(height: Space.s6),
          _Label('مرتب‌سازی'),
          Wrap(
            spacing: Space.s2,
            runSpacing: Space.s2,
            children: [
              for (final s in CourseSort.values)
                PishroChip(
                  label: s.label,
                  selected: filters.sort == s,
                  onTap: () => notifier.state = filters.copyWith(sort: s),
                ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.page),
          child: PishroButton(
            label: filters.isEmpty
                ? 'مشاهده نتایج'
                : 'اعمال ${filters.selectedCount} فیلتر',
            onPressed: () => context.go(Routes.courseSearchResults),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: Space.s3),
    child: Text(
      text,
      style: context.text.bodySmall.copyWith(
        color: context.colors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
