import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/pishro_chip.dart';
import '../../../../shared/widgets/pishro_text_field.dart';
import '../../data/news_repository.dart';
import '../../news_routes.dart';

/// Screen/News/Search — کیبورد باز + جست‌وجوهای اخیر.
class NewsSearchScreen extends ConsumerStatefulWidget {
  const NewsSearchScreen({super.key});

  @override
  ConsumerState<NewsSearchScreen> createState() => _NewsSearchScreenState();
}

class _NewsSearchScreenState extends ConsumerState<NewsSearchScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(newsQueryProvider).search ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _go(String raw) async {
    final q = Fmt.toAscii(raw).trim();
    final current = ref.read(newsQueryProvider);
    ref.read(newsQueryProvider.notifier).state = (
      search: q.isEmpty ? null : q,
      category: current.category,
      sort: current.sort,
      range: current.range,
    );
    if (q.isNotEmpty) {
      await ref.read(recentSearchesProvider).remember(q);
      ref.invalidate(recentSearchListProvider);
    }
    if (mounted) context.push(newsSearchResultsPath());
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final recents = ref.watch(recentSearchListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'جستجوی اخبار',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
        actions: [
          IconButton(
            tooltip: 'فیلترها',
            onPressed: () => context.push(Routes.newsFilters),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          PishroTextField(
            controller: _controller,
            label: 'عبارت جستجو',
            hint: 'بیت‌کوین، نرخ بهره…',
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: (_) {},
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: () => _go(_controller.text),
              child: const Text('مشاهده نتایج'),
            ),
          ),
          const SizedBox(height: Space.s4),
          Row(
            children: [
              Text(
                'جستجوهای اخیر',
                style: context.text.bodySmall.copyWith(
                  color: c.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () async {
                  await ref.read(recentSearchesProvider).clear();
                  ref.invalidate(recentSearchListProvider);
                },
                child: const Text('پاک کردن'),
              ),
            ],
          ),
          recents.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (items) {
              if (items.isEmpty) {
                return Text(
                  'هنوز جستجویی ثبت نشده است.',
                  style: context.text.caption.copyWith(color: c.textMuted),
                );
              }
              return Wrap(
                spacing: Space.s2,
                runSpacing: Space.s2,
                children: [
                  for (final t in items)
                    PishroChip(
                      label: t,
                      selected: false,
                      onTap: () {
                        _controller.text = t;
                        _go(t);
                      },
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
