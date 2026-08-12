import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/pishro_badge.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/account_repository.dart';

/// Screen/Account/Profile.
class AccountProfileScreen extends ConsumerWidget {
  const AccountProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final profile = ref.watch(accountProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'پروفایل',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: profile.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(Space.page),
          child: Skeleton.box(height: 120),
        ),
        error: (e, _) => ErrorStateView(
          onRetry: () => ref.invalidate(accountProfileProvider),
        ),
        data: (p) => ListView(
          padding: const EdgeInsets.all(Space.page),
          children: [
            Text(
              p.displayName,
              style: context.text.h2.copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: Space.s2),
            Text(
              Fmt.maskPhone(p.phone),
              style: context.text.bodySmall.copyWith(color: c.textMuted),
            ),
            if (p.email != null) ...[
              const SizedBox(height: Space.s1),
              Text(
                p.email!,
                style: context.text.caption.copyWith(color: c.textMuted),
              ),
            ],
            const SizedBox(height: Space.s3),
            PishroBadge(
              label: p.phoneVerified ? 'تأییدشده' : 'تأیید نشده',
              tone: p.phoneVerified
                  ? PishroBadgeTone.success
                  : PishroBadgeTone.warning,
              icon: p.phoneVerified
                  ? Icons.check_rounded
                  : Icons.hourglass_top_rounded,
            ),
            const SizedBox(height: Space.s6),
            Text(
              'هویتی',
              style: context.text.bodySmall.copyWith(
                color: c.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: Space.s2),
            _Field(label: 'نام حقوقی', value: p.displayName),
            const _Field(label: 'کد ملی', value: 'ثبت‌نشده'),
            const SizedBox(height: Space.s2),
            Text(
              'برای تغییر این اطلاعات، درخواست بررسی هویت ثبت کنید.',
              style: context.text.caption.copyWith(color: c.textMuted),
            ),
            const SizedBox(height: Space.s5),
            Text(
              'تماس',
              style: context.text.bodySmall.copyWith(
                color: c.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: Space.s2),
            _Field(label: 'موبایل', value: Fmt.maskPhone(p.phone)),
            _Field(label: 'ایمیل', value: p.email ?? 'ثبت‌نشده'),
            const SizedBox(height: Space.s4),
            Text(
              // Join date is not on /user/me, so only the status is stated.
              'وضعیت حساب: فعال',
              style: context.text.caption.copyWith(color: c.textMuted),
            ),
            const SizedBox(height: Space.s6),
            PishroButton(
              label: 'ویرایش پروفایل',
              onPressed: () => context.push(Routes.editProfile),
            ),
          ],
        ),
      ),
    );
  }
}

/// One «برچسب … مقدار» row of the deck's account-information list.
class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.s2),
      child: Row(
        children: [
          Text(label, style: context.text.caption.copyWith(color: c.textMuted)),
          const Spacer(),
          Text(
            value,
            style: context.text.bodySmall.copyWith(color: c.textPrimary),
          ),
        ],
      ),
    );
  }
}
