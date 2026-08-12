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
import '../../data/market_models.dart';
import '../../data/market_repository.dart';
import '../widgets/asset_row.dart';
import '../widgets/market_async.dart';

/// Screen/Market/Home — اسنپ‌شات + میانبرها + فهرست کوتاه.
class MarketHomeScreen extends ConsumerWidget {
  const MarketHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final snap = ref.watch(marketSnapshotProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'بازار',
          style: context.text.h2.copyWith(color: c.textPrimary),
        ),
        actions: [
          IconButton(
            tooltip: 'جستجو',
            onPressed: () => context.push(Routes.marketSearch),
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            tooltip: 'هشدار قیمت',
            onPressed: () => context.push(Routes.priceAlerts),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: MarketAsync(
        value: snap,
        onRetry: () => ref.invalidate(marketSnapshotProvider),
        builder: (context, data) {
          final top = data.assets.take(8).toList();
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(marketSnapshotProvider),
            child: ListView(
              padding: const EdgeInsets.only(bottom: Space.s8),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Space.page,
                    Space.s3,
                    Space.page,
                    Space.s3,
                  ),
                  child: PishroCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'وضعیت داده',
                              style: context.text.bodySmall.copyWith(
                                color: c.textMuted,
                              ),
                            ),
                            const Spacer(),
                            PishroBadge(
                              label: data.providers.hasLive
                                  ? 'زنده'
                                  : 'جایگزین',
                              tone: data.providers.hasLive
                                  ? PishroBadgeTone.success
                                  : PishroBadgeTone.warning,
                              icon: data.providers.hasLive
                                  ? Icons.sensors_rounded
                                  : Icons.cloud_off_outlined,
                            ),
                          ],
                        ),
                        const SizedBox(height: Space.s3),
                        Text(
                          'ارزش بازار: ${faMillions(data.global.marketCap)} دلار',
                          style: context.text.bodySmall.copyWith(
                            color: c.textPrimary,
                          ),
                        ),
                        const SizedBox(height: Space.s1),
                        MarketDelta(data.global.marketCapChange24h),
                        const SizedBox(height: Space.s1),
                        Text(
                          'منبع: ${data.global.source} · ${Fmt.relative(data.generatedAt)}',
                          style: context.text.caption.copyWith(
                            color: c.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: Layout.minTapTarget,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: Space.page),
                    children: [
                      _Chip('همه ارزها', () => context.push(Routes.allAssets)),
                      _Chip(
                        'علاقه‌مندی‌ها',
                        () => context.push(Routes.favorites),
                      ),
                      _Chip(
                        'پرطرفدار',
                        () => context.push(Routes.marketTrending),
                      ),
                      _Chip(
                        'بیشترین رشد',
                        () => context.push(Routes.topGainers),
                      ),
                      _Chip(
                        'بیشترین افت',
                        () => context.push(Routes.topLosers),
                      ),
                      _Chip('جامعه', () => context.push(Routes.community)),
                    ],
                  ),
                ),
                SectionHeader(
                  title: 'ارزها',
                  onSeeAll: () => context.push(Routes.allAssets),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Space.page),
                  child: Column(
                    children: [
                      for (final a in top) ...[
                        AssetRow(
                          asset: a,
                          onTap: () => context.push(Routes.coinDetails(a.id)),
                        ),
                        const SizedBox(height: Space.s3),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label, this.onTap);
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: Space.s2),
      child: ActionChip(
        label: Text(label),
        onPressed: onTap,
        backgroundColor: c.surfaceSecondary,
      ),
    );
  }
}
