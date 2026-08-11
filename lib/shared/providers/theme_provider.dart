import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme preference. Dark is the product default per Foundations Frame 01, so
/// an unset preference resolves to dark rather than to the system setting.
///
/// Account/Preferences exposes this; note the deck forbids changing the
/// RoyalGreen palette itself — only the light/dark mapping is user-facing.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark) {
    _restore();
  }

  static const _key = 'pishro_theme_mode';

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    if (stored == null) return;
    state = ThemeMode.values.firstWhere(
      (m) => m.name == stored,
      orElse: () => ThemeMode.dark,
    );
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }

  Future<void> toggle() =>
      set(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) => ThemeModeNotifier());
