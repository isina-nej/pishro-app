import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/providers/session_provider.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/account_repository.dart';

/// Screen/Account/Home.
class AccountHomeScreen extends ConsumerWidget {
  const AccountHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final session = ref.watch(sessionProvider);
    final profile = ref.watch(accountProfileProvider);

    if (!session.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'حساب کاربری',
            style: context.text.h2.copyWith(color: c.textPrimary),
          ),
        ),
        body: EmptyState(
          title: 'وارد حساب نشده‌اید',
          actionLabel: 'ورود',
          onAction: () => context.push(Routes.login),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'حساب کاربری',
          style: context.text.h2.copyWith(color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: Space.s8),
        children: [
          Padding(
            padding: const EdgeInsets.all(Space.page),
            child: PishroCard(
              onTap: () => context.push(Routes.profile),
              child: profile.when(
                loading: () => const Skeleton.line(width: 180),
                error: (_, __) => Text(
                  'پروفایل بارگذاری نشد',
                  style: context.text.bodySmall.copyWith(color: c.textMuted),
                ),
                data: (p) => Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: c.surfaceSecondary,
                      child: Text(
                        p.displayName.characters.first,
                        style: context.text.h3.copyWith(color: c.textPrimary),
                      ),
                    ),
                    const SizedBox(width: Space.s3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.displayName,
                            style: context.text.bodyLarge.copyWith(
                              color: c.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            Fmt.maskPhone(p.phone),
                            style: context.text.caption.copyWith(
                              color: c.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_left_rounded, color: c.textMuted),
                  ],
                ),
              ),
            ),
          ),
          _Item(
            'احراز هویت',
            Icons.verified_outlined,
            () => context.push(Routes.kycOverview),
          ),
          _Item(
            'کیف پول',
            Icons.account_balance_wallet_outlined,
            () => context.push(Routes.wallet),
          ),
          _Item(
            'پیشرو کوین',
            Icons.stars_outlined,
            () => context.push(Routes.pishroCoin),
          ),
          _Item(
            'خریدها',
            Icons.receipt_long_outlined,
            () => context.push(Routes.purchaseHistory),
          ),
          _Item(
            'سرمایه‌گذاری‌ها',
            Icons.trending_up_rounded,
            () => context.push(Routes.investmentHistory),
          ),
          _Item(
            'اشتراک‌ها',
            Icons.card_membership_outlined,
            () => context.push(Routes.accountSubscriptions),
          ),
          _Item(
            'ذخیره‌شده‌ها',
            Icons.bookmark_border_rounded,
            () => context.push(Routes.savedItems),
          ),
          _Item(
            'اعلان‌ها',
            Icons.notifications_none_rounded,
            () => context.push(Routes.notifications),
          ),
          _Item(
            'امنیت',
            Icons.lock_outline_rounded,
            () => context.push(Routes.security),
          ),
          _Item(
            'دستگاه‌ها',
            Icons.devices_outlined,
            () => context.push(Routes.devices),
          ),
          _Item(
            'حریم خصوصی',
            Icons.privacy_tip_outlined,
            () => context.push(Routes.privacy),
          ),
          _Item(
            'پشتیبانی',
            Icons.support_agent_rounded,
            () => context.push(Routes.support),
          ),
          _Item(
            'معرفی دوستان',
            Icons.group_add_outlined,
            () => context.push(Routes.referrals),
          ),
          _Item(
            'ترجیحات',
            Icons.tune_rounded,
            () => context.push(Routes.preferences),
          ),
          _Item(
            'اسناد حقوقی',
            Icons.gavel_outlined,
            () => context.push(Routes.legalDocuments),
          ),
          Padding(
            padding: const EdgeInsets.all(Space.page),
            child: PishroButton(
              label: 'خروج از حساب',
              variant: PishroButtonVariant.danger,
              onPressed: () async {
                await ref.read(sessionProvider.notifier).signOut();
                if (context.mounted) context.go(Routes.welcome);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item(this.label, this.icon, this.onTap);
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListTile(
      leading: Icon(icon, color: c.textSecondary),
      title: Text(
        label,
        style: context.text.bodyMedium.copyWith(color: c.textPrimary),
      ),
      trailing: Icon(Icons.chevron_left_rounded, color: c.textMuted),
      onTap: onTap,
    );
  }
}
