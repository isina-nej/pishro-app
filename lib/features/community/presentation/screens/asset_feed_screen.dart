import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/community_repository.dart';
import '../widgets/analysis_card.dart';

/// Screen/Community/AssetFeed — reuse AnalysisCard.
class AssetFeedScreen extends ConsumerWidget {
  const AssetFeedScreen({super.key, this.id = ''});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final symbol = id.toUpperCase();
    final feed = ref.watch(assetFeedProvider(symbol));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تحلیل‌های $symbol',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: feed.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(Space.page),
          children: const [
            Skeleton.box(height: 120),
            SizedBox(height: Space.s3),
            Skeleton.box(height: 120),
          ],
        ),
        error: (_, __) => ErrorStateView(
          onRetry: () => ref.invalidate(assetFeedProvider(symbol)),
        ),
        data: (items) => items.isEmpty
            ? const EmptyState(title: 'تحلیلی برای این دارایی نیست')
            : ListView.separated(
                padding: const EdgeInsets.all(Space.page),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: Space.s3),
                itemBuilder: (_, i) => AnalysisCard(items[i]),
              ),
      ),
    );
  }
}
