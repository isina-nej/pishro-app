import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_badge.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/account_repository.dart';

/// Screen/Account/Devices — mock · IP ماسک.
class AccountDevicesScreen extends ConsumerWidget {
  const AccountDevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final devices = ref.watch(devicesProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'دستگاه‌ها و نشست‌ها',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: devices.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            ErrorStateView(onRetry: () => ref.invalidate(devicesProvider)),
        data: (items) => ListView(
          padding: const EdgeInsets.all(Space.page),
          children: [
            for (final d in items) ...[
              PishroCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            d.name,
                            style: context.text.bodyMedium.copyWith(
                              color: c.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (d.current)
                          const PishroBadge(
                            label: 'این دستگاه',
                            tone: PishroBadgeTone.info,
                            icon: Icons.phone_android_rounded,
                          )
                        else
                          const PishroBadge(
                            label: 'فعال',
                            tone: PishroBadgeTone.success,
                            icon: Icons.check_rounded,
                          ),
                      ],
                    ),
                    const SizedBox(height: Space.s2),
                    if (d.maskedIp.isNotEmpty)
                      Text(
                        'IP: ${d.maskedIp}',
                        style: context.text.caption.copyWith(
                          color: c.textMuted,
                        ),
                      ),
                    Text(
                      'آخرین فعالیت: ${Fmt.relative(d.lastSeen)}',
                      style: context.text.caption.copyWith(color: c.textMuted),
                    ),
                    Text(
                      'موقعیت تقریبی بر اساس اطلاعات شبکه',
                      style: context.text.caption.copyWith(color: c.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Space.s3),
            ],
            const NoticeBanner(
              message: 'آدرس IP همیشه به‌صورت ماسک‌شده نمایش داده می‌شود.',
              tone: NoticeTone.info,
            ),
            const SizedBox(height: Space.s4),
            PishroButton(
              label: 'خروج از همه نشست‌های دیگر',
              variant: PishroButtonVariant.danger,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
