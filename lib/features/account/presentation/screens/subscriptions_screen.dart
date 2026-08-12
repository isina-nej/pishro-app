import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_badge.dart';
import '../../../../shared/widgets/states.dart';

import '../../../community/data/community_repository.dart';

class AccountSubscriptionsScreen extends ConsumerWidget {
  const AccountSubscriptionsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final subs = ref.watch(communitySubscriptionsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'اشتراک‌ها',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: subs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ErrorStateView(
          onRetry: () => ref.invalidate(communitySubscriptionsProvider),
        ),
        data: (items) => items.isEmpty
            ? const EmptyState(title: 'اشتراکی فعال نیست')
            : ListView.separated(
                padding: const EdgeInsets.all(Space.page),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: Space.s3),
                itemBuilder: (_, i) {
                  final s = items[i];
                  return PishroCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            s.providerName,
                            style: context.text.bodyMedium.copyWith(
                              color: c.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        PishroBadge(
                          label: s.status.label,
                          tone: PishroBadgeTone.neutral,
                          icon: Icons.circle_outlined,
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
