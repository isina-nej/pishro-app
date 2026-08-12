import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// «بیشتر از» · «کمتر از» · «تغییر درصدی» — Overlay/Market/CreatePriceAlert.
enum AlertCondition {
  above('بیشتر از'),
  below('کمتر از'),
  percentChange('تغییر درصدی');

  const AlertCondition(this.label);

  final String label;
}

class PriceAlert {
  const PriceAlert({
    required this.id,
    required this.assetId,
    required this.assetName,
    required this.symbol,
    required this.condition,
    required this.value,
    required this.enabled,
    required this.createdAt,
  });

  factory PriceAlert.fromJson(Map<String, dynamic> json) => PriceAlert(
    id: json['id'] as String,
    assetId: json['assetId'] as String,
    assetName: json['assetName'] as String? ?? '',
    symbol: json['symbol'] as String? ?? '',
    condition: AlertCondition.values.firstWhere(
      (c) => c.name == json['condition'],
      orElse: () => AlertCondition.above,
    ),
    value: (json['value'] as num?)?.toDouble() ?? 0,
    enabled: json['enabled'] as bool? ?? true,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
  );

  final String id;
  final String assetId;
  final String assetName;
  final String symbol;
  final AlertCondition condition;

  /// Toman for above/below, percent for percentChange.
  final double value;
  final bool enabled;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'assetId': assetId,
    'assetName': assetName,
    'symbol': symbol,
    'condition': condition.name,
    'value': value,
    'enabled': enabled,
    'createdAt': createdAt.toIso8601String(),
  };

  PriceAlert copyWith({bool? enabled}) => PriceAlert(
    id: id,
    assetId: assetId,
    assetName: assetName,
    symbol: symbol,
    condition: condition,
    value: value,
    enabled: enabled ?? this.enabled,
    createdAt: createdAt,
  );
}

/// No endpoint exists for alerts either; same interface-first treatment as
/// favourites. Evaluation is deliberately out of scope — a price alert never
/// trades («هشدار قیمت به معنای انجام خودکار معامله نیست»).
abstract class PriceAlertsRepository {
  Future<List<PriceAlert>> load();

  Future<void> save(List<PriceAlert> alerts);
}

class PrefsPriceAlertsRepository implements PriceAlertsRepository {
  const PrefsPriceAlertsRepository();

  static const _key = 'market.priceAlerts';

  @override
  Future<List<PriceAlert>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return [
      for (final item in decoded)
        PriceAlert.fromJson((item as Map).cast<String, dynamic>()),
    ];
  }

  @override
  Future<void> save(List<PriceAlert> alerts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode([for (final a in alerts) a.toJson()]),
    );
  }
}

final priceAlertsRepositoryProvider = Provider<PriceAlertsRepository>(
  (ref) => const PrefsPriceAlertsRepository(),
);

class PriceAlertsNotifier extends AsyncNotifier<List<PriceAlert>> {
  @override
  Future<List<PriceAlert>> build() =>
      ref.watch(priceAlertsRepositoryProvider).load();

  Future<void> add(PriceAlert alert) =>
      _write([...state.value ?? const [], alert]);

  Future<void> remove(String id) =>
      _write([...?state.value?.where((a) => a.id != id)]);

  Future<void> setEnabled(String id, bool enabled) => _write([
    for (final a in state.value ?? const <PriceAlert>[])
      a.id == id ? a.copyWith(enabled: enabled) : a,
  ]);

  Future<void> _write(List<PriceAlert> next) async {
    state = AsyncData(next);
    await ref.read(priceAlertsRepositoryProvider).save(next);
  }
}

final priceAlertsProvider =
    AsyncNotifierProvider<PriceAlertsNotifier, List<PriceAlert>>(
      PriceAlertsNotifier.new,
    );

/// Recent search terms — session-scoped on purpose; the deck shows them but
/// nothing in the flow depends on them surviving a restart.
final recentSearchesProvider = StateProvider<List<String>>((ref) => const []);
