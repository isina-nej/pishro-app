import '../../../shared/widgets/pishro_badge.dart' show RiskLevel;

/// The deck's own placeholder string. Used verbatim wherever the backend cannot
/// supply a figure — the decks never fake a number, they label the hole.
const kSampleValue = 'مقدار نمونه';

/// «طبق شرایط قرارداد» — rendered instead of a computed figure wherever the
/// deck defers to the contract.
const kPerContract = 'طبق شرایط قرارداد';

/// «طبق برنامه قرارداد» — the deck's next-payment placeholder.
const kPerContractSchedule = 'طبق برنامه قرارداد';

/// How a plan's return is expressed.
///
/// The backend has no column for this: `InvestmentFund` stores a `monthlyRate`
/// for every fund, including the hold fund whose seed comment marks the value
/// as a placeholder. The deck is explicit that the hold plan must never show a
/// percentage («بدون درصد اختراعی»), so the classification lives here and the
/// rate is dropped for dynamic plans.
enum ReturnModel {
  /// «نرخ اعلام‌شده» — the fund publishes a monthly rate.
  stated,

  /// «داینامیک» — variable, no fixed rate. Never render a percentage.
  dynamicReturn,
}

/// A purchasable plan. Maps `GET /investment-funds` (`InvestmentFund`).
class InvestmentPlan {
  const InvestmentPlan({
    required this.id,
    required this.key,
    required this.name,
    required this.returnModel,
    required this.riskLevel,
    required this.monthlyRate,
    required this.minDurationMonths,
    required this.maxDurationMonths,
    required this.durationStep,
    required this.minAmount,
    required this.maxAmount,
    required this.amountStep,
    this.description,
  });

  final String id;
  final String key;
  final String name;
  final String? description;

  final ReturnModel returnModel;
  final RiskLevel riskLevel;

  /// Fraction, e.g. `0.08` for ۸٪. **Null for [ReturnModel.dynamicReturn]** —
  /// nothing downstream may render or compute a percentage from a null rate.
  final double? monthlyRate;

  final int minDurationMonths;
  final int maxDurationMonths;
  final int durationStep;

  final int minAmount;
  final int maxAmount;
  final int amountStep;

  bool get isDynamic => returnModel == ReturnModel.dynamicReturn;

  /// «۸٪ ماهیانه» — null when the plan has no stated rate.
  double? get monthlyRatePercent =>
      monthlyRate == null ? null : monthlyRate! * 100;

  /// Selectable durations, honouring the fund's step.
  List<int> get durationOptions {
    final out = <int>[];
    for (var m = minDurationMonths; m <= maxDurationMonths; m += durationStep) {
      out.add(m);
    }
    return out.isEmpty ? [minDurationMonths] : out;
  }

  /// Monthly estimate — «برآورد», never a guarantee. Null when the plan has no
  /// stated rate, which is the signal to render [kPerContract] instead.
  int? monthlyEstimate(int amount) =>
      monthlyRate == null ? null : (amount * monthlyRate!).round();

  /// Total estimated return over [months]. Null for dynamic plans.
  int? totalEstimate(int amount, int months) {
    final monthly = monthlyEstimate(amount);
    return monthly == null ? null : monthly * months;
  }

  factory InvestmentPlan.fromJson(Map<String, dynamic> json) {
    final key = (json['key'] as String?) ?? '';
    // No `returnModel` / `riskLevel` column exists upstream. `key` is the only
    // stable discriminator the API exposes.
    final dynamicPlan = key.contains('hold');

    return InvestmentPlan(
      id: (json['id'] as String?) ?? key,
      key: key,
      name: (json['name'] as String?) ?? '',
      description: json['description'] as String?,
      returnModel:
          dynamicPlan ? ReturnModel.dynamicReturn : ReturnModel.stated,
      // The deck labels the stated-rate fund «ریسک متوسط» and the hold fund
      // «ریسک بالا». Always rendered through RiskBadge (icon + label).
      riskLevel: dynamicPlan ? RiskLevel.high : RiskLevel.medium,
      monthlyRate:
          dynamicPlan ? null : (json['monthlyRate'] as num?)?.toDouble(),
      minDurationMonths: (json['minDuration'] as num?)?.toInt() ?? 1,
      maxDurationMonths: (json['maxDuration'] as num?)?.toInt() ?? 12,
      durationStep: (json['durationStep'] as num?)?.toInt() ?? 1,
      minAmount: (json['minAmount'] as num?)?.toInt() ?? 0,
      maxAmount: (json['maxAmount'] as num?)?.toInt() ?? 0,
      amountStep: (json['amountStep'] as num?)?.toInt() ?? 1,
    );
  }
}

