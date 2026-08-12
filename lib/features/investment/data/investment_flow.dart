import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import 'investment_models.dart';
import 'investment_repository.dart';

/// Flow state from PlanDetails → Success. Never invents a rate or ROI.
@immutable
class InvestmentDraft {
  const InvestmentDraft({
    this.plan,
    this.amount = 0,
    this.durationMonths = 1,
    this.funding = FundingSourceKind.gateway,
    this.riskAccepted = false,
    this.termsAccepted = false,
    this.showConsentError = false,
    this.submitting = false,
    this.orderId,
  });

  final InvestmentPlan? plan;
  final int amount;
  final int durationMonths;
  final FundingSourceKind funding;
  final bool riskAccepted;
  final bool termsAccepted;
  final bool showConsentError;
  final bool submitting;
  final String? orderId;

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
    bool? riskAccepted,
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
    riskAccepted: riskAccepted ?? this.riskAccepted,
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

  void setRiskAccepted(bool v) => state = state.copyWith(
    riskAccepted: v,
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
    EligibilityCheck('احراز هویت', CheckStatus.verified),
    EligibilityCheck('شماره شبا', CheckStatus.pending),
    EligibilityCheck('نشانی محل سکونت', CheckStatus.missing),
  ]),
);
