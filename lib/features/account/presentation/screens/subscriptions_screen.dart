import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_badge.dart';
import '../../../../shared/widgets/pishro_chip.dart';
import '../../../../shared/widgets/states.dart';
import '../../../community/data/community_models.dart';
import '../../../community/data/community_repository.dart';

/// Screen/Account/Subscriptions.
class AccountSubscriptionsScreen extends ConsumerStatefulWidget {
  const AccountSubscriptionsScreen({super.key});

  @override
  ConsumerState<AccountSubscriptionsScreen> createState() =>
      _AccountSubscriptionsScreenState();
}

class _AccountSubscriptionsScreenState
    extends ConsumerState<AccountSubscriptionsScreen> {
  SubscriptionStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final subs = ref.watch(communitySubscriptionsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'اشتراک‌ها',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: Column(
        children: [
          PishroChipBar(
            labels: [
              'همه',
              ...[for (final s in SubscriptionStatus.values) s.label],
            ],
            selectedIndex: _filter == null ? 0 : _filter!.index + 1,
            onSelected: (i) => setState(() {
              _filter = i == 0 ? null : SubscriptionStatus.values[i - 1];
            }),
          ),
          Expanded(
            child: subs.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(Space.page),
                child: Skeleton.box(height: 96),
              ),
              error: (_, __) => ErrorStateView(
                onRetry: () => ref.invalidate(communitySubscriptionsProvider),
              ),
              data: (items) {
                final filtered = [
                  for (final s in items)
                    if (_filter == null || s.status == _filter) s,
                ];
                if (filtered.isEmpty) {
                  return const EmptyState(title: 'اشتراکی در این وضعیت نیست');
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(Space.page),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: Space.s3),
                  itemBuilder: (_, i) {
                    final s = filtered[i];
                    return PishroCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  s.providerName,
                                  style: context.text.bodyMedium.copyWith(
                                    color: c.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              PishroBadge(
                                label: s.status.label,
                                tone: switch (s.status) {
                                  SubscriptionStatus.active =>
                                    PishroBadgeTone.success,
                                  SubscriptionStatus.pending =>
                                    PishroBadgeTone.warning,
                                  SubscriptionStatus.ended =>
                                    PishroBadgeTone.neutral,
                                  SubscriptionStatus.cancelled =>
                                    PishroBadgeTone.danger,
                                },
                                icon: switch (s.status) {
                                  SubscriptionStatus.active =>
                                    Icons.check_rounded,
                                  SubscriptionStatus.pending =>
                                    Icons.hourglass_top_rounded,
                                  SubscriptionStatus.ended =>
                                    Icons.flag_outlined,
                                  SubscriptionStatus.cancelled =>
                                    Icons.cancel_outlined,
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: Space.s2),
                          Text(
                            '${Fmt.toman(s.priceToman)} · ${s.period}${s.renewsAt == null ? '' : ' · تمدید: ${Fmt.jalaliLong(s.renewsAt!)}'}',
                            style: context.text.caption.copyWith(
                              color: c.textMuted,
                            ),
                          ),
                          const SizedBox(height: Space.s2),
                          // Payment settled and access granted are two facts;
                          // a paid-but-unactivated row must say so plainly.
                          Text(
                            s.status == SubscriptionStatus.pending
                                ? 'پرداخت: پرداخت‌شده · دسترسی: در انتظار'
                                : 'پرداخت: پرداخت‌شده · دسترسی: ${s.status.label}',
                            style: context.text.caption.copyWith(
                              color: c.textMuted,
                            ),
                          ),
                          if (s.status == SubscriptionStatus.pending) ...[
                            const SizedBox(height: Space.s2),
                            Text(
                              'پرداخت ثبت شد؛ فعال‌سازی محتوا هنوز تأیید نشده '
                              'است.',
                              style: context.text.caption.copyWith(
                                color: c.warning,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
