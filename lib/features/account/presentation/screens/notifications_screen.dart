import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_chip.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/account_repository.dart';

/// Screen/Account/Notifications — mock.
class AccountNotificationsScreen extends ConsumerStatefulWidget {
  const AccountNotificationsScreen({super.key});

  @override
  ConsumerState<AccountNotificationsScreen> createState() =>
      _AccountNotificationsScreenState();
}

class _AccountNotificationsScreenState
    extends ConsumerState<AccountNotificationsScreen> {
  var _tab = 0;

  /// Local only — there is no read-state endpoint, so «علامت‌گذاری همه» dims
  /// the unread dots for this session rather than claiming a server write.
  var _allRead = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final notes = ref.watch(notificationsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'اعلان‌ها',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() => _allRead = true),
            child: const Text('علامت‌گذاری همه'),
          ),
        ],
      ),
      body: Column(
        children: [
          PishroChipBar(
            labels: const ['همه', 'امنیت', 'پرداخت', 'سرمایه‌گذاری'],
            selectedIndex: _tab,
            onSelected: (i) => setState(() => _tab = i),
          ),
          Expanded(
            child: notes.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => ErrorStateView(
                onRetry: () => ref.invalidate(notificationsProvider),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const EmptyState(title: 'اعلانی نیست');
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(Space.page),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: Space.s3),
                  itemBuilder: (_, i) {
                    final n = items[i];
                    return PishroCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (!n.read && !_allRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsetsDirectional.only(
                                    end: Space.s2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: c.actionPrimary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              Expanded(
                                child: Text(
                                  n.title,
                                  style: context.text.bodyMedium.copyWith(
                                    color: c.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: Space.s2),
                          Text(
                            n.body,
                            style: context.text.bodySmall.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                          const SizedBox(height: Space.s1),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
