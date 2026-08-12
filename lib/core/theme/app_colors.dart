import 'package:flutter/material.dart';

import 'tokens.dart';

/// Semantic colour layer — the ONLY layer widgets should read.
/// Components must never reference [Neutral]/[Gold] primitives directly, so a
/// theme switch stays a single-file change.
///
/// Read it via `context.colors` (see [AppColorsX]).
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.brightness,
    required this.backgroundApp,
    required this.surfacePrimary,
    required this.surfaceSecondary,
    required this.surfaceSelected,
    required this.borderDefault,
    required this.borderActive,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.actionPrimary,
    required this.actionPrimaryPressed,
    required this.onAction,
    required this.actionDisabled,
    required this.premium,
    required this.success,
    required this.danger,
    required this.warning,
    required this.info,
    required this.marketUp,
    required this.marketDown,
  });

  final Brightness brightness;

  final Color backgroundApp;
  final Color surfacePrimary;
  final Color surfaceSecondary;
  final Color surfaceSelected;

  final Color borderDefault;
  final Color borderActive;

  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  final Color actionPrimary;
  final Color actionPrimaryPressed;
  final Color onAction;
  final Color actionDisabled;

  /// VIP badge / Pishro Coin / certificate only — never a general accent.
  final Color premium;

  final Color success;
  final Color danger;
  final Color warning;
  final Color info;

  /// Price direction. Never use alone — always pair with an arrow glyph and a
  /// text label (Foundations Frame 02: «هرگز فقط با رنگ»).
  final Color marketUp;
  final Color marketDown;

  bool get isDark => brightness == Brightness.dark;

  static const dark = AppColors(
    brightness: Brightness.dark,
    backgroundApp: Neutral.n1000,
    surfacePrimary: Neutral.n900,
    surfaceSecondary: Neutral.n800,
    // Surface/Selected = RoyalGreen/Light @ 12%
    surfaceSelected: Color(0x1F2A9761),
    borderDefault: Neutral.n700,
    borderActive: RoyalGreen.base,
    textPrimary: Neutral.n100,
    textSecondary: Neutral.n300,
    textMuted: Neutral.n400,
    actionPrimary: RoyalGreen.base,
    actionPrimaryPressed: RoyalGreen.light,
    onAction: Neutral.n50,
    actionDisabled: Neutral.n600,
    premium: Gold.g500,
    success: Color(0xFF2BBF84),
    danger: Color(0xFFF05C68),
    warning: Color(0xFFF2B84B),
    info: Color(0xFF3B9EFF),
    marketUp: Color(0xFF24C486),
    marketDown: Color(0xFFF05B67),
  );

  static const light = AppColors(
    brightness: Brightness.light,
    backgroundApp: Color(0xFFF5F7F5),
    surfacePrimary: Color(0xFFFFFFFF),
    surfaceSecondary: Color(0xFFF0F3F1),
    surfaceSelected: RoyalGreen.tintLight,
    borderDefault: Color(0xFFD8E0DB),
    borderActive: RoyalGreen.base,
    textPrimary: Color(0xFF142119),
    textSecondary: Color(0xFF46534B),
    textMuted: Color(0xFF66736B),
    actionPrimary: RoyalGreen.deep,
    actionPrimaryPressed: RoyalGreen.dark,
    onAction: Color(0xFFFFFFFF),
    actionDisabled: Color(0xFFB6BEC6),
    premium: Gold.g500,
    success: Color(0xFF14805A),
    danger: Color(0xFFD43C4A),
    warning: Color(0xFF9A6700),
    info: Color(0xFF1769AA),
    marketUp: Color(0xFF12845C),
    marketDown: Color(0xFFD64550),
  );

  /// Divider is a hair lighter than the border in light mode; identical in dark.
  Color get divider => isDark ? Neutral.n800 : const Color(0xFFE1E7E3);

  @override
  AppColors copyWith({Brightness? brightness}) => this;

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return t < 0.5 ? this : other;
  }
}

extension AppColorsX on BuildContext {
  AppColors get colors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.dark;
}
