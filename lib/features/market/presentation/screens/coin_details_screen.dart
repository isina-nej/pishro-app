import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_badge.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/favorites_repository.dart';
import '../../data/market_models.dart';
import '../../data/market_repository.dart';
import '../widgets/market_async.dart';

/// Screen/Market/CoinDetails — بدون خرید/فروش.
class CoinDetailsScreen extends ConsumerWidget {
  const CoinDetailsScreen({super.key, this.id = ''});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final detail = ref.watch(assetDetailProvider(id));
    final fav = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'جزئیات ارز',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
        actions: [
          IconButton(
            tooltip: fav.value?.contains(id) == true
                ? 'حذف از علاقه‌مندی‌ها'
                : 'افزودن به علاقه‌مندی‌ها',
            onPressed: () => ref.read(favoritesProvider.notifier).toggle(id),
            icon: Icon(
              fav.value?.contains(id) == true
                  ? Icons.star_rounded
                  : Icons.star_border_rounded,
              color: fav.value?.contains(id) == true ? c.warning : c.textMuted,
            ),
          ),
        ],
      ),
      body: MarketAsync(
        value: detail,
        onRetry: () => ref.invalidate(assetDetailProvider(id)),
        builder: (context, data) {
          final a = data.asset;
          return ListView(
            padding: const EdgeInsets.all(Space.page),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.symbol,
                          style: context.text.h2.copyWith(color: c.textPrimary),
                        ),
                        Text(
                          a.persianName ?? a.name,
                          style: context.text.bodySmall.copyWith(
                            color: c.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PishroBadge(
                    label: data.providers.hasLive ? 'زنده' : 'جایگزین',
                    tone: data.providers.hasLive
                        ? PishroBadgeTone.success
                        : PishroBadgeTone.warning,
                    icon: data.providers.hasLive
                        ? Icons.sensors_rounded
                        : Icons.cloud_off_outlined,
                  ),
                ],
              ),
              const SizedBox(height: Space.s4),
              Text(
                a.priceIrt == null
                    ? 'داده در دسترس نیست'
                    : '${faToman(a.priceIrt!)} تومان',
                style: context.text.h2.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: Space.s2),
              MarketDelta(a.change24h),
              const SizedBox(height: Space.s5),
              _Link('نمودار قیمت', () => context.push(Routes.priceChart(id))),
              _Link('آمار', () => context.push(Routes.statistics(id))),
              _Link('تاریخچه', () => context.push(Routes.historicalData(id))),
              _Link(
                'جامعه این دارایی',
                () => context.push('${Routes.community}/asset/$id'),
              ),
              const SizedBox(height: Space.s4),
              const NoticeBanner(
                message:
                    'این صفحه فقط نمایش قیمت است و امکان خرید یا فروش ندارد.',
                tone: NoticeTone.info,
              ),
              const SizedBox(height: Space.s3),
              Text(
                'منبع قیمت: ${a.priceSource} · بازار: ${a.marketSource}',
                style: context.text.caption.copyWith(color: c.textMuted),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Link extends StatelessWidget {
  const _Link(this.label, this.onTap);
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: context.text.bodyMedium.copyWith(color: c.textPrimary),
      ),
      trailing: Icon(Icons.chevron_left_rounded, color: c.textMuted),
      onTap: onTap,
    );
  }
}
