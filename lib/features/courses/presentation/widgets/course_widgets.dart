import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_badge.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/courses_models.dart';

/// «★ ۴٫۸ (۳۱۰)» — rating always ships its star glyph, never colour alone.
class RatingLabel extends StatelessWidget {
  const RatingLabel(this.rating, {super.key, this.count, this.gold = false});

  final double? rating;
  final int? count;
  final bool gold;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (rating == null) {
      return Text(
        'بدون امتیاز',
        style: context.text.caption.copyWith(color: c.textMuted),
      );
    }
    return Semantics(
      label: 'امتیاز ${faDecimal(rating!)} از ۵',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: 14,
            color: gold ? c.premium : c.textSecondary,
          ),
          const SizedBox(width: 2),
          Text(
            count == null
                ? faDecimal(rating!)
                : '${faDecimal(rating!)} (${Fmt.fa('$count')})',
            style: context.text.caption.copyWith(color: c.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// «۲٬۴۹۰٬۰۰۰ تومان» with the amount and its unit on separate baselines, the
/// way every price block in the deck is set.
class PriceTag extends StatelessWidget {
  const PriceTag({
    super.key,
    required this.toman,
    this.prefix,
    this.large = false,
  });

  final int toman;

  /// e.g. «شروع از»
  final String? prefix;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (toman == 0) {
      return Text(
        'رایگان',
        style: (large ? context.text.h3 : context.text.bodyMedium).copyWith(
          color: c.success,
          fontWeight: FontWeight.w700,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (prefix != null)
          Text(prefix!, style: context.text.micro.copyWith(color: c.textMuted)),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              Fmt.grouped(toman),
              style: (large ? context.text.h2 : context.text.bodyLarge)
                  .copyWith(color: c.textPrimary, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: Space.s1),
            Text(
              'تومان',
              style: context.text.caption.copyWith(color: c.textMuted),
            ),
          ],
        ),
      ],
    );
  }
}

/// 16:9 cover with the package badge the deck overlays on it.
class CourseCover extends StatelessWidget {
  const CourseCover({super.key, required this.course, this.height});

  final Course course;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final url = course.coverUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(Radii.card),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: url == null || url.isEmpty
                ? Container(
                    color: c.surfaceSecondary,
                    child: Icon(
                      Icons.play_circle_outline_rounded,
                      size: 34,
                      color: c.textMuted,
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const Skeleton.cover(),
                    errorWidget: (_, __, ___) => Container(
                      color: c.surfaceSecondary,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 28,
                        color: c.textMuted,
                      ),
                    ),
                  ),
          ),
          Positioned(
            top: Space.s2,
            right: Space.s2,
            child: course.hasVip
                ? const PishroBadge(
                    label: 'VIP موجود',
                    tone: PishroBadgeTone.premium,
                    icon: Icons.star_rounded,
                  )
                : const PishroBadge.regular(),
          ),
        ],
      ),
    );
  }
}

/// Card/Course — the 16:9 tile used by «دوره‌های پیشنهادی».
class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.course,
    this.onTap,
    this.width = 260,
  });

  final Course course;
  final VoidCallback? onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      width: width,
      child: PishroCard(
        onTap: onTap,
        padding: const EdgeInsets.all(Space.s3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CourseCover(course: course),
            const SizedBox(height: Space.s3),
            Text(
              course.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodyMedium.copyWith(
                color: c.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: Space.s1),
            Text(
              [
                course.instructorName,
                if (course.durationLabel != null) course.durationLabel!,
              ].join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.caption.copyWith(color: c.textMuted),
            ),
            const SizedBox(height: Space.s3),
            Row(
              children: [
                PriceTag(toman: course.finalPrice),
                const Spacer(),
                RatingLabel(course.rating),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Row form used by SearchResults and MyCourses-adjacent lists.
class CourseListRow extends StatelessWidget {
  const CourseListRow({super.key, required this.course, this.onTap});

  final Course course;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return PishroCard(
      onTap: onTap,
      padding: const EdgeInsets.all(Space.s3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 96, child: CourseCover(course: course)),
          const SizedBox(width: Space.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyMedium.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: Space.s1),
                Text(
                  '${course.instructorName} · ${course.level.label}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.caption.copyWith(color: c.textMuted),
                ),
                const SizedBox(height: Space.s2),
                Wrap(
                  spacing: Space.s2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    RatingLabel(course.rating),
                    if (course.students != null)
                      Text(
                        '${Fmt.fa('${course.students}')} دانشجو',
                        style: context.text.caption.copyWith(
                          color: c.textMuted,
                        ),
                      ),
                    if (course.durationLabel != null)
                      Text(
                        course.durationLabel!,
                        style: context.text.caption.copyWith(
                          color: c.textMuted,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: Space.s2),
                PriceTag(toman: course.finalPrice),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Card/CourseCategory — «تحلیل تکنیکال · پرطرفدار · … در ۱۸ دوره».
class CategoryCard extends StatelessWidget {
  const CategoryCard({super.key, required this.category, this.onTap});

  final CourseCategory category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return PishroCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: c.surfaceSecondary,
              borderRadius: BorderRadius.circular(Radii.md),
            ),
            child: Icon(
              Icons.category_outlined,
              size: 20,
              color: c.textSecondary,
            ),
          ),
          const SizedBox(width: Space.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        category.title,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodyMedium.copyWith(
                          color: c.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (category.featured) ...[
                      const SizedBox(width: Space.s2),
                      const PishroBadge(
                        label: 'پرطرفدار',
                        tone: PishroBadgeTone.info,
                        icon: Icons.local_fire_department_outlined,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: Space.s1),
                Text(
                  '${Fmt.fa('${category.courseCount}')} دوره',
                  style: context.text.caption.copyWith(color: c.textMuted),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_left_rounded, color: c.textMuted),
        ],
      ),
    );
  }
}

/// Course/MetaItem — «مدت · ۱۲ ساعت» stacked label over value.
class CourseMetaItem extends StatelessWidget {
  const CourseMetaItem({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.text.micro.copyWith(color: c.textMuted)),
        const SizedBox(height: 2),
        Text(
          value,
          style: context.text.bodySmall.copyWith(
            color: c.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Course/StickyPurchaseBar — «قیمت‌گذاری همیشه پیش از پرداخت نمایان است», so
/// the price never scrolls away on Course/Details.
class StickyPurchaseBar extends StatelessWidget {
  const StickyPurchaseBar({
    super.key,
    required this.toman,
    required this.actionLabel,
    required this.onAction,
    this.prefix = 'شروع از',
    this.loading = false,
  });

  final int toman;
  final String actionLabel;
  final VoidCallback? onAction;
  final String prefix;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.surfacePrimary,
        border: Border(top: BorderSide(color: c.borderDefault)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(Space.page),
          child: Row(
            children: [
              PriceTag(toman: toman, prefix: prefix, large: true),
              const SizedBox(width: Space.s4),
              Expanded(
                child: PishroButton(
                  label: actionLabel,
                  onPressed: onAction,
                  loading: loading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
