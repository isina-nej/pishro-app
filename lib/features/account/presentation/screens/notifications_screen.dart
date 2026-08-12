import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/states.dart';

import '../../../../core/utils/formatters.dart';
import '../../data/account_repository.dart';

class AccountNotificationsScreen extends ConsumerWidget {
  const AccountNotificationsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final notes = ref.watch(notificationsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'اعلان‌ها',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: notes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ErrorStateView(
          onRetry: () => ref.invalidate(notificationsProvider),
        ),
        data: (items) => items.isEmpty
            ? const EmptyState(title: 'اعلانی نیست')
            : ListView.separated(
                padding: const EdgeInsets.all(Space.page),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: Space.s3),
                itemBuilder: (_, i) {
                  final n = items[i];
                  return PishroCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          n.title,
                          style: context.text.bodyMedium.copyWith(
                            color: c.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          n.body,
                          style: context.text.bodySmall.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                        Text(
                          Fmt.relative(n.at),
                          style: context.text.caption.copyWith(
                            color: c.textMuted,
                          ),
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
