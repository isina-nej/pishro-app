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
import '../../data/checkout_repository.dart';
import '../../data/courses_models.dart';
import '../../data/courses_repository.dart';
import '../widgets/course_widgets.dart';

/// Screen/Course/Details — کاور، متا، توضیح، نوار خرید چسبان.
class CourseDetailsScreen extends ConsumerWidget {
  const CourseDetailsScreen({super.key, this.id = ''});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final course = ref.watch(courseProvider(id));
    final enrollment = ref.watch(enrollmentProvider(id));

    return course.when(
      loading: () => const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(Space.page),
          child: Column(
            children: [
              Skeleton.cover(),
              SizedBox(height: Space.s4),
              Skeleton.line(width: 220),
              SizedBox(height: Space.s2),
              Skeleton.line(),
            ],
          ),
        ),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorStateView(
          message: e is ApiException ? e.message : 'دوره بارگذاری نشد.',
          onRetry: () => ref.invalidate(courseProvider(id)),
        ),
      ),
      data: (course) {
        final enrolled = enrollment.valueOrNull;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              course.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.h3.copyWith(color: c.textPrimary),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(
              Space.page,
              Space.s3,
              Space.page,
              120,
            ),
            children: [
              CourseCover(course: course),
              const SizedBox(height: Space.s4),
              Row(
                children: [
                  if (course.hasVip)
                    const PishroBadge.vip()
                  else
                    const PishroBadge.regular(),
                  const SizedBox(width: Space.s2),
                  Text(
                    course.level.label,
                    style: context.text.caption.copyWith(color: c.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: Space.s3),
              Text(
                course.title,
                style: context.text.h2.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: Space.s2),
              Text(
                course.instructorName,
                style: context.text.bodySmall.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: Space.s4),
              Row(
                children: [
                  Expanded(
                    child: CourseMetaItem(
                      label: 'مدت',
                      value: course.durationLabel ?? '—',
                    ),
                  ),
                  Expanded(
                    child: CourseMetaItem(
                      label: 'جلسات',
                      value: course.videosCount == null
                          ? '—'
                          : Fmt.fa('${course.videosCount}'),
                    ),
                  ),
                  Expanded(
                    child: CourseMetaItem(
                      label: 'دانشجو',
                      value: course.students == null
                          ? '—'
                          : Fmt.fa('${course.students}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Space.s3),
              RatingLabel(course.rating, count: course.ratingCount),
              if (course.description != null &&
                  course.description!.trim().isNotEmpty) ...[
                const SizedBox(height: Space.s6),
                Text(
                  'درباره دوره',
                  style: context.text.h3.copyWith(color: c.textPrimary),
                ),
                const SizedBox(height: Space.s2),
                Text(
                  course.description!,
                  style: context.text.bodyMedium.copyWith(
                    color: c.textSecondary,
                    height: 1.8,
                  ),
                ),
              ],
              if (course.learningGoals.isNotEmpty) ...[
                const SizedBox(height: Space.s6),
                Text(
                  'آنچه یاد می‌گیرید',
                  style: context.text.h3.copyWith(color: c.textPrimary),
                ),
                const SizedBox(height: Space.s2),
                for (final g in course.learningGoals)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Space.s2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 18,
                          color: c.success,
                        ),
                        const SizedBox(width: Space.s2),
                        Expanded(
                          child: Text(
                            g,
                            style: context.text.bodySmall.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
              if (enrolled != null) ...[
                const SizedBox(height: Space.s6),
                PishroCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'شما در این دوره ثبت‌نام کرده‌اید',
                        style: context.text.bodyMedium.copyWith(
                          color: c.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: Space.s3),
                      PishroProgress(value: enrolled.progress),
                      const SizedBox(height: Space.s4),
                      PishroButton(
                        label: 'ادامه یادگیری',
                        onPressed: () =>
                            context.push(Routes.learningDashboard(course.id)),
                      ),
                    ],
                  ),
                ),
              ],
              if (course.hasVip) ...[
                const SizedBox(height: Space.s4),
                PishroButton(
                  label: 'مقایسه بسته‌ها',
                  variant: PishroButtonVariant.secondary,
                  onPressed: () =>
                      context.push(Routes.packageComparison(course.id)),
                ),
              ],
            ],
          ),
          bottomNavigationBar: enrolled != null
              ? null
              : StickyPurchaseBar(
                  toman: course.finalPrice,
                  prefix: course.hasVip ? 'شروع از' : 'قیمت',
                  actionLabel: course.isFree ? 'ثبت‌نام رایگان' : 'خرید دوره',
                  onAction: () {
                    ref
                        .read(checkoutProvider.notifier)
                        .start(course, PackageType.regular);
                    context.push(Routes.checkout);
                  },
                ),
        );
      },
    );
  }
}
