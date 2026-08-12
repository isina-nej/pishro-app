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
