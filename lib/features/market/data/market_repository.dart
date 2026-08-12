import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import 'market_models.dart';

/// `GET /public/crypto-market` · `GET /public/crypto-market/{id}`.
///
/// Both handlers wrap their payload in the JSend envelope, which [ApiClient]
/// already strips, so these only translate JSON to models and let
/// [ApiException] propagate.
class MarketRepository {
  const MarketRepository(this._api);

  final ApiClient _api;

  Future<MarketSnapshot> fetchMarket({int limit = 100}) async {
    final data = await _api.get<Map<String, dynamic>>(
      '/public/crypto-market',
      query: {'limit': limit},
    );
    return MarketSnapshot.fromJson(data);
  }

  Future<AssetDetail> fetchAsset(String id) async {
    final data = await _api.get<Map<String, dynamic>>(
      '/public/crypto-market/$id',
    );
    return AssetDetail.fromJson(data);
  }
}

final marketRepositoryProvider = Provider<MarketRepository>(
  (ref) => MarketRepository(ref.watch(apiClientProvider)),
);

/// The whole market list. Every list screen filters/sorts this one fetch
/// instead of asking the backend again — the endpoint answers with the full
/// snapshot and is cached for 30s upstream.
final marketSnapshotProvider = FutureProvider<MarketSnapshot>(
  (ref) => ref.watch(marketRepositoryProvider).fetchMarket(),
);

/// Detail adds the CoinGecko per-coin merge (supply, ATH, full sparkline).
final assetDetailProvider = FutureProvider.family<AssetDetail, String>(
  (ref, id) => ref.watch(marketRepositoryProvider).fetchAsset(id),
);
