import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/pishro_chip.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/community_models.dart';
import '../../data/community_repository.dart';
import '../widgets/analysis_card.dart';

class CommunityHomeScreen extends ConsumerStatefulWidget {
  const CommunityHomeScreen({super.key});
  @override
  ConsumerState<CommunityHomeScreen> createState() =>
      _CommunityHomeScreenState();
}

class _CommunityHomeScreenState extends ConsumerState<CommunityHomeScreen> {
  var _filter = AnalysisFilter.all;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final feed = ref.watch(communityFeedProvider(_filter));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'جامعه تحلیلگران',
          style: context.text.h2.copyWith(color: c.textPrimary),
        ),
        actions: [
          IconButton(
            tooltip: 'جستجو',
            onPressed: () => context.push(Routes.communitySearch),
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            tooltip: 'تحلیل جدید',
            onPressed: () => context.push(Routes.createAnalysis),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          PishroChipBar(
            labels: [for (final f in AnalysisFilter.values) f.label],
            selectedIndex: _filter.index,
            onSelected: (i) =>
                setState(() => _filter = AnalysisFilter.values[i]),
          ),
          Expanded(
            child: feed.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(Space.page),
                child: Skeleton.box(height: 96),
              ),
              error: (_, __) => ErrorStateView(
                onRetry: () => ref.invalidate(communityFeedProvider(_filter)),
              ),
              data: (items) => items.isEmpty
                  ? const EmptyState(title: 'تحلیلی در این فیلتر نیست')
                  : ListView(
                      padding: const EdgeInsets.all(Space.page),
                      children: [
                        Wrap(
                          spacing: Space.s2,
                          children: [
                            ActionChip(
                              label: const Text('دنبال‌شده‌ها'),
                              onPressed: () =>
                                  context.push(Routes.followingFeed),
                            ),
                            ActionChip(
                              label: const Text('تحلیلگران'),
                              onPressed: () =>
                                  context.push(Routes.recommendedAnalysts),
                            ),
                            ActionChip(
                              label: const Text('رتبه‌بندی'),
                              onPressed: () => context.push(Routes.leaderboard),
                            ),
                            ActionChip(
                              label: const Text('سیگنال‌ها'),
                              onPressed: () =>
                                  context.push(Routes.premiumSignals),
                            ),
                          ],
                        ),
                        const SizedBox(height: Space.s4),
                        for (final a in items) ...[
                          AnalysisCard(a),
                          const SizedBox(height: Space.s3),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
