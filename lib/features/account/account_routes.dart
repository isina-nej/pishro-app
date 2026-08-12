import 'package:go_router/go_router.dart';

import 'presentation/screens/devices_screen.dart';
import 'presentation/screens/edit_profile_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/investment_history_screen.dart';
import 'presentation/screens/kyc_overview_screen.dart';
import 'presentation/screens/kyc_verification_screen.dart';
import 'presentation/screens/legal_documents_screen.dart';
import 'presentation/screens/notifications_screen.dart';
import 'presentation/screens/pishro_coin_screen.dart';
import 'presentation/screens/preferences_screen.dart';
import 'presentation/screens/privacy_screen.dart';
import 'presentation/screens/profile_screen.dart';
import 'presentation/screens/purchase_history_screen.dart';
import 'presentation/screens/referrals_screen.dart';
import 'presentation/screens/saved_items_screen.dart';
import 'presentation/screens/security_screen.dart';
import 'presentation/screens/subscriptions_screen.dart';
import 'presentation/screens/support_screen.dart';
import 'presentation/screens/wallet_screen.dart';
import 'presentation/screens/wallet_transactions_screen.dart';

final List<RouteBase> accountRoutes = [
  GoRoute(
    path: '/account',
    builder: (_, __) => const AccountHomeScreen(),
    routes: [
      GoRoute(
        path: 'profile',
        builder: (_, __) => const AccountProfileScreen(),
        routes: [
          GoRoute(path: 'edit', builder: (_, __) => const EditProfileScreen()),
        ],
      ),
      GoRoute(
        path: 'kyc',
        builder: (_, __) => const KYCOverviewScreen(),
        routes: [
          GoRoute(
            path: 'verify',
            builder: (_, __) => const KYCVerificationScreen(),
          ),
        ],
      ),
      GoRoute(
        path: 'wallet',
        builder: (_, __) => const AccountWalletScreen(),
        routes: [
          GoRoute(
            path: 'transactions',
            builder: (_, __) => const WalletTransactionsScreen(),
          ),
        ],
      ),
      GoRoute(path: 'coin', builder: (_, __) => const PishroCoinScreen()),
      GoRoute(
        path: 'purchases',
        builder: (_, __) => const PurchaseHistoryScreen(),
      ),
      GoRoute(
        path: 'investments',
        builder: (_, __) => const InvestmentHistoryScreen(),
      ),
      GoRoute(
        path: 'subscriptions',
        builder: (_, __) => const AccountSubscriptionsScreen(),
      ),
      GoRoute(path: 'saved', builder: (_, __) => const SavedItemsScreen()),
      GoRoute(
        path: 'notifications',
        builder: (_, __) => const AccountNotificationsScreen(),
      ),
      GoRoute(
        path: 'security',
        builder: (_, __) => const AccountSecurityScreen(),
      ),
      GoRoute(
        path: 'devices',
        builder: (_, __) => const AccountDevicesScreen(),
      ),
      GoRoute(
        path: 'privacy',
        builder: (_, __) => const AccountPrivacyScreen(),
      ),
      GoRoute(
        path: 'support',
        builder: (_, __) => const AccountSupportScreen(),
      ),
      GoRoute(
        path: 'referrals',
        builder: (_, __) => const AccountReferralsScreen(),
      ),
      GoRoute(
        path: 'preferences',
        builder: (_, __) => const AccountPreferencesScreen(),
      ),
      GoRoute(path: 'legal', builder: (_, __) => const LegalDocumentsScreen()),
    ],
  ),
];
