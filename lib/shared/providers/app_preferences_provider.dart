import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// «بازه پیش‌فرض نمودار» on Screen/Account/Preferences.
enum ChartRangePref { day, week, month }

extension ChartRangePrefX on ChartRangePref {
  String get label => switch (this) {
    ChartRangePref.day => '۲۴ ساعت',
    ChartRangePref.week => '۷ روز',
    ChartRangePref.month => '۳۰ روز',
  };
}

/// Device-local playback and display preferences. These are client settings —
/// there is no `/user/preferences` endpoint and they never leave the device.
@immutable
class AppPreferences {
  const AppPreferences({
    this.autoplayVideo = true,
    this.dataSaver = false,
    this.chartRange = ChartRangePref.day,
    this.reduceMotion = false,
  });

  final bool autoplayVideo;
  final bool dataSaver;
  final ChartRangePref chartRange;

  /// Opt-in on top of the platform setting; the platform's own reduce-motion
  /// flag is still honoured independently.
  final bool reduceMotion;

  AppPreferences copyWith({
    bool? autoplayVideo,
    bool? dataSaver,
    ChartRangePref? chartRange,
    bool? reduceMotion,
  }) => AppPreferences(
    autoplayVideo: autoplayVideo ?? this.autoplayVideo,
    dataSaver: dataSaver ?? this.dataSaver,
    chartRange: chartRange ?? this.chartRange,
    reduceMotion: reduceMotion ?? this.reduceMotion,
  );
}

class AppPreferencesNotifier extends StateNotifier<AppPreferences> {
  AppPreferencesNotifier() : super(const AppPreferences()) {
    _restore();
  }

  static const _autoplayKey = 'pishro_autoplay_video';
  static const _dataSaverKey = 'pishro_data_saver';
  static const _chartRangeKey = 'pishro_chart_range';
  static const _reduceMotionKey = 'pishro_reduce_motion';

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final storedRange = prefs.getString(_chartRangeKey);
    state = AppPreferences(
      autoplayVideo: prefs.getBool(_autoplayKey) ?? true,
      dataSaver: prefs.getBool(_dataSaverKey) ?? false,
      chartRange: ChartRangePref.values.firstWhere(
        (r) => r.name == storedRange,
        orElse: () => ChartRangePref.day,
      ),
      reduceMotion: prefs.getBool(_reduceMotionKey) ?? false,
    );
  }

  Future<void> setAutoplay(bool v) async {
    state = state.copyWith(autoplayVideo: v);
    await (await SharedPreferences.getInstance()).setBool(_autoplayKey, v);
  }

  Future<void> setDataSaver(bool v) async {
    state = state.copyWith(dataSaver: v);
    await (await SharedPreferences.getInstance()).setBool(_dataSaverKey, v);
  }

  Future<void> setChartRange(ChartRangePref r) async {
    state = state.copyWith(chartRange: r);
    await (await SharedPreferences.getInstance()).setString(
      _chartRangeKey,
      r.name,
    );
  }

  Future<void> setReduceMotion(bool v) async {
    state = state.copyWith(reduceMotion: v);
    await (await SharedPreferences.getInstance()).setBool(_reduceMotionKey, v);
  }

  /// «بازنشانی تنظیمات به حالت پیش‌فرض» — this screen's settings only; the
  /// theme and the session are untouched.
  Future<void> reset() async {
    state = const AppPreferences();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_autoplayKey);
    await prefs.remove(_dataSaverKey);
    await prefs.remove(_chartRangeKey);
    await prefs.remove(_reduceMotionKey);
  }
}

final appPreferencesProvider =
    StateNotifierProvider<AppPreferencesNotifier, AppPreferences>(
      (ref) => AppPreferencesNotifier(),
    );
