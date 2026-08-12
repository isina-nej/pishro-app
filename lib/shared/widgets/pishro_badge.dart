import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/tokens.dart';

enum PishroBadgeTone {
  /// Gold. VIP / Pishro Coin / certificate only.
  premium,
  neutral,
  success,
  warning,
  danger,
  info,
}

/// BADGE/* from Frame 06 — «★ VIP» · «عادی» · «✓ تأییدشده» · «ریسک متوسط».
class PishroBadge extends StatelessWidget {
  const PishroBadge({
    super.key,
    required this.label,
    this.tone = PishroBadgeTone.neutral,
    this.icon,
  });

  /// «★ VIP»
  const PishroBadge.vip({super.key})
    : label = 'VIP',
      tone = PishroBadgeTone.premium,
      icon = Icons.star_rounded;

  /// «عادی»
  const PishroBadge.regular({super.key})
    : label = 'عادی',
      tone = PishroBadgeTone.neutral,
      icon = null;

  /// «✓ تأییدشده»
  const PishroBadge.verified({super.key})
    : label = 'تأییدشده',
      tone = PishroBadgeTone.success,
      icon = Icons.check_rounded;

  /// Sample/placeholder data marker — the decks show it wherever numbers are
  /// illustrative rather than live, and it must survive into the real app.
  const PishroBadge.sampleData({super.key})
    : label = 'داده نمونه',
      tone = PishroBadgeTone.neutral,
      icon = null;

  final String label;
  final PishroBadgeTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = switch (tone) {
      PishroBadgeTone.premium => c.premium,
      PishroBadgeTone.neutral => c.textMuted,
      PishroBadgeTone.success => c.success,
      PishroBadgeTone.warning => c.warning,
      PishroBadgeTone.danger => c.danger,
      PishroBadgeTone.info => c.info,
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Space.s2 + 2,
        vertical: Space.s1 + 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Radii.pill),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: Space.s1),
          ],
          Text(
            label,
            style: context.text.micro.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Risk level. The deck is explicit that risk is «با آیکون+متن», never colour
/// alone, so the icon is not optional.
enum RiskLevel { low, medium, high }

class RiskBadge extends StatelessWidget {
  const RiskBadge(this.level, {super.key});

  final RiskLevel level;

  @override
  Widget build(BuildContext context) => PishroBadge(
    label: switch (level) {
      RiskLevel.low => 'ریسک کم',
      RiskLevel.medium => 'ریسک متوسط',
      RiskLevel.high => 'ریسک بالا',
    },
    tone: switch (level) {
      RiskLevel.low => PishroBadgeTone.success,
      RiskLevel.medium => PishroBadgeTone.warning,
      RiskLevel.high => PishroBadgeTone.danger,
    },
    icon: switch (level) {
      RiskLevel.low => Icons.shield_outlined,
      RiskLevel.medium => Icons.info_outline_rounded,
      RiskLevel.high => Icons.warning_amber_rounded,
    },
  );
}
