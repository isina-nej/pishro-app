import '../../../core/utils/formatters.dart';

/// Per-provider health reported by the backend aggregator
/// (`lib/services/crypto-market-service.ts`). The deck is explicit that nothing
/// may be labelled «زنده» unless the backend says so, so this drives the
/// Market/DataStatus component rather than a client-side guess.
enum ProviderStatus {
  live('زنده'),
  fallback('جایگزین'),
  standby('آماده‌باش'),
  unavailable('در دسترس نیست'),
  unknown('نامشخص');

  const ProviderStatus(this.label);

  final String label;

  static ProviderStatus parse(Object? raw) => switch (raw) {
    'live' => ProviderStatus.live,
    'fallback' => ProviderStatus.fallback,
    'standby' => ProviderStatus.standby,
    'unavailable' => ProviderStatus.unavailable,
    _ => ProviderStatus.unknown,
  };
}

double? _num(Object? v) => v is num
    ? v.toDouble()
    : (v is String ? double.tryParse(v) : null);

double _numOr0(Object? v) => _num(v) ?? 0;

/// Persian names for the assets the backend can actually serve — the API only
/// returns Latin names, and Search must match «بیت‌کوین» as well as «BTC».
const _persianNames = <String, String>{
  'BTC': 'بیت‌کوین',
  'ETH': 'اتریوم',
  'USDT': 'تتر',
  'USDC': 'یواس‌دی‌کوین',
  'BNB': 'بایننس‌کوین',
  'SOL': 'سولانا',
  'XRP': 'ریپل',
  'ADA': 'کاردانو',
  'DOGE': 'دوج‌کوین',
  'TRX': 'ترون',
  'TON': 'تون‌کوین',
  'SHIB': 'شیبا اینو',
  'DOT': 'پولکادات',
  'LTC': 'لایت‌کوین',
  'LINK': 'چین‌لینک',
  'BCH': 'بیت‌کوین کش',
  'UNI': 'یونی‌سواپ',
  'NEAR': 'نیر پروتکل',
  'XLM': 'استلار',
  'ATOM': 'کازموس',
  'FIL': 'فایل‌کوین',
  'AVAX': 'آوالانچ',
  'MATIC': 'پالیگان',
  'POL': 'پالیگان',
};

/// Folds the spelling variants a Persian keyboard produces (Arabic ي/ك, ZWNJ,
/// spaces) plus Persian digits, so «بیت‌کوین» and «بیت کوین» hit the same key.
String normalizeQuery(String input) => Fmt.toAscii(input)
    .toLowerCase()
    .replaceAll('ي', 'ی')
    .replaceAll('ى', 'ی')
    .replaceAll('ك', 'ک')
    .replaceAll('ة', 'ه')
    .replaceAll(RegExp(r'[\s‌‏‎_\-]'), '');

/// One asset from `GET /public/crypto-market`.
class MarketAsset {
  const MarketAsset({
    required this.id,
    required this.name,
    required this.symbol,
    required this.imageUrl,
    required this.rank,
    required this.priceUsd,
    required this.priceIrt,
    required this.change24h,
    required this.change7d,
    required this.change30d,
    required this.volume24h,
    required this.marketCap,
    required this.fullyDilutedValuation,
    required this.high24h,
    required this.low24h,
    required this.athUsd,
    required this.athDate,
    required this.circulatingSupply,
    required this.maxSupply,
    required this.sparkline,
    required this.marketSource,
    required this.priceSource,
    required this.localSource,
  });

