import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/tokens.dart';

enum PishroButtonVariant {
  /// Filled RoyalGreen — one per screen.
  primary,

  /// Outlined, for the secondary action beside a primary.
  secondary,

  /// Text-only, for tertiary/dismiss actions.
  ghost,

  /// Destructive (delete account, cancel contract).
  danger,

  /// Gold-filled — VIP purchase and Pishro Coin only.
  premium,
}

enum PishroButtonSize { regular, small }

/// BUTTON/* from Foundations Frame 06.
///
/// While [loading] the button keeps its width and stays non-interactive, which
/// is what stops the double-submit the checkout deck calls out
/// («ارسال مجدد مسدود است»).
class PishroButton extends StatelessWidget {
  const PishroButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = PishroButtonVariant.primary,
    this.size = PishroButtonSize.regular,
    this.icon,
    this.loading = false,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final PishroButtonVariant variant;
  final PishroButtonSize size;
  final IconData? icon;
  final bool loading;
  final bool expanded;

  bool get _enabled => onPressed != null && !loading;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final height = size == PishroButtonSize.regular ? 52.0 : Layout.minTapTarget;
    final textStyle = (size == PishroButtonSize.regular
            ? context.text.bodyLarge
            : context.text.bodySmall)
        .copyWith(fontWeight: FontWeight.w600);

    final (bg, fg, border) = _palette(c);

    final child = Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          ),
          const SizedBox(width: Space.s2),
        ] else if (icon != null) ...[
          Icon(icon, size: 20, color: fg),
          const SizedBox(width: Space.s2),
        ],
        Flexible(
          child: Text(
            loading ? 'در حال پردازش…' : label,
            style: textStyle.copyWith(color: fg),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );

    return Semantics(
      button: true,
      enabled: _enabled,
      label: label,
      child: SizedBox(
        width: expanded ? double.infinity : null,
        height: height,
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(Radii.button),
          child: InkWell(
            onTap: _enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(Radii.button),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Radii.button),
                border: border == null ? null : Border.all(color: border),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: size == PishroButtonSize.regular ? Space.s5 : Space.s4,
              ),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }

  /// Returns (background, foreground, border?).
  (Color, Color, Color?) _palette(AppColors c) {
    if (!_enabled) {
      return (
        c.actionDisabled.withValues(alpha: 0.25),
        c.actionDisabled,
        null,
      );
    }
    return switch (variant) {
      PishroButtonVariant.primary => (c.actionPrimary, c.onAction, null),
      PishroButtonVariant.secondary => (
          Colors.transparent,
          c.textPrimary,
          c.borderDefault,
        ),
      PishroButtonVariant.ghost => (Colors.transparent, c.actionPrimary, null),
      PishroButtonVariant.danger => (
          Colors.transparent,
          c.danger,
          c.danger.withValues(alpha: 0.5),
        ),
      // Gold text sits on dark only — the deck forbids gold text on light
      // surfaces, so the label uses the darkest neutral instead.
      PishroButtonVariant.premium => (c.premium, Neutral.n1000, null),
    };
  }
}
