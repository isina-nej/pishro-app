import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/formatters.dart';

/// Section title with an optional «مشاهده همه» affordance.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
    this.trailingIcon,
  });

  final String title;
  final VoidCallback? onSeeAll;

  /// e.g. the gold star beside «دوره‌های VIP».
  final Widget? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.page, Space.s5, Space.page, Space.s3),
      child: Row(
        children: [
          Text(title, style: context.text.h3.copyWith(color: c.textPrimary)),
          if (trailingIcon != null) ...[
            const SizedBox(width: Space.s2),
            trailingIcon!,
          ],
          const Spacer(),
          if (onSeeAll != null)
            InkWell(
              onTap: onSeeAll,
              borderRadius: BorderRadius.circular(Radii.sm),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Space.s2,
                  vertical: Space.s1 + 2,
                ),
                child: Text(
                  'مشاهده همه',
                  style: context.text.bodySmall.copyWith(
                    color: c.actionPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Price change indicator. Renders arrow + sign + label together so the meaning
/// survives for colour-blind users — Frame 02 forbids colour as the sole cue.
class MarketDelta extends StatelessWidget {
  const MarketDelta(this.percent, {super.key, this.compact = false});

  final double percent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final up = percent >= 0;
    final color = up ? c.marketUp : c.marketDown;
    final text = Fmt.percentDelta(percent);

    return Semantics(
      label: '${up ? 'رشد' : 'افت'} ${Fmt.fa(percent.abs().toStringAsFixed(2))} درصد',
      excludeSemantics: true,
      child: Container(
        padding: compact
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: Space.s2, vertical: 2),
        decoration: compact
            ? null
            : BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(Radii.xs),
              ),
        child: Text(
          text,
          style: context.text.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Standard surface container: tonal fill + hairline border, no heavy shadow.
class PishroCard extends StatelessWidget {
  const PishroCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(Space.s4),
    this.selected = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: selected ? c.surfaceSelected : c.surfacePrimary,
      borderRadius: BorderRadius.circular(Radii.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.card),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Radii.card),
            border: Border.all(
              color: selected ? c.borderActive : c.borderDefault,
            ),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// Progress bar with the «۴۲٪ از دوره تکمیل شده» caption from Frame 06.
class PishroProgress extends StatelessWidget {
  const PishroProgress({
    super.key,
    required this.value,
    this.label,
    this.showPercent = true,
  });

  /// 0.0 – 1.0
  final double value;
  final String? label;
  final bool showPercent;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final pct = (value.clamp(0.0, 1.0) * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(Radii.pill),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: c.surfaceSecondary,
            valueColor: AlwaysStoppedAnimation(c.actionPrimary),
          ),
        ),
        if (showPercent || label != null) ...[
          const SizedBox(height: Space.s2),
          Text(
            label ?? '${Fmt.fa('$pct')}٪ از دوره تکمیل شده',
            style: context.text.caption.copyWith(color: c.textMuted),
          ),
        ],
      ],
    );
  }
}

/// Screen-level horizontal padding, matching the 390px design canvas.
class PagePadding extends StatelessWidget {
  const PagePadding({super.key, required this.child, this.vertical = 0});

  final Widget child;
  final double vertical;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Space.page,
          vertical: vertical,
        ),
        child: child,
      );
}
