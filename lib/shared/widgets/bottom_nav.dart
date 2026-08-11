import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/tokens.dart';

/// Navigation/Bottom — Foundations Frame 07.
///
/// Five destinations, right-to-left, fixed order, labels always visible.
/// No home tab and no centre floating action, both explicitly ruled out by the
/// deck. Height is 78 + safe area; each item is at least 44×44.
class PishroBottomNav extends StatelessWidget {
  const PishroBottomNav({
    super.key,
    required this.currentIndex,
    required this.onSelected,
    this.badges = const {},
  });

  final int currentIndex;
  final ValueChanged<int> onSelected;

  /// index -> unread count, e.g. `{1: 3}` for the news badge in the deck.
  final Map<int, int> badges;

  static const destinations = <({String label, IconData outline, IconData filled})>[
    (label: 'دوره‌ها', outline: Icons.school_outlined, filled: Icons.school),
    (label: 'اخبار', outline: Icons.article_outlined, filled: Icons.article),
    (
      label: 'سرمایه‌گذاری',
      outline: Icons.trending_up_outlined,
      filled: Icons.trending_up
    ),
    (
      label: 'بازار',
      outline: Icons.candlestick_chart_outlined,
      filled: Icons.candlestick_chart
    ),
    (label: 'حساب', outline: Icons.person_outline, filled: Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.isDark ? c.surfacePrimary : c.surfacePrimary,
        border: Border(top: BorderSide(color: c.borderDefault)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: Layout.bottomNavHeight,
          child: Row(
            children: [
              for (var i = 0; i < destinations.length; i++)
                Expanded(
                  child: _NavItem(
                    data: destinations[i],
                    active: i == currentIndex,
                    badge: badges[i],
                    onTap: () => onSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.data,
    required this.active,
    required this.onTap,
    this.badge,
  });

  final ({String label, IconData outline, IconData filled}) data;
  final bool active;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = active ? c.actionPrimary : c.textMuted;

    return Semantics(
      selected: active,
      button: true,
      label: data.label,
      child: InkWell(
        onTap: onTap,
        // Filled icon variants are reserved for the active tab (Frame 05).
        child: Container(
          constraints: const BoxConstraints(
            minHeight: Layout.minTapTarget,
            minWidth: Layout.minTapTarget,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(active ? data.filled : data.outline, size: 24, color: color),
                  if (badge != null && badge! > 0)
                    Positioned(
                      top: -4,
                      left: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: c.danger,
                          borderRadius: BorderRadius.circular(Radii.pill),
                        ),
                        constraints: const BoxConstraints(minWidth: 16),
                        child: Text(
                          badge! > 99 ? '۹۹+' : _fa(badge!),
                          textAlign: TextAlign.center,
                          style: context.text.micro.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: Space.s1),
              Text(
                data.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.micro.copyWith(
                  color: color,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _fa(int n) => n
      .toString()
      .split('')
      .map((d) => '۰۱۲۳۴۵۶۷۸۹'[int.parse(d)])
      .join();
}
