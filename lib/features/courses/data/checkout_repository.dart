import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/providers/session_provider.dart';
import 'courses_models.dart';

enum PaymentMethod {
  directGateway('درگاه بانکی مستقیم', 'کارت‌های عضو شتاب', available: true),
  bankWallet('کیف پول بانکی', 'به‌زودی', available: false),
  installments('پرداخت اقساطی', 'به‌زودی', available: false);

  const PaymentMethod(this.label, this.hint, {required this.available});

  final String label;
  final String hint;
  final bool available;
}

/// Screen/Checkout/PaymentSuccess · PaymentFailure · PaymentUnknown.
///
/// [unknown] is deliberately its own case: the deck keeps «وضعیت پرداخت
/// نامشخص» apart from «پرداخت ناموفق» because one means the money definitely
/// did not move and the other means nobody knows yet.
enum PaymentOutcome { success, failure, unknown }

/// A discount code the user typed. The backend has no validation endpoint, so
/// [percent] comes from [CheckoutRepository.applyDiscountCode].
class DiscountCode {
  const DiscountCode({required this.code, required this.percent});

  final String code;
  final int percent;
}

/// Checkout/OrderSummary — every figure the summary rows render.
class CheckoutTotals {
  const CheckoutTotals({
    required this.base,
    required this.discount,
    required this.coinDiscount,
    required this.payable,
  });

  /// Package price before any reduction.
  final int base;

  /// Discount-code reduction, in toman.
  final int discount;

  /// Pishro Coin reduction. Null while the amount is still «طبق قوانین
  /// محاسبه می‌شود» — the deck forbids showing a made-up conversion rate.
  final int? coinDiscount;

  final int payable;
}

/// Pure money maths, kept out of the widgets so it can be tested on its own.
///
/// Rounds the way `app/api/checkout/route.ts` does and never lets a discount
/// push the payable amount below zero.
CheckoutTotals computeTotals({
  required int base,
  DiscountCode? code,
  int? coinDiscount,
}) {
  final safeBase = base < 0 ? 0 : base;
  final rawDiscount = code == null
      ? 0
      : (safeBase * code.percent.clamp(0, 100) / 100).round();
  final discount = rawDiscount.clamp(0, safeBase);
  final coin = coinDiscount == null
      ? null
      : coinDiscount.clamp(0, safeBase - discount);
  return CheckoutTotals(
    base: safeBase,
    discount: discount,
    coinDiscount: coin,
    payable: safeBase - discount - (coin ?? 0),
  );
}

/// The whole checkout flow's state, carried from Course/Details through to the
/// result screen.
class CheckoutDraft {
  const CheckoutDraft({
    required this.course,
    required this.package,
    this.discount,
    this.discountError,
    this.applyingDiscount = false,
    this.useCoin = false,
    this.coinDiscount,
    this.method = PaymentMethod.directGateway,
    this.consentAccepted = false,
    this.showConsentError = false,
    this.submitting = false,
    this.orderId,
    this.serverTotal,
  });

  final Course course;
  final PackageType package;
  final DiscountCode? discount;
  final String? discountError;
  final bool applyingDiscount;
  final bool useCoin;
  final int? coinDiscount;
  final PaymentMethod method;
  final bool consentAccepted;
  final bool showConsentError;

  /// True from the moment the pay button is tapped until the gateway answers.
  /// `PishroButton(loading: true)` reads this, which is what blocks the
  /// double-submit the deck calls out.
  final bool submitting;

  final String? orderId;

  /// `POST /checkout` recomputes the total itself; when it disagrees with the
  /// client figure the server's number is the one that gets charged.
  final int? serverTotal;

  int get base => course.priceFor(package);

  CheckoutTotals get totals => computeTotals(
    base: base,
    code: discount,
    coinDiscount: useCoin ? coinDiscount : null,
  );

  /// «پرداخت ۲٬۴۹۰٬۰۰۰ تومان»
  String get payLabel => 'پرداخت ${Fmt.toman(totals.payable)}';

  bool get canSubmit => consentAccepted && !submitting;

