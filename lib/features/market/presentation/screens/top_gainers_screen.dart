import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/pishro_chip.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/market_models.dart';
import '../../data/market_repository.dart';
import '../widgets/asset_row.dart';
import '../widgets/market_async.dart';

/// Screen/Market/TopGainers.
class TopGainersScreen extends ConsumerStatefulWidget {
  const TopGainersScreen({super.key});

  @override
  ConsumerState<TopGainersScreen> createState() => _TopGainersScreenState();
}

class _TopGainersScreenState extends ConsumerState<TopGainersScreen> {
  var _window = ChangeWindow.h24;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final snap = ref.watch(marketSnapshotProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'بیشترین رشد',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: Column(
        children: [
          PishroChipBar(
            labels: [for (final w in ChangeWindow.values) w.label],
            selectedIndex: ChangeWindow.values.indexOf(_window),
            onSelected: (i) => setState(() => _window = ChangeWindow.values[i]),
          ),
          Expanded(
            child: MarketAsync(
              value: snap,
              onRetry: () => ref.invalidate(marketSnapshotProvider),
              builder: (context, data) {
                final items = data.ranked(_window);
                if (items.isEmpty) {
                  return const EmptyState(title: 'رشدی در این بازه ثبت نشده');
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(Space.page),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: Space.s3),
                  itemBuilder: (_, i) {
                    final a = items[i];
                    return AssetRow(
                      asset: a,
                      window: _window,
                      onTap: () => context.push(Routes.coinDetails(a.id)),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