  factory MarketAsset.fromJson(Map<String, dynamic> json) {
    final sources = (json['sources'] as Map?)?.cast<String, dynamic>() ?? {};
    return MarketAsset(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      symbol: (json['symbol'] as String? ?? '').toUpperCase(),
      imageUrl: json['imageUrl'] as String?,
      rank: (_num(json['rank']) ?? 0).toInt(),
      priceUsd: _numOr0(json['priceUsd']),
      priceIrt: _num(json['priceIrt']),
      change24h: _numOr0(json['change24h']),
      change7d: _numOr0(json['change7d']),
      change30d: _numOr0(json['change30d']),
      volume24h: _numOr0(json['volume24h']),
      marketCap: _numOr0(json['marketCap']),
      fullyDilutedValuation: _num(json['fullyDilutedValuation']),
      high24h: _num(json['high24h']),
      low24h: _num(json['low24h']),
      athUsd: _num(json['athUsd']),
      athDate: DateTime.tryParse(json['athDate'] as String? ?? ''),
      circulatingSupply: _num(json['circulatingSupply']),
      maxSupply: _num(json['maxSupply']),
      sparkline: [
        for (final p in (json['sparkline'] as List? ?? const []))
          if (_num(p) case final v?) v,
      ],
      marketSource: sources['market'] as String? ?? 'نامشخص',
      priceSource: sources['price'] as String? ?? 'نامشخص',
      localSource: sources['local'] as String?,
    );
  }

  final String id;
  final String name;
  final String symbol;
  final String? imageUrl;
  final int rank;

  final double priceUsd;

  /// Toman. Null when neither Nobitex pair nor the USDT rate was reachable —
  /// render «داده در دسترس نیست», never zero (deck: Statistics/UnavailableValue).
  final double? priceIrt;

  final double change24h;
  final double change7d;
  final double change30d;

  /// USD.
  final double volume24h;
  final double marketCap;
  final double? fullyDilutedValuation;
  final double? high24h;
  final double? low24h;
  final double? athUsd;
  final DateTime? athDate;
  final double? circulatingSupply;
  final double? maxSupply;

  /// 7 days of hourly USD prices — the only price history the backend exposes.
  final List<double> sparkline;

  final String marketSource;
  final String priceSource;
  final String? localSource;

  String? get persianName => _persianNames[symbol];

  /// Implied toman/USD rate, used to present USD-denominated figures
  /// (market cap, volume, sparkline) in the toman the deck shows.
  double? get tomanPerUsd =>
      priceIrt != null && priceUsd > 0 ? priceIrt! / priceUsd : null;

  double? toToman(double? usd) {
    final rate = tomanPerUsd;
    return usd == null || rate == null ? null : usd * rate;
  }

  double changeFor(ChangeWindow window) => switch (window) {
    ChangeWindow.h24 => change24h,
    ChangeWindow.d7 => change7d,
    ChangeWindow.d30 => change30d,
  };

  /// Matches Latin name, ticker, CoinGecko id and the Persian name.
  bool matches(String query) {
    final q = normalizeQuery(query);
    if (q.isEmpty) return false;
    return normalizeQuery(name).contains(q) ||
        normalizeQuery(symbol).contains(q) ||
        normalizeQuery(id).contains(q) ||
        normalizeQuery(persianName ?? '').contains(q);
  }
}

enum ChangeWindow {
  h24('۲۴ ساعت'),
  d7('۷ روز'),
  d30('۳۰ روز');

  const ChangeWindow(this.label);

  final String label;
}

class GlobalMarket {
  const GlobalMarket({
    required this.marketCap,
    required this.volume24h,
    required this.btcDominance,
    required this.marketCapChange24h,
    required this.activeCryptocurrencies,
    required this.source,
  });

  factory GlobalMarket.fromJson(Map<String, dynamic> json) => GlobalMarket(
    marketCap: _numOr0(json['marketCap']),
    volume24h: _numOr0(json['volume24h']),
    btcDominance: _numOr0(json['btcDominance']),
    marketCapChange24h: _numOr0(json['marketCapChange24h']),
    activeCryptocurrencies: _num(json['activeCryptocurrencies'])?.toInt(),
    source: json['source'] as String? ?? 'نامشخص',
  );

  final double marketCap;
  final double volume24h;
  final double btcDominance;
  final double marketCapChange24h;
  final int? activeCryptocurrencies;
  final String source;
}

/// The four upstreams the backend aggregates, with their last known state.
class ProviderReport {
  const ProviderReport(this.statuses);

  factory ProviderReport.fromJson(Map<String, dynamic> json) => ProviderReport({
    for (final e in json.entries) e.key: ProviderStatus.parse(e.value),
  });

  final Map<String, ProviderStatus> statuses;

  /// The deck's rule: «زنده» only when the backend confirms a live provider.
  bool get hasLive => statuses.values.contains(ProviderStatus.live);

