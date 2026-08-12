import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';

/// Onboarding pager indicator — 26×4 pill for the active slide, 8×4 for the
/// rest, with the «۱ / ۳» counter pushed to the far end.
class OnboardingDots extends StatelessWidget {
  const OnboardingDots({super.key, required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      label: 'اسلاید ${Fmt.fa('${index + 1}')} از ${Fmt.fa('$count')}',
      excludeSemantics: true,
      child: Row(
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: i == index ? 26 : 8,
              height: 4,
              decoration: BoxDecoration(
                color: i == index ? c.actionPrimary : c.borderDefault,
                borderRadius: BorderRadius.circular(Radii.pill),
              ),
            ),
          ],
          const Spacer(),
          Text(
            '${Fmt.fa('${index + 1}')} / ${Fmt.fa('$count')}',
            style: context.text.caption.copyWith(color: c.textMuted),
          ),
        ],
      ),
    );
  }
}
