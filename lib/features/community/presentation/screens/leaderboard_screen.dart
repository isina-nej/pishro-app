import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/states.dart';

import '../../../../core/utils/formatters.dart';
import '../../data/community_repository.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final page = ref.watch(leaderboardProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'رتبه‌بندی',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: page.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            ErrorStateView(onRetry: () => ref.invalidate(leaderboardProvider)),
        data: (p) => ListView(
          padding: const EdgeInsets.all(Space.page),
          children: [
            NoticeBanner(message: p.notice, tone: NoticeTone.info),
            const SizedBox(height: Space.s4),
            for (final e in p.entries) ...[
              PishroCard(
                onTap: () => context.push(Routes.analystProfile(e.analystId)),
                child: Row(
                  children: [
                    Text(
                      Fmt.fa('${e.rank}'),
                      style: context.text.h3.copyWith(color: c.textPrimary),
                    ),
                    const SizedBox(width: Space.s3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.displayName,
                            style: context.text.bodyMedium.copyWith(
                              color: c.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${Fmt.fa('${e.analysisCount}')} تحلیل · امتیاز ${Fmt.fa(e.rating.toStringAsFixed(1))}',
                            style: context.text.caption.copyWith(
                              color: c.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Space.s3),
            ],
          ],
        ),
      ),
    );
  }
}