/// Landing copy for the catalog header — `GET /landing/investment-plans`.
/// Marketing content only: it carries no rates, amounts, durations or risk.
class PlanCatalogIntro {
  const PlanCatalogIntro({required this.title, required this.description});

  final String title;
  final String description;

  factory PlanCatalogIntro.fromJson(Map<String, dynamic> json) =>
      PlanCatalogIntro(
        title: (json['title'] as String?) ?? '',
        description: (json['description'] as String?) ?? '',
      );
}

enum TxStatus { pending, success, failed }

/// A row of `GET /user/transactions`.
///
/// This is the *only* record of a user's money the API exposes. It carries no
/// plan reference, no duration and no schedule, so every screen built on it
/// says so rather than inferring.
class InvestmentTransaction {
  const InvestmentTransaction({
    required this.id,
    required this.amount,
    required this.status,
    required this.type,
    required this.createdAt,
    this.gateway,
    this.refNumber,
    this.description,
  });

  final String id;
  final int amount;
  final TxStatus status;
  final String type;
  final DateTime createdAt;
  final String? gateway;
  final String? refNumber;
  final String? description;

  /// «فعال» / «در انتظار فعال‌سازی» / «ناموفق».
  /// A pending record is never presented as a failure — deck rule
  /// «نامشخص هرگز به‌عنوان ناموفق نمایش داده نمی‌شود».
  String get investmentStatusLabel => switch (status) {
        TxStatus.success => 'فعال',
        TxStatus.pending => 'در انتظار فعال‌سازی',
        TxStatus.failed => 'ناموفق',
      };

  /// «پرداخت‌شده» / «در حال بررسی» / «ناموفق» — PaymentSchedule wording.
  String get scheduleStatusLabel => switch (status) {
        TxStatus.success => 'پرداخت‌شده',
        TxStatus.pending => 'در حال بررسی',
        TxStatus.failed => 'ناموفق',
      };

  /// The API has no plan reference on a transaction; `description` is the
  /// closest human label it offers.
  String get title => (description != null && description!.isNotEmpty)
      ? description!
      : 'سرمایه‌گذاری ثبت‌شده';

  factory InvestmentTransaction.fromJson(Map<String, dynamic> json) =>
      InvestmentTransaction(
        id: (json['id'] as String?) ?? '',
        amount: (json['amount'] as num?)?.toInt() ?? 0,
        status: switch ((json['status'] as String?)?.toUpperCase()) {
          'SUCCESS' => TxStatus.success,
          'FAILED' => TxStatus.failed,
          _ => TxStatus.pending,
        },
        type: (json['type'] as String?) ?? 'PAYMENT',
        createdAt:
            DateTime.tryParse((json['createdAt'] as String?) ?? '')?.toLocal() ??
                DateTime.now(),
        gateway: json['gateway'] as String?,
        refNumber: json['refNumber'] as String?,
        description: json['description'] as String?,
      );
}

/// Where the money comes from — Screen/Investment/FundingSource.
enum FundingSourceKind { wallet, gateway, bankTransfer }

extension FundingSourceLabels on FundingSourceKind {
  String get title => switch (this) {
        FundingSourceKind.wallet => 'کیف پول داخلی',
        FundingSourceKind.gateway => 'درگاه پرداخت بانکی',
        FundingSourceKind.bankTransfer => 'انتقال بانکی با شناسه واریز',
      };

  /// The wallet balance and the bank-transfer settlement time have no endpoint,
  /// so both fall back to the deck's own placeholder.
  String get subtitle => switch (this) {
        FundingSourceKind.wallet => 'موجودی: $kSampleValue',
        FundingSourceKind.gateway => 'پرداخت امن از طریق درگاه بانکی',
        FundingSourceKind.bankTransfer => 'زمان تأیید: $kSampleValue',
      };
}

// ---------------------------------------------------------------------------
// KYC / eligibility — no backend endpoint (see KycRepository).
// ---------------------------------------------------------------------------

enum CheckStatus { verified, pending, missing }

extension CheckStatusLabel on CheckStatus {
  String get label => switch (this) {
        CheckStatus.verified => 'تأییدشده',
        CheckStatus.pending => 'در حال بررسی',
        CheckStatus.missing => 'تکمیل نشده',
      };
}

class EligibilityCheck {
  const EligibilityCheck(this.title, this.status);
  final String title;
  final CheckStatus status;
}

class Eligibility {
  const Eligibility(this.checks);
  final List<EligibilityCheck> checks;

  bool get isEligible =>
      checks.every((c) => c.status == CheckStatus.verified);

  bool get isPending =>
      !isEligible && checks.any((c) => c.status == CheckStatus.pending);
}
