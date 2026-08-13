import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/pishro_chip.dart';
import '../../../../shared/widgets/pishro_text_field.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/market_repository.dart';
import '../../data/price_alerts_repository.dart';
import '../widgets/market_async.dart';

/// Screen/Market/PriceAlerts — هشدار ≠ معامله خودکار.
class PriceAlertsScreen extends ConsumerStatefulWidget {
  const PriceAlertsScreen({super.key});

  @override
  ConsumerState<PriceAlertsScreen> createState() => _PriceAlertsScreenState();
}

class _PriceAlertsScreenState extends ConsumerState<PriceAlertsScreen> {
  var _condition = AlertCondition.above;
  final _value = TextEditingController();
  String? _assetId;

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final alerts = ref.watch(priceAlertsProvider);
    final snap = ref.watch(marketSnapshotProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'هشدارهای قیمت',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          const NoticeBanner(
            message: 'هشدار قیمت به معنای انجام خودکار معامله نیست.',
            tone: NoticeTone.warning,
          ),
          const SizedBox(height: Space.s5),
          Text(
            'هشدار جدید',
            style: context.text.h3.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: Space.s3),
          MarketAsync(
            value: snap,
            onRetry: () => ref.invalidate(marketSnapshotProvider),
            skeleton: const Skeleton.box(height: 48),
            builder: (context, data) {
              final assets = data.assets.take(30).toList();
              _assetId ??= assets.isEmpty ? null : assets.first.id;
              return DropdownButtonFormField<String>(
                initialValue: assets.any((a) => a.id == _assetId)
                    ? _assetId
                    : null,
                decoration: const InputDecoration(labelText: 'دارایی'),
                items: [
                  for (final a in assets)
                    DropdownMenuItem(
                      value: a.id,
                      child: Text('${a.symbol} · ${a.persianName ?? a.name}'),
                    ),
                ],
                onChanged: (v) => setState(() => _assetId = v),
              );
            },
          ),
          const SizedBox(height: Space.s3),
          Wrap(
            spacing: Space.s2,
            children: [
              for (final cond in AlertCondition.values)
                PishroChip(
                  label: cond.label,
                  selected: _condition == cond,
                  onTap: () => setState(() => _condition = cond),
                ),
            ],
          ),
          const SizedBox(height: Space.s3),
          PishroTextField(
            controller: _value,
            label: _condition == AlertCondition.percentChange
                ? 'درصد تغییر'
                : 'مقدار (تومان)',
            hint: '۰',
          ),
          const SizedBox(height: Space.s3),
          PishroButton(
            label: 'ثبت هشدار',
            onPressed: () async {
              final assetId = _assetId;
              final snapData = snap.valueOrNull;
              if (assetId == null || snapData == null) return;
              final asset = snapData.byId(assetId);
              if (asset == null) return;
              final n = double.tryParse(Fmt.toAscii(_value.text)) ?? 0;
              if (n <= 0) return;
              await ref
                  .read(priceAlertsProvider.notifier)
                  .add(
                    PriceAlert(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      assetId: asset.id,
                      assetName: asset.persianName ?? asset.name,
                      symbol: asset.symbol,
                      condition: _condition,
                      value: n,
                      enabled: true,
                      createdAt: DateTime.now(),
                    ),
                  );
              _value.clear();
            },
          ),
          const SizedBox(height: Space.s6),
          Text(
            'هشدارهای فعال',
            style: context.text.h3.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: Space.s3),
          alerts.when(
            loading: () => const Skeleton.box(height: 64),
            error: (_, __) => ErrorStateView(
              onRetry: () => ref.invalidate(priceAlertsProvider),
            ),
            data: (items) {
              if (items.isEmpty) {
                return PishroCard(
                  child: Text(
                    'هنوز هشداری ثبت نشده است. هشدار قیمت به معنای انجام خودکار معامله نیست.',
                    style: context.text.bodySmall.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  for (final a in items) ...[
                    PishroCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${a.symbol} · ${a.condition.label}',
                                  style: context.text.bodySmall.copyWith(
                                    color: c.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  a.condition == AlertCondition.percentChange
                                      ? '${Fmt.fa(a.value.toStringAsFixed(2))}٪'
                                      : Fmt.toman(a.value),
                                  style: context.text.caption.copyWith(
                                    color: c.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: a.enabled,
                            onChanged: (v) => ref
                                .read(priceAlertsProvider.notifier)
                                .setEnabled(a.id, v),
                          ),
                          IconButton(
                            tooltip: 'حذف',
                            onPressed: () => ref
                                .read(priceAlertsProvider.notifier)
                                .remove(a.id),
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              color: c.danger,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Space.s3),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
