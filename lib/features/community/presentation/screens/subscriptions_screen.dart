import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_badge.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/pishro_chip.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/community_models.dart';
import '../../data/community_repository.dart';

/// Screen/Community/Subscriptions — «۱۰ · اشتراک‌های من».
///
/// Status filter bar, then price · period · renewal per row. «در انتظار» is
/// its own state and never dressed up as active.
class CommunitySubscriptionsScreen extends ConsumerStatefulWidget {
  const CommunitySubscriptionsScreen({super.key});

  @override
  ConsumerState<CommunitySubscriptionsScreen> createState() =>
      _CommunitySubscriptionsScreenState();
}

class _CommunitySubscriptionsScreenState
    extends ConsumerState<CommunitySubscriptionsScreen> {
  SubscriptionStatus _status = SubscriptionStatus.active;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final subs = ref.watch(communitySubscriptionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'اشتراک‌های من',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: Column(
        children: [
          PishroChipBar(
            labels: [for (final s in SubscriptionStatus.values) s.label],
            selectedIndex: _status.index,
            onSelected: (i) =>
                setState(() => _status = SubscriptionStatus.values[i]),
          ),
          Expanded(
            child: subs.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => ErrorStateView(
                onRetry: () => ref.invalidate(communitySubscriptionsProvider),
              ),
              data: (all) {
                final items = [
                  for (final s in all)
                    if (s.status == _status) s,
                ];
                if (items.isEmpty) {
                  return EmptyState(
                    title: 'اشتراکی با وضعیت «${_status.label}» نیست',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(Space.page),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: Space.s3),
                  itemBuilder: (_, i) => _SubscriptionCard(items[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard(this.s);

  final Subscription s;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final renewal = s.renewsAt;

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
                  SubscriptionStatus.active => PishroBadgeTone.success,
                  SubscriptionStatus.pending => PishroBadgeTone.warning,
                  SubscriptionStatus.ended ||
                  SubscriptionStatus.cancelled => PishroBadgeTone.neutral,
                },
                icon: switch (s.status) {
                  SubscriptionStatus.active => Icons.check_rounded,
                  SubscriptionStatus.pending => Icons.schedule_rounded,
                  SubscriptionStatus.ended => Icons.history_rounded,
                  SubscriptionStatus.cancelled => Icons.block_rounded,
                },
              ),
            ],
          ),
          const SizedBox(height: Space.s2),
          Text(
            [
              Fmt.toman(s.priceToman),
              s.period,
              if (renewal != null) 'تمدید: ${Fmt.jalaliLong(renewal)}',
            ].join(' · '),
            style: context.text.caption.copyWith(color: c.textMuted),
          ),
          if (!s.autoRenew) ...[
            const SizedBox(height: Space.s1),
            Text(
              'تمدید خودکار غیرفعال است.',
              style: context.text.caption.copyWith(color: c.textMuted),
            ),
          ],
          const SizedBox(height: Space.s3),
          Row(
            children: [
              Expanded(
                child: PishroButton(
                  label: 'مدیریت',
                  variant: PishroButtonVariant.ghost,
                  onPressed: () => context.push(Routes.premiumSignals),
                ),
              ),
              const SizedBox(width: Space.s3),
              Expanded(
                child: PishroButton(
                  label: 'مشاهده محتوا',
                  variant: PishroButtonVariant.secondary,
                  // Content stays gated until the subscription is actually
                  // active — pending payment is not access.
                  onPressed: s.status == SubscriptionStatus.active
                      ? () => context.push(Routes.premiumSignals)
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