  Iterable<MapEntry<String, ProviderStatus>> get entries => statuses.entries;
}

class MarketSnapshot {
  const MarketSnapshot({
    required this.generatedAt,
    required this.assets,
    required this.global,
    required this.providers,
  });

  factory MarketSnapshot.fromJson(Map<String, dynamic> json) => MarketSnapshot(
    generatedAt:
        DateTime.tryParse(json['generatedAt'] as String? ?? '') ??
        DateTime.now(),
    assets: [
      for (final a in (json['assets'] as List? ?? const []))
        MarketAsset.fromJson((a as Map).cast<String, dynamic>()),
    ],
    global: GlobalMarket.fromJson(
      (json['global'] as Map?)?.cast<String, dynamic>() ?? const {},
    ),
    providers: ProviderReport.fromJson(
      (json['providers'] as Map?)?.cast<String, dynamic>() ?? const {},
    ),
  );

  final DateTime generatedAt;
  final List<MarketAsset> assets;
  final GlobalMarket global;
  final ProviderReport providers;

  MarketAsset? byId(String id) {
    for (final a in assets) {
      if (a.id == id) return a;
    }
    return null;
  }

  /// Highest movers first. [losers] flips to the deepest fall first.
  List<MarketAsset> ranked(ChangeWindow window, {bool losers = false}) {
    final sorted = [...assets]
      ..sort((a, b) => b.changeFor(window).compareTo(a.changeFor(window)));
    final filtered = sorted.where(
      (a) => losers ? a.changeFor(window) < 0 : a.changeFor(window) > 0,
    );
    return losers ? filtered.toList().reversed.toList() : filtered.toList();
  }
}

class AssetDetail {
  const AssetDetail({
    required this.generatedAt,
    required this.asset,
    required this.providers,
  });

  factory AssetDetail.fromJson(Map<String, dynamic> json) => AssetDetail(
    generatedAt:
        DateTime.tryParse(json['generatedAt'] as String? ?? '') ??
        DateTime.now(),
    asset: MarketAsset.fromJson(
      (json['asset'] as Map?)?.cast<String, dynamic>() ?? const {},
    ),
    providers: ProviderReport.fromJson(
      (json['providers'] as Map?)?.cast<String, dynamic>() ?? const {},
    ),
  );

  final DateTime generatedAt;
  final MarketAsset asset;
  final ProviderReport providers;
}

/// One trading day folded out of the hourly sparkline.
class DailyCandle {
  const DailyCandle({
    required this.day,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });

  final DateTime day;
  final double open;
  final double high;
  final double low;
  final double close;

  double get changePercent => open == 0 ? 0 : (close - open) / open * 100;
}

/// The sparkline is 7 days of hourly USD prices ending at [endsAt]; the deck's
/// HistoricalData screen wants daily OHLC, so fold it here rather than ask the
/// backend for an endpoint that does not exist.
List<DailyCandle> dailyCandles(List<double> hourly, DateTime endsAt) {
  if (hourly.isEmpty) return const [];
  final buckets = <DateTime, List<double>>{};
  for (var i = 0; i < hourly.length; i++) {
    final at = endsAt.subtract(Duration(hours: hourly.length - 1 - i));
    final day = DateTime(at.year, at.month, at.day);
    (buckets[day] ??= []).add(hourly[i]);
  }
  final days = buckets.keys.toList()..sort((a, b) => b.compareTo(a));
  return [
    for (final day in days)
      DailyCandle(
        day: day,
        open: buckets[day]!.first,
        high: buckets[day]!.reduce((a, b) => a > b ? a : b),
        low: buckets[day]!.reduce((a, b) => a < b ? a : b),
        close: buckets[day]!.last,
      ),
  ];
}

/// Persian-digit toman amount. Keeps two decimals below ۱۰۰۰ so sub-toman
/// assets (SHIB) do not collapse to «۰».
String faToman(num value) => value != 0 && value.abs() < 1000
    ? Fmt.fa(value.toStringAsFixed(2)).replaceAll('.', '٫')
    : Fmt.grouped(value);

/// «۳٬۳۸۰م» — the abbreviated cell the HistoricalData deck frame uses.
String faMillions(num value) => '${Fmt.grouped(value / 1e6)}م';
