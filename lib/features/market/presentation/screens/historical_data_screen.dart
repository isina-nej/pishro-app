import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/market_models.dart';
import '../../data/market_repository.dart';
import '../widgets/data_source_note.dart';
import '../widgets/market_async.dart';

/// Screen/Market/HistoricalData — OHLC روزانه از اسپارک‌لاین ساعتی.
class HistoricalDataScreen extends ConsumerWidget {
  const HistoricalDataScreen({super.key, this.id = ''});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final detail = ref.watch(assetDetailProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'داده‌های تاریخی',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: MarketAsync(
        value: detail,
        onRetry: () => ref.invalidate(assetDetailProvider(id)),
        builder: (context, data) {
          final candles = dailyCandles(data.asset.sparkline, data.generatedAt);
          if (candles.isEmpty) {
            return const EmptyState(title: 'تاریخچه‌ای برای نمایش نیست');
          }
          return ListView(
            padding: const EdgeInsets.all(Space.page),
            children: [
              Text(
                '${Fmt.jalaliLong(candles.last.day)} تا ${Fmt.jalaliLong(candles.first.day)}',
                style: context.text.bodySmall.copyWith(
                  color: c.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: Space.s3),
              const NoticeBanner(
                message:
                    'کندل روزانه از اسپارک‌لاین ۷روزه ساخته شده؛ داده نمونه کامل نیست و سیگنال معامله محسوب نمی‌شود.',
                tone: NoticeTone.info,
              ),
              const SizedBox(height: Space.s4),
              for (final candle in candles) ...[
                PishroCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Fmt.jalaliLong(candle.day),
                        style: context.text.bodySmall.copyWith(
                          color: c.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: Space.s2),
                      Text(
                        'باز ${faToman(candle.open)} · بالا ${faToman(candle.high)} · پایین ${faToman(candle.low)} · بسته ${faToman(candle.close)}',
                        style: context.text.caption.copyWith(
                          color: c.textMuted,
                        ),
                      ),
                      const SizedBox(height: Space.s2),
                      MarketDelta(candle.changePercent, compact: true),
                    ],
                  ),
                ),
                const SizedBox(height: Space.s3),
              ],
              DataSourceNote(
                source: data.asset.priceSource,
                generatedAt: data.generatedAt,
                extra: 'منطقه زمانی: تهران',
              ),
            ],
          );
        },
      ),
    );
  }
}
