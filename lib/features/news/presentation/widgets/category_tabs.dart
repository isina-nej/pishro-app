import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/pishro_chip.dart';
import '../../data/news_models.dart';

/// «همه · ارز دیجیتال · اقتصاد ایران …» — the horizontal category strip on
/// News/Home. `null` selection is «همه».
class NewsCategoryTabs extends StatelessWidget {
  const NewsCategoryTabs({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  final List<NewsCategoryGroup> categories;
  final String? selectedId;
  final ValueChanged<NewsCategoryGroup?> onSelected;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: Layout.minTapTarget,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: Space.page),
      itemCount: categories.length + 1,
      separatorBuilder: (_, __) => const SizedBox(width: Space.s2),
      itemBuilder: (context, i) {
        if (i == 0) {
          return Center(
            child: PishroChip(
              label: 'همه',
              selected: selectedId == null,
              onTap: () => onSelected(null),
            ),
          );
        }
        final group = categories[i - 1];
        return Center(
          child: PishroChip(
            label: group.title,
            selected: group.id != null && group.id == selectedId,
            onTap: () => onSelected(group),
          ),
        );
      },
    ),
  );
}

/// Tile on News/Categories — «۱۲۴ خبر · آخرین: نوسان بازار امروز».
class CategoryCard extends StatelessWidget {
  const CategoryCard({super.key, required this.group, this.onTap});

  final NewsCategoryGroup group;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.surfaceSecondary,
      borderRadius: BorderRadius.circular(Radii.lg - 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.lg - 2),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Radii.lg - 2),
            border: Border.all(color: c.borderDefault),
          ),
          padding: const EdgeInsets.all(Space.s3 + 1),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: c.actionPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(Radii.sm + 2),
                ),
                child: Icon(
                  Icons.article_outlined,
                  size: 19,
                  color: c.actionPrimary,
                ),
              ),
              const SizedBox(width: Space.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.title,
                      style: context.text.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${Fmt.fa('${group.count}')} خبر · آخرین: ${group.latestTitle}',
                      style: context.text.micro.copyWith(color: c.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The «امروز · این هفته · این ماه» selector on News/Trending, and the
/// «جدیدترین ذخیره‌شده · جدیدترین خبر» / comment-sort pills. One shape, because
/// the deck draws them the same way.
class SegmentedPills<T> extends StatelessWidget {
  const SegmentedPills({
    super.key,
    required this.values,
    required this.labelOf,
    required this.selected,
    required this.onSelected,
    this.expanded = false,
  });

  final List<T> values;
  final String Function(T) labelOf;
  final T selected;
  final ValueChanged<T> onSelected;

  /// Trending's row divides the width equally; the pill rows do not.
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final children = [
      for (final v in values)
        _Pill(
          label: labelOf(v),
          selected: v == selected,
          square: expanded,
          onTap: () => onSelected(v),
        ),
    ];

    return Row(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: Space.s2),
          if (expanded) Expanded(child: children[i]) else children[i],
        ],
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.square,
    this.onTap,
  });

  final String label;
  final bool selected;
  final bool square;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final radius = BorderRadius.circular(square ? Radii.sm + 2 : Radii.pill);
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? c.actionPrimary : c.surfaceSecondary,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: selected ? c.actionPrimary : c.borderDefault,
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: square ? Space.s2 : Space.s3,
              vertical: Space.s2 - 1,
            ),
            constraints: const BoxConstraints(minHeight: 34),
            child: Center(
              widthFactor: square ? null : 1,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: context.text.micro.copyWith(
                  color: selected ? c.onAction : c.textSecondary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
