import 'package:flutter/material.dart';

/// Typography scale — Foundations Frame 03.
/// Persian primary: Vazirmatn (fallbacks IRANSansX ← Peyda).
/// Latin tickers/figures: Inter with `tabular-nums`.
abstract final class AppFonts {
  /// Declared in pubspec once the TTFs land in `assets/fonts/`; until then
  /// Flutter falls back to the platform Persian face, which still renders RTL
  /// correctly — only the letterforms differ.
  static const persian = 'Vazirmatn';

  /// Used for tickers (BTC/ETH/USDT) and monetary figures.
  static const latin = 'Inter';

  static const fallback = <String>['IRANSansX', 'Peyda', 'Tahoma'];
}

/// The named steps from the deck. Sizes are `size / lineHeight` in px.
@immutable
class AppTextStyles extends ThemeExtension<AppTextStyles> {
  const AppTextStyles({
    required this.displayLarge,
    required this.displaySmall,
    required this.h1,
    required this.h2,
    required this.h3,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.caption,
    required this.micro,
    required this.numeric,
  });

  final TextStyle displayLarge; // 32 / 44
  final TextStyle displaySmall; // 28 / 40
  final TextStyle h1; // 24 / 36
  final TextStyle h2; // 20 / 32
  final TextStyle h3; // 18 / 28
  final TextStyle bodyLarge; // 16 / 28
  final TextStyle bodyMedium; // 14 / 24 — default body
  final TextStyle bodySmall; // 13 / 22
  final TextStyle caption; // 12 / 20
  final TextStyle micro; // 11 / 18

  /// Tabular figures for prices/amounts so digits don't jitter while polling.
  final TextStyle numeric;

  static TextStyle _s(
    double size,
    double lineHeight, {
    FontWeight weight = FontWeight.w400,
  }) =>
      TextStyle(
        fontFamily: AppFonts.persian,
        fontFamilyFallback: AppFonts.fallback,
        fontSize: size,
        height: lineHeight / size,
        fontWeight: weight,
        // Persian has no uppercase and must never be letter-spaced.
        letterSpacing: 0,
      );

  static final base = AppTextStyles(
    displayLarge: _s(32, 44, weight: FontWeight.w800),
    displaySmall: _s(28, 40, weight: FontWeight.w700),
    h1: _s(24, 36, weight: FontWeight.w700),
    h2: _s(20, 32, weight: FontWeight.w700),
    h3: _s(18, 28, weight: FontWeight.w600),
    bodyLarge: _s(16, 28),
    bodyMedium: _s(14, 24),
    bodySmall: _s(13, 22),
    caption: _s(12, 20),
    micro: _s(11, 18),
    numeric: const TextStyle(
      fontFamily: AppFonts.latin,
      fontFamilyFallback: AppFonts.fallback,
      fontSize: 16,
      height: 28 / 16,
      fontWeight: FontWeight.w600,
      fontFeatures: [FontFeature.tabularFigures()],
    ),
  );

  @override
  AppTextStyles copyWith() => this;

  @override
  AppTextStyles lerp(ThemeExtension<AppTextStyles>? other, double t) => this;
}

extension AppTextStylesX on BuildContext {
  AppTextStyles get text =>
      Theme.of(this).extension<AppTextStyles>() ?? AppTextStyles.base;
}
