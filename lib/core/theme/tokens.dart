import 'package:flutter/material.dart';

/// Primitive design tokens — the fixed scale shared by both themes.
/// Source: «Pishro Sarmaye — Foundations», Frame 02 (سیستم رنگ).
/// Only the semantic layer (see [AppColors]) switches between Dark and Light.
abstract final class Neutral {
  static const n1000 = Color(0xFF080A0D);
  static const n950 = Color(0xFF0B0D10);
  static const n900 = Color(0xFF101318);
  static const n850 = Color(0xFF14181D);
  static const n800 = Color(0xFF191E24);
  static const n750 = Color(0xFF20262D);
  static const n700 = Color(0xFF29313A);
  static const n600 = Color(0xFF3B4550);
  static const n500 = Color(0xFF65707C);
  static const n400 = Color(0xFF8D97A2);
  static const n300 = Color(0xFFB6BEC6);
  static const n200 = Color(0xFFD9DEE3);
  static const n100 = Color(0xFFF1F3F5);
  static const n50 = Color(0xFFFAFAF8);
}

/// Brand Gold — VIP badge, Pishro Coin and certificate decoration ONLY.
/// Per the deck this is no longer the primary action colour (see [RoyalGreen]).
abstract final class Gold {
  static const g900 = Color(0xFF5E4822);
  static const g800 = Color(0xFF785D2D);
  static const g700 = Color(0xFF96743B);
  static const g600 = Color(0xFFB38A48);
  static const g500 = Color(0xFFC9A45C); // base
  static const g400 = Color(0xFFD6B56F);
  static const g300 = Color(0xFFE3C88E);
  static const g200 = Color(0xFFEFDCB3);
  static const g100 = Color(0xFFF8EDD5);
}

/// Theme/RoyalGreen — the primary action ramp.
abstract final class RoyalGreen {
  static const dark = Color(0xFF0A3D28); // light-theme hover/pressed
  static const deep = Color(0xFF0F5132); // light-theme Action/Primary
  static const base = Color(0xFF1E7A4B); // focus ring / Border-Active
  static const light = Color(0xFF2A9761); // dark-theme hover
  static const tintLight = Color(0xFFE5F2EA); // light-theme Surface/Selected
}

/// 8pt grid. `s4` (16) is the standard horizontal page padding at 390px.
abstract final class Space {
  static const s1 = 4.0;
  static const s2 = 8.0;
  static const s3 = 12.0;
  static const s4 = 16.0;
  static const s5 = 20.0;
  static const s6 = 24.0;
  static const s8 = 32.0;
  static const s10 = 40.0;
  static const s12 = 48.0;
  static const s16 = 64.0;

  /// Horizontal page padding — Frame 04.
  static const page = s4;
}

/// Corner radii — card 16 · input 12 · button 12 · bottom-sheet top 24.
abstract final class Radii {
  static const xs = 6.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const pill = 999.0;

  static const card = lg;
  static const input = md;
  static const button = md;
  static const sheet = xxl;
}

/// Layout constants from the deck.
abstract final class Layout {
  /// Design canvas width. Desktop/tablet renders as a centred column.
  static const designWidth = 390.0;

  /// Navigation/Bottom height, excluding safe area — Frame 07.
  static const bottomNavHeight = 78.0;

  /// Minimum tappable target (WCAG 2.2 AA).
  static const minTapTarget = 44.0;
}
