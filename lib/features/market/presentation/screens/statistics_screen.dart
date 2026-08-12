import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/common.dart';
import '../../data/market_models.dart';
import '../../data/market_repository.dart';
import '../widgets/data_source_note.dart';
import '../widgets/market_async.dart';

/// Screen/Market/Statistics — مقدار ناموجود هرگز صفر نمی‌شود.
class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key, this.id = ''});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final detail = ref.watch(assetDetailProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'آمار',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: MarketAsync(
        value: detail,
        onRetry: () => ref.invalidate(assetDetailProvider(id)),
        builder: (context, data) {
          final a = data.asset;
          String orMissing(double? v, [String Function(double)? fmt]) =>
              v == null ? 'داده در دسترس نیست' : (fmt ?? faToman)(v);

          return ListView(
            padding: const EdgeInsets.all(Space.page),
            children: [
              Text(
                'آمار بازار — ${a.persianName ?? a.name}',
                style: context.text.h3.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: Space.s2),
              Text(
                'مقدار ناموجود هرگز صفر نمایش داده نمی‌شود.',
                style: context.text.caption.copyWith(color: c.textMuted),
              ),
              const SizedBox(height: Space.s4),
              _Stat(
                'قیمت تومان',
                orMissing(a.priceIrt, (v) => '${faToman(v)} تومان'),
              ),
              _Stat('قیمت دلار', '${Fmt.fa(a.priceUsd.toStringAsFixed(2))} \$'),
              _Stat('تغییر ۲۴ساعت', Fmt.percentDelta(a.change24h)),
              _Stat('تغییر ۷روز', Fmt.percentDelta(a.change7d)),
              _Stat('تغییر ۳۰روز', Fmt.percentDelta(a.change30d)),
              _Stat('حجم ۲۴ ساعت', orMissing(a.volume24h, faMillions)),
              _Stat('ارزش بازار', orMissing(a.marketCap, faMillions)),
              _Stat('بیشترین قیمت روز', orMissing(a.high24h, faToman)),
              _Stat('کمترین قیمت روز', orMissing(a.low24h, faToman)),
              _Stat(
                'بالاترین قیمت تاریخی',
                orMissing(
                  a.athUsd,
                  (v) => '${Fmt.fa(v.toStringAsFixed(2))} \$',
                ),
              ),
              _Stat(
                'تاریخ ATH',
                a.athDate == null
                    ? 'داده در دسترس نیست'
                    : Fmt.jalaliLong(a.athDate!),
              ),
              _Stat('عرضه در گردش', orMissing(a.circulatingSupply, faMillions)),
              _Stat('حداکثر عرضه', orMissing(a.maxSupply, faMillions)),
              _Stat(
                'رتبه بازار',
                a.rank <= 0 ? 'داده در دسترس نیست' : Fmt.fa('${a.rank}'),
              ),
              DataSourceNote(
                source: a.marketSource,
                generatedAt: data.generatedAt,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.s3),
      child: PishroCard(
        child: Row(
          children: [
            Text(
              label,
              style: context.text.bodySmall.copyWith(color: c.textMuted),
            ),
            const Spacer(),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: context.text.bodySmall.copyWith(
                  color: c.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