  CheckoutDraft copyWith({
    PackageType? package,
    DiscountCode? discount,
    String? discountError,
    bool? applyingDiscount,
    bool? useCoin,
    int? coinDiscount,
    PaymentMethod? method,
    bool? consentAccepted,
    bool? showConsentError,
    bool? submitting,
    String? orderId,
    int? serverTotal,
    bool clearDiscount = false,
    bool clearDiscountError = false,
  }) => CheckoutDraft(
    course: course,
    package: package ?? this.package,
    discount: clearDiscount ? null : (discount ?? this.discount),
    discountError: clearDiscountError ? null : (discountError ?? this.discountError),
    applyingDiscount: applyingDiscount ?? this.applyingDiscount,
    useCoin: useCoin ?? this.useCoin,
    coinDiscount: coinDiscount ?? this.coinDiscount,
    method: method ?? this.method,
    consentAccepted: consentAccepted ?? this.consentAccepted,
    showConsentError: showConsentError ?? this.showConsentError,
    submitting: submitting ?? this.submitting,
    orderId: orderId ?? this.orderId,
    serverTotal: serverTotal ?? this.serverTotal,
  );
}

/// One row of `GET /user/orders`.
class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.total,
    required this.status,
    required this.paymentRef,
    required this.createdAt,
    required this.titles,
  });

  factory OrderSummary.fromJson(Map<String, dynamic> json) => OrderSummary(
    id: '${json['id'] ?? ''}',
    total: (json['total'] as num?)?.toInt() ?? 0,
    status: '${json['status'] ?? 'PENDING'}'.toUpperCase(),
    paymentRef: json['paymentRef'] as String?,
    createdAt: DateTime.tryParse('${json['createdAt'] ?? ''}'),
    titles: [
      for (final item in (json['items'] as List? ?? const []))
        if (item is Map && item['title'] != null) '${item['title']}',
    ],
  );

  final String id;
  final int total;
  final String status;
  final String? paymentRef;
  final DateTime? createdAt;
  final List<String> titles;

  PaymentOutcome get outcome => switch (status) {
    'PAID' => PaymentOutcome.success,
    'FAILED' => PaymentOutcome.failure,
    // PENDING after a gateway round-trip is exactly the indeterminate case.
    _ => PaymentOutcome.unknown,
  };

  /// «TXN-2K9-۸۸۲۱» — the reference the result screens quote.
  String get reference => Fmt.fa(paymentRef ?? 'TXN-${id.toUpperCase()}');
}

/// Pishro Coin balance. No endpoint exists; CLAUDE.md lists the coin slice as
/// mock-until-implemented.
class CoinBalance {
  const CoinBalance({required this.amount});

  final int amount;

  /// The deck is explicit: the balance is «غیرقابل برداشت» and carries no
  /// fixed conversion rate.
  static const withdrawable = false;
}

class CheckoutRepository {
  const CheckoutRepository(this._api);

  final ApiClient _api;

  /// `POST /checkout`.
  ///
  /// The handler takes `userId` from the request body rather than the session
  /// and recomputes the total from the course row, ignoring package type,
  /// discount code and coin. Whatever it returns as `total` is authoritative.
  Future<({String orderId, String payUrl, int total})> createOrder({
    required String courseId,
    required String userId,
  }) async {
    final data = await _api.post<Map<String, dynamic>>(
      '/checkout',
      body: {
        'userId': userId,
        'items': [
          {'courseId': courseId},
        ],
      },
    );
    return (
      orderId: '${data['orderId']}',
      payUrl: '${data['payUrl']}',
      total: (data['total'] as num?)?.toInt() ?? 0,
    );
  }

  /// `GET /user/orders` — paginated envelope. Used to resolve the outcome of a
  /// payment once the gateway hands control back.
  Future<List<OrderSummary>> orders({int page = 1, int limit = 20}) async {
    final data = await _api.get<Map<String, dynamic>>(
      '/user/orders',
      query: {'page': page, 'limit': limit},
    );
    return [
      for (final row in (data['items'] as List? ?? const []))
        if (row is Map) OrderSummary.fromJson(row.cast<String, dynamic>()),
    ];
  }

  /// `GET /cart` — pending orders. Returns `{orders, total, itemCount}`.
  Future<int> pendingItemCount() async {
    final data = await _api.get<Map<String, dynamic>>('/cart');
    return (data['itemCount'] as num?)?.toInt() ?? 0;
  }

