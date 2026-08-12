import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/common.dart';
import '../../data/market_models.dart';

/// One market list row: rank, icon, Latin ticker + Persian name, toman + delta.
class AssetRow extends StatelessWidget {
  const AssetRow({
    super.key,
    required this.asset,
    this.onTap,
    this.window = ChangeWindow.h24,
    this.trailing,
  });

  final MarketAsset asset;
  final VoidCallback? onTap;
  final ChangeWindow window;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final irt = asset.priceIrt;
    return PishroCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: Space.s3,
        vertical: Space.s3,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              asset.rank > 0 ? '${asset.rank}' : '—',
              textAlign: TextAlign.center,
              style: context.text.caption.copyWith(color: c.textMuted),
            ),
          ),
          const SizedBox(width: Space.s2),
          _Icon(url: asset.imageUrl, symbol: asset.symbol),
          const SizedBox(width: Space.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.symbol,
                  style: context.text.bodyMedium.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  asset.persianName ?? asset.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.caption.copyWith(color: c.textMuted),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                irt == null ? 'داده در دسترس نیست' : '${faToman(irt)} تومان',
                style: context.text.bodySmall.copyWith(
                  color: c.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              MarketDelta(asset.changeFor(window), compact: true),
            ],
          ),
          if (trailing != null) ...[const SizedBox(width: Space.s2), trailing!],
        ],
      ),
    );
  }
}

class _Icon extends StatelessWidget {
  const _Icon({required this.url, required this.symbol});

  final String? url;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final child = url == null || url!.isEmpty
        ? Center(
            child: Text(
              symbol.isEmpty ? '?' : symbol[0],
              style: context.text.caption.copyWith(color: c.textSecondary),
            ),
          )
        : CachedNetworkImage(imageUrl: url!, fit: BoxFit.cover);
    return ClipOval(
      child: Container(
        width: 36,
        height: 36,
        color: c.surfaceSecondary,
        child: child,
      ),
    );
  }
}
