import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/jalali_range_picker.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/pishro_chip.dart';
import '../../data/news_models.dart';
import '../../data/news_repository.dart';
import '../../news_routes.dart';

/// Screen/News/Filters — «۰۴ · فیلتر».
///
/// Four groups: زمان انتشار (including «بازه دلخواه») · نوع محتوا · منبع ·
/// ترتیب نمایش, with the deck's selected-count line above the CTA.
class NewsFiltersScreen extends ConsumerWidget {
  const NewsFiltersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final q = ref.watch(newsQueryProvider);
    final sources = ref.watch(newsSourcesProvider);

    void update({
      NewsSort? sort,
      NewsRange? range,
      NewsKind? kind,
      String? source,
      bool clearSource = false,
      ({DateTime start, DateTime end})? custom,
      bool clearCustom = false,
    }) => ref.read(newsQueryProvider.notifier).state = (
      search: q.search,
      category: q.category,
      sort: sort ?? q.sort,
      range: range ?? q.range,
      kind: kind ?? q.kind,
      source: clearSource ? null : (source ?? q.source),
      custom: clearCustom ? null : (custom ?? q.custom),
    );

    Future<void> pickCustomRange() async {
      final existing = q.custom;
      final picked = await showJalaliRangePicker(
        context,
        initial: existing == null
            ? null
            : JalaliRange(
                from: Jalali.fromDateTime(existing.start),
                to: Jalali.fromDateTime(existing.end),
              ),
      );
      if (picked == null) {
        // Cleared — fall back to همه زمان‌ها rather than an empty custom range.
        if (q.range == NewsRange.custom) {
          update(range: NewsRange.all, clearCustom: true);
        }
        return;
      }
      update(
        range: NewsRange.custom,
        custom: (start: picked.start, end: picked.end),
      );
    }

    final selectedCount = [
      q.range != NewsRange.all,
      q.kind != NewsKind.all,
      q.source != null,
      q.sort != NewsSort.newest,
    ].where((e) => e).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'فیلتر اخبار',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: selectedCount == 0
                ? null
                : () => update(
                    sort: NewsSort.newest,
                    range: NewsRange.all,
                    kind: NewsKind.all,
                    clearSource: true,
                    clearCustom: true,
                  ),
            child: const Text('پاک کردن همه'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          _Group(
            title: 'زمان انتشار',
            children: [
              for (final r in NewsRange.values)
                if (r == NewsRange.custom)
                  PishroChip(
                    label: q.custom == null
                        ? r.spanLabel
                        : '${Fmt.jalaliDate(q.custom!.start)} تا ${Fmt.jalaliDate(q.custom!.end)}',
                    selected: q.range == NewsRange.custom,
                    onTap: pickCustomRange,
                  )
                else
                  PishroChip(
                    label: r.spanLabel,
                    selected: q.range == r,
                    onTap: () => update(range: r, clearCustom: true),
                  ),
            ],
          ),
          _Group(
            title: 'نوع محتوا',
            children: [
              for (final k in NewsKind.values)
                PishroChip(
                  label: k.label,
                  selected: q.kind == k,
                  onTap: () => update(kind: k),
                ),
            ],
          ),
          _Group(
            title: 'منبع',
            children: [
              PishroChip(
                label: 'همه منابع',
                selected: q.source == null,
                onTap: () => update(clearSource: true),
              ),
              for (final s in sources.valueOrNull ?? const <String>[])
                PishroChip(
                  label: s,
                  selected: q.source == s,
                  onTap: () => update(source: s),
                ),
            ],
          ),
          _Group(
            title: 'ترتیب نمایش',
            children: [
              for (final s in NewsSort.values)
                PishroChip(
                  label: s.label,
                  selected: q.sort == s,
                  onTap: () => update(sort: s),
                ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.page),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (selectedCount > 0) ...[
                Text(
                  '${Fmt.fa('$selectedCount')} فیلتر انتخاب‌شده',
                  style: context.text.caption.copyWith(color: c.textMuted),
                ),
                const SizedBox(height: Space.s2),
              ],
              PishroButton(
                label: 'نمایش نتایج',
                onPressed: () => context.go(newsSearchResultsPath()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.text.bodySmall.copyWith(
            color: c.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: Space.s3),
        Wrap(spacing: Space.s2, runSpacing: Space.s2, children: children),
        const SizedBox(height: Space.s6),
      ],
    );
  }
}