  Future<PaymentOutcome> outcomeOf(String orderId) async {
    for (final order in await orders()) {
      if (order.id == orderId) return order.outcome;
    }
    return PaymentOutcome.unknown;
  }

  /// No discount-code endpoint exists. This is the deck's own example table;
  /// the moment a validation route ships it becomes one API call.
  // ponytail: local code table, swap for POST /discount/validate when it lands.
  Future<DiscountCode> applyDiscountCode(String raw) async {
    const known = {'PSX10': 10, 'PSX20': 20};
    final code = Fmt.toAscii(raw).trim().toUpperCase();
    final percent = known[code];
    if (percent == null) {
      throw const ValidationException('کد تخفیف واردشده معتبر نیست.', {
        'discountCode': 'کد تخفیف واردشده معتبر نیست.',
      });
    }
    return DiscountCode(code: code, percent: percent);
  }

  /// Mock — the coin ledger has no endpoint yet.
  Future<CoinBalance> coinBalance() async => const CoinBalance(amount: 1250);
}

final checkoutRepositoryProvider = Provider<CheckoutRepository>(
  (ref) => CheckoutRepository(ref.watch(apiClientProvider)),
);

final coinBalanceProvider = FutureProvider<CoinBalance>(
  (ref) => ref.watch(checkoutRepositoryProvider).coinBalance(),
);

final orderHistoryProvider = FutureProvider<List<OrderSummary>>(
  (ref) => ref.watch(checkoutRepositoryProvider).orders(),
);

/// The live checkout. Null until a package is picked on Course/Details or
/// PackageComparison; the checkout screens bounce back when it is.
final checkoutProvider =
    StateNotifierProvider<CheckoutController, CheckoutDraft?>(
      CheckoutController.new,
    );

class CheckoutController extends StateNotifier<CheckoutDraft?> {
  CheckoutController(this._ref) : super(null);

  final Ref _ref;

  void start(Course course, PackageType package) =>
      state = CheckoutDraft(course: course, package: package);

  void clear() => state = null;

  void setMethod(PaymentMethod method) {
    if (!method.available) return;
    state = state?.copyWith(method: method);
  }

  void setConsent(bool accepted) => state = state?.copyWith(
    consentAccepted: accepted,
    showConsentError: accepted ? false : state?.showConsentError,
  );

  /// «برای ادامه، پذیرش قوانین خرید الزامی است.» — the validation frame.
  void flagConsentMissing() => state = state?.copyWith(showConsentError: true);

  void toggleCoin(bool on) => state = state?.copyWith(useCoin: on);

  Future<void> applyDiscount(String code) async {
    final current = state;
    if (current == null) return;
    state = current.copyWith(applyingDiscount: true, clearDiscountError: true);
    try {
      final applied =
          await _ref.read(checkoutRepositoryProvider).applyDiscountCode(code);
      state = state?.copyWith(
        discount: applied,
        applyingDiscount: false,
        clearDiscountError: true,
      );
    } on ApiException catch (e) {
      state = state?.copyWith(
        applyingDiscount: false,
        discountError: e.message,
        clearDiscount: true,
      );
    }
  }

  void removeDiscount() => state = state?.copyWith(
    clearDiscount: true,
    clearDiscountError: true,
  );

  /// Creates the order. Returns the order id, or throws an [ApiException] that
  /// the Processing screen renders as its network-error frame.
  Future<String> submit() async {
    final current = state;
    if (current == null) throw const ServerException('سفارشی در جریان نیست.');
    if (current.submitting) throw const ServerException('پرداخت در حال انجام است.');

    final userId = _ref.read(sessionProvider).userId;
    if (userId == null) {
      throw const UnauthorizedException('برای پرداخت ابتدا وارد حساب شوید.');
    }

    state = current.copyWith(submitting: true);
    try {
      final order = await _ref
          .read(checkoutRepositoryProvider)
          .createOrder(courseId: current.course.id, userId: userId);
      state = state?.copyWith(
        submitting: false,
        orderId: order.orderId,
        serverTotal: order.total,
      );
      return order.orderId;
    } catch (_) {
      state = state?.copyWith(submitting: false);
      rethrow;
    }
  }
}
