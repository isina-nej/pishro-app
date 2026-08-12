import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/market_repository.dart';
import '../widgets/asset_row.dart';
import '../widgets/data_source_note.dart';
import '../widgets/market_async.dart';

/// Screen/Market/Trending — بیشترین حجم ۲۴ساعته.
class MarketTrendingScreen extends ConsumerWidget {
  const MarketTrendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final snap = ref.watch(marketSnapshotProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ارزهای پرطرفدار',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: MarketAsync(
        value: snap,
        onRetry: () => ref.invalidate(marketSnapshotProvider),
        builder: (context, data) {
          final items = [...data.assets]
            ..sort((a, b) => b.volume24h.compareTo(a.volume24h));
          if (items.isEmpty) {
            return const EmptyState(title: 'داده‌ای برای نمایش نیست');
          }
          final top = items.take(20).toList();
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(Space.page),
                  itemCount: top.length,
                  separatorBuilder: (_, __) => const SizedBox(height: Space.s3),
                  itemBuilder: (_, i) => AssetRow(
                    asset: top[i],
                    onTap: () => context.push(Routes.coinDetails(top[i].id)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Space.page),
                child: DataSourceNote(
                  generatedAt: data.generatedAt,
                  extra: 'معیار پرطرفداربودن از سرویس داده دریافت می‌شود.',
                ),
              ),
              const SizedBox(height: Space.s4),
            ],
          );
        },
      ),
    );
  }
}
