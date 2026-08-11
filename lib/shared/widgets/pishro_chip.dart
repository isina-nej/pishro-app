import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/tokens.dart';

/// CHIP/FILTER from Frame 06 — «همه · تحلیل تکنیکال · ارز دیجیتال …».
class PishroChip extends StatelessWidget {
  const PishroChip({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
    this.count,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      selected: selected,
      button: true,
      child: ConstrainedBox(
        // WCAG 2.2 AA minimum target height.
        constraints: const BoxConstraints(minHeight: Layout.minTapTarget - 8),
        child: Material(
          color: selected ? c.surfaceSelected : c.surfaceSecondary,
          borderRadius: BorderRadius.circular(Radii.pill),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(Radii.pill),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Radii.pill),
                border: Border.all(
                  color: selected ? c.borderActive : c.borderDefault,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: Space.s4,
                vertical: Space.s2 + 2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: context.text.bodySmall.copyWith(
                      color: selected ? c.borderActive : c.textSecondary,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  if (count != null) ...[
                    const SizedBox(width: Space.s1 + 2),
                    Text(
                      '($count)',
                      style: context.text.micro.copyWith(color: c.textMuted),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Horizontally scrolling chip row, the standard category filter in the decks.
class PishroChipBar extends StatelessWidget {
  const PishroChipBar({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: Layout.minTapTarget,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: Space.page),
      itemCount: labels.length,
      separatorBuilder: (_, __) => const SizedBox(width: Space.s2),
      itemBuilder: (context, i) => Center(
        child: PishroChip(
          label: labels[i],
          selected: i == selectedIndex,
          onTap: () => onSelected(i),
        ),
      ),
    ),
  );
}
