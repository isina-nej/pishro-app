import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import 'investment_models.dart';
import 'investment_repository.dart';

/// The four acknowledgements Screen/Investment/RiskDisclosure requires. The
/// deck is explicit that they are separate and never pre-selected — one
/// blanket checkbox would not be informed consent.
const kRiskAcknowledgements = [
  'ریسک‌های این طرح را مطالعه کرده‌ام.',
  'می‌دانم نرخ اعلام‌شده به معنای تضمین پرداخت نیست.',
  'شرایط برداشت و خروج زودهنگام را بررسی کرده‌ام.',
  'از امکان کاهش یا تغییر بازده در طرح داینامیک آگاه هستم.',
];

/// Flow state from PlanDetails → Success. Never invents a rate or ROI.
@immutable
class InvestmentDraft {
  const InvestmentDraft({
    this.plan,
    this.amount = 0,
    this.durationMonths = 1,
    this.funding = FundingSourceKind.gateway,
    this.riskChecks = const {},
    this.termsAccepted = false,
    this.showConsentError = false,
    this.submitting = false,
    this.orderId,
  });

  final InvestmentPlan? plan;
  final int amount;
  final int durationMonths;
  final FundingSourceKind funding;

  /// Indices into [kRiskAcknowledgements] the user has ticked.
  final Set<int> riskChecks;
  final bool termsAccepted;
  final bool showConsentError;
  final bool submitting;
  final String? orderId;

  /// Every acknowledgement ticked — the gate the deck's CTA waits on.
  bool get riskAccepted => riskChecks.length == kRiskAcknowledgements.length;

  bool get consentsOk => riskAccepted && termsAccepted;

  bool get amountValid {
    final p = plan;
    if (p == null) return false;
    if (amount < p.minAmount || amount > p.maxAmount) return false;
    if (p.amountStep <= 0) return true;
    return (amount - p.minAmount) % p.amountStep == 0;
  }

  int? get monthlyEstimate => plan?.monthlyEstimate(amount);

  int? get totalEstimate => plan?.totalEstimate(amount, durationMonths);

  InvestmentDraft copyWith({
    InvestmentPlan? plan,
    int? amount,
    int? durationMonths,
    FundingSourceKind? funding,
    Set<int>? riskChecks,
    bool? termsAccepted,
    bool? showConsentError,
    bool? submitting,
    String? orderId,
    bool clearOrder = false,
  }) => InvestmentDraft(
    plan: plan ?? this.plan,
    amount: amount ?? this.amount,
    durationMonths: durationMonths ?? this.durationMonths,
    funding: funding ?? this.funding,
    riskChecks: riskChecks ?? this.riskChecks,
    termsAccepted: termsAccepted ?? this.termsAccepted,
    showConsentError: showConsentError ?? this.showConsentError,
    submitting: submitting ?? this.submitting,
    orderId: clearOrder ? null : (orderId ?? this.orderId),
  );
}

class InvestmentFlowNotifier extends StateNotifier<InvestmentDraft> {
  InvestmentFlowNotifier(this._ref) : super(const InvestmentDraft());

  final Ref _ref;

  void start(InvestmentPlan plan) {
    final duration = plan.durationOptions.isEmpty
        ? plan.minDurationMonths
        : plan.durationOptions.first;
    state = InvestmentDraft(
      plan: plan,
      amount: plan.minAmount,
      durationMonths: duration,
    );
  }

  void setAmount(int amount) => state = state.copyWith(amount: amount);

  void setDuration(int months) =>
      state = state.copyWith(durationMonths: months);

  void setFunding(FundingSourceKind source) =>
      state = state.copyWith(funding: source);

  void toggleRiskCheck(int index, bool v) {
    final next = {...state.riskChecks};
    v ? next.add(index) : next.remove(index);
    state = state.copyWith(
      riskChecks: next,
      showConsentError: v ? false : state.showConsentError,
    );
  }

  /// The final confirmation screen re-asks for one combined acknowledgement,
  /// which stands in for all four.
  void setAllRiskChecks(bool v) => state = state.copyWith(
    riskChecks: v
        ? {for (var i = 0; i < kRiskAcknowledgements.length; i++) i}
        : const {},
    showConsentError: v ? false : state.showConsentError,
  );

  void setTermsAccepted(bool v) => state = state.copyWith(
    termsAccepted: v,
    showConsentError: v ? false : state.showConsentError,
  );

  void flagConsentMissing() => state = state.copyWith(showConsentError: true);

  Future<String> submit() async {
    final draft = state;
    final plan = draft.plan;
    if (plan == null) {
      throw const ServerException('طرحی انتخاب نشده است.');
    }
    if (draft.submitting) {
      throw const ServerException('درخواست در حال ثبت است.');
    }
    if (!draft.consentsOk) {
      flagConsentMissing();
      throw const ValidationException(
        'پذیرش ریسک و شرایط قرارداد الزامی است.',
        {'consent': 'پذیرش ریسک و شرایط قرارداد الزامی است.'},
      );
    }
    if (!draft.amountValid) {
      throw const ValidationException('مبلغ واردشده در بازه طرح نیست.', {
        'amount': 'مبلغ واردشده در بازه طرح نیست.',
      });
    }
    state = draft.copyWith(submitting: true);
    try {
      final id = await _ref
          .read(investmentRepositoryProvider)
          .submitPortfolio(
            plan: plan,
            amount: draft.amount,
            durationMonths: draft.durationMonths,
          );
      state = state.copyWith(submitting: false, orderId: id);
      return id;
    } catch (_) {
      state = state.copyWith(submitting: false);
      rethrow;
    }
  }
}

final investmentFlowProvider =
    StateNotifierProvider<InvestmentFlowNotifier, InvestmentDraft>(
      InvestmentFlowNotifier.new,
    );

/// Mock eligibility — no KYC endpoint exists yet.
final eligibilityProvider = Provider<Eligibility>(
  (ref) => const Eligibility([
    EligibilityCheck('اطلاعات هویتی', CheckStatus.verified),
    EligibilityCheck('شماره موبایل تأییدشده', CheckStatus.verified),
    EligibilityCheck('حساب بانکی به نام کاربر', CheckStatus.verified),
    EligibilityCheck('مطالعه اطلاع‌رسانی ریسک', CheckStatus.verified),
    EligibilityCheck('پذیرش شرایط قرارداد', CheckStatus.verified),
  ]),
);
