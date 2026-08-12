import 'package:go_router/go_router.dart';

import 'presentation/screens/active_investment_details_screen.dart';
import 'presentation/screens/active_investments_screen.dart';
import 'presentation/screens/amount_entry_screen.dart';
import 'presentation/screens/calculator_screen.dart';
import 'presentation/screens/contract_confirmation_screen.dart';
import 'presentation/screens/eligibility_kyc_screen.dart';
import 'presentation/screens/final_review_screen.dart';
import 'presentation/screens/fixed_monthly_plan_details_screen.dart';
import 'presentation/screens/funding_source_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/payment_schedule_screen.dart';
import 'presentation/screens/plan_catalog_screen.dart';
import 'presentation/screens/plan_comparison_screen.dart';
import 'presentation/screens/processing_screen.dart';
import 'presentation/screens/risk_disclosure_screen.dart';
import 'presentation/screens/success_screen.dart';
import 'presentation/screens/terms_and_contract_screen.dart';

final List<RouteBase> investmentRoutes = [
  GoRoute(
    path: '/investment',
    builder: (_, __) => const InvestmentHomeScreen(),
    routes: [
      GoRoute(
        path: 'plans',
        builder: (_, __) => const PlanCatalogScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) => FixedMonthlyPlanDetailsScreen(
              id: state.pathParameters['id'] ?? '',
            ),
          ),
        ],
      ),
      GoRoute(
        path: 'compare',
        builder: (_, __) => const PlanComparisonScreen(),
      ),
      GoRoute(
        path: 'calculator',
        builder: (_, __) => const InvestmentCalculatorScreen(),
      ),
      GoRoute(path: 'risk', builder: (_, __) => const RiskDisclosureScreen()),
      GoRoute(
        path: 'terms',
        builder: (_, __) => const TermsAndContractScreen(),
      ),
      GoRoute(path: 'kyc', builder: (_, __) => const EligibilityAndKYCScreen()),
      GoRoute(path: 'amount', builder: (_, __) => const AmountEntryScreen()),
      GoRoute(path: 'funding', builder: (_, __) => const FundingSourceScreen()),
      GoRoute(path: 'review', builder: (_, __) => const FinalReviewScreen()),
      GoRoute(
        path: 'contract',
        builder: (_, __) => const ContractConfirmationScreen(),
      ),
      GoRoute(
        path: 'processing',
        builder: (_, __) => const InvestmentProcessingScreen(),
      ),
      GoRoute(
        path: 'success',
        builder: (_, __) => const InvestmentSuccessScreen(),
      ),
      GoRoute(
        path: 'active',
        builder: (_, __) => const ActiveInvestmentsScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) => ActiveInvestmentDetailsScreen(
              id: state.pathParameters['id'] ?? '',
            ),
            routes: [
              GoRoute(
                path: 'schedule',
                builder: (context, state) =>
                    PaymentScheduleScreen(id: state.pathParameters['id'] ?? ''),
              ),
            ],
          ),
        ],
      ),
    ],
  ),
];
