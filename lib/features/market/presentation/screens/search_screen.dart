import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/pishro_text_field.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/market_models.dart';
import '../../data/market_repository.dart';
import '../../data/price_alerts_repository.dart';
import '../widgets/asset_row.dart';
import '../widgets/market_async.dart';

/// Screen/Market/Search — بیت‌کوین و BTC هر دو.
class MarketSearchScreen extends ConsumerStatefulWidget {
  const MarketSearchScreen({super.key});

  @override
  ConsumerState<MarketSearchScreen> createState() => _MarketSearchScreenState();
}

class _MarketSearchScreenState extends ConsumerState<MarketSearchScreen> {
  final _controller = TextEditingController();
  var _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final snap = ref.watch(marketSnapshotProvider);
    final recents = ref.watch(recentSearchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'جستجوی بازار',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(Space.page),
            child: PishroTextField(
              controller: _controller,
              label: 'نام یا نماد',
              hint: 'BTC یا بیت‌کوین',
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
          ),
          if (_query.isEmpty && recents.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.page),
              child: Wrap(
                spacing: Space.s2,
                children: [
                  for (final t in recents)
                    ActionChip(
                      label: Text(t),
                      onPressed: () {
                        _controller.text = t;
                        setState(() => _query = t);
                      },
                    ),
                ],
              ),
            ),
          Expanded(
            child: MarketAsync(
              value: snap,
              onRetry: () => ref.invalidate(marketSnapshotProvider),
              builder: (context, data) {
                final items = _query.isEmpty
                    ? const <MarketAsset>[]
                    : [
                        for (final a in data.assets)
                          if (a.matches(_query)) a,
                      ];
                if (_query.isEmpty) {
                  return const EmptyState(
                    title: 'نام ارز یا نماد آن را جستجو کنید',
                    icon: Icons.search_rounded,
                  );
                }
                if (items.isEmpty) {
                  return EmptyState(
                    title: 'ارزی برای «$_query» پیدا نشد',
                    icon: Icons.search_off_rounded,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(Space.page),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: Space.s3),
                  itemBuilder: (_, i) {
                    final a = items[i];
                    return AssetRow(
                      asset: a,
                      onTap: () {
                        final q = Fmt.toAscii(_query);
                        ref.read(recentSearchesProvider.notifier).state = [
                          q,
                          ...recents.where((e) => e != q),
                        ].take(8).toList();
                        context.push(Routes.coinDetails(a.id));
                      },
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
