import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import 'investment_models.dart';

/// Investment data access.
///
/// Endpoint reality (verified against `pishro/app/api/…`):
/// * `GET /investment-funds`        → the only source of plan economics.
/// * `GET /landing/investment-plans`→ landing copy; no economics.
/// * `POST /cart/add-portfolio`     → creates a PENDING **order**, not an
///   activated investment. It returns `{orderId, message}` only.
/// * `GET /user/transactions`       → payment rows; no plan, no schedule.
class InvestmentRepository {
  const InvestmentRepository(this._api);

  final ApiClient _api;

  Future<List<InvestmentPlan>> plans() async {
    final data = await _api.get<List<dynamic>>('/investment-funds');
    return data
        .whereType<Map<String, dynamic>>()
        .map(InvestmentPlan.fromJson)
        .toList();
  }

  /// Header copy for the catalog. Optional: the screen renders without it.
  Future<PlanCatalogIntro> catalogIntro() async {
    final data = await _api.get<Map<String, dynamic>>(
      '/landing/investment-plans',
    );
    return PlanCatalogIntro.fromJson(data);
  }

  Future<List<InvestmentTransaction>> transactions({
    int page = 1,
    int limit = 20,
  }) async {
    final data = await _api.get<Map<String, dynamic>>(
      '/user/transactions',
      query: {'page': page, 'limit': limit},
    );
    final items = data['items'] as List<dynamic>? ?? const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(InvestmentTransaction.fromJson)
        .toList();
  }

  /// Submits the investment request. Returns the created order id.
  ///
  /// `portfolioType` is the server's own `low|medium|high` whitelist, which is
  /// the same taxonomy as [RiskLevel]. `monthlyRate`/`expectedReturn` are sent
  /// as null for dynamic plans — there is no rate to send and none may be
  /// invented.
  Future<String> submitPortfolio({
    required InvestmentPlan plan,
    required int amount,
    required int durationMonths,
  }) async {
    final res = await _api.post<Map<String, dynamic>>(
      '/cart/add-portfolio',
      body: {
        'portfolioType': plan.riskLevel.name,
        'portfolioAmount': amount,
        'portfolioDuration': durationMonths,
        'expectedReturn': plan.totalEstimate(amount, durationMonths),
        'monthlyRate': plan.monthlyRate,
        'price': amount,
      },
    );
    return (res['orderId'] as String?) ?? '';
  }
}

final investmentRepositoryProvider = Provider<InvestmentRepository>(
  (ref) => InvestmentRepository(ref.watch(apiClientProvider)),
);

final plansProvider = FutureProvider<List<InvestmentPlan>>(
  (ref) => ref.watch(investmentRepositoryProvider).plans(),
);

/// Single plan by id, resolved from the same list the catalog uses.
final planProvider = FutureProvider.family<InvestmentPlan?, String>((
  ref,
  id,
) async {
  final plans = await ref.watch(plansProvider.future);
  for (final p in plans) {
    if (p.id == id || p.key == id) return p;
  }
  return null;
});

final catalogIntroProvider = FutureProvider<PlanCatalogIntro>(
  (ref) => ref.watch(investmentRepositoryProvider).catalogIntro(),
);

final transactionsProvider = FutureProvider<List<InvestmentTransaction>>(
  (ref) => ref.watch(investmentRepositoryProvider).transactions(),
);

final transactionProvider =
    FutureProvider.family<InvestmentTransaction?, String>((ref, id) async {
      final all = await ref.watch(transactionsProvider.future);
      for (final t in all) {
        if (t.id == id) return t;
      }
      return null;
    });
