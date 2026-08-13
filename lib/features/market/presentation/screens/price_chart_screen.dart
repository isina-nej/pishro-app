import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_chip.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/market_models.dart';
import '../../data/market_repository.dart';
import '../widgets/data_source_note.dart';
import '../widgets/market_async.dart';

/// Screen/Market/PriceChart — اسپارک‌لاین ۷روزه، تنها تاریخچه موجود.
class PriceChartScreen extends ConsumerWidget {
  const PriceChartScreen({super.key, this.id = ''});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final detail = ref.watch(assetDetailProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'نمودار قیمت',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: MarketAsync(
        value: detail,
        onRetry: () => ref.invalidate(assetDetailProvider(id)),
        builder: (context, data) {
          final spark = data.asset.sparkline;
          if (spark.length < 2) {
            return const EmptyState(
              title: 'نموداری برای این ارز نیست',
              message: 'فقط اسپارک‌لاین ۷روزه از سرور می‌آید.',
            );
          }
          final min = spark.reduce((a, b) => a < b ? a : b);
          final max = spark.reduce((a, b) => a > b ? a : b);
          return ListView(
            padding: const EdgeInsets.all(Space.page),
            children: [
              Text(
                '${data.asset.persianName ?? data.asset.name} (${data.asset.symbol})',
                style: context.text.h3.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: Space.s3),
              Wrap(
                spacing: Space.s2,
                children: [
                  PishroChip(label: '۲۴س', selected: false, onTap: () {}),
                  const PishroChip(label: '۷روز', selected: true),
                  PishroChip(label: '۳۰روز', selected: false, onTap: () {}),
                ],
              ),
              const SizedBox(height: Space.s2),
              Text(
                'فقط بازه ۷روز از سرور می‌آید. بازه‌های دیگر به‌زودی.',
                style: context.text.caption.copyWith(color: c.textMuted),
              ),
              const SizedBox(height: Space.s4),
              SizedBox(
                height: 220,
                child: LineChart(
                  LineChartData(
                    minY: min,
                    maxY: max,
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          for (var i = 0; i < spark.length; i++)
                            FlSpot(i.toDouble(), spark[i]),
                        ],
                        isCurved: true,
                        color: c.actionPrimary,
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Space.s4),
              MarketDelta(data.asset.change7d),
              const SizedBox(height: Space.s4),
              // The deck's three period readings, taken from the same series
              // the chart draws — no second source, no invented figures.
              _PeriodStat(label: 'بیشترین', value: max),
              _PeriodStat(label: 'کمترین', value: min),
              _PeriodStat(label: 'شروع دوره', value: spark.first),
              const SizedBox(height: Space.s3),
              Text(
                'در بازه انتخاب‌شده، قیمت از مقدار آغازین به مقدار پایانی '
                'تغییر کرده است.',
                style: context.text.caption.copyWith(color: c.textMuted),
              ),
              const SizedBox(height: Space.s3),
              const NoticeBanner(
                message:
                    'این نمودار فقط ۷ روز گذشته را نشان می‌دهد و سیگنال معامله نیست.',
                tone: NoticeTone.info,
              ),
              DataSourceNote(
                source: data.asset.priceSource,
                generatedAt: data.generatedAt,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// One «بیشترین / کمترین / شروع دوره» reading under the chart.
class _PeriodStat extends StatelessWidget {
  const _PeriodStat({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.s2),
      child: Row(
        children: [
          Text(label, style: context.text.caption.copyWith(color: c.textMuted)),
          const Spacer(),
          Text(
            faToman(value),
            style: context.text.bodySmall.copyWith(
              color: c.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
