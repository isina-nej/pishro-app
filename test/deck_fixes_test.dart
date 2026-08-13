import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishro_app/core/theme/app_theme.dart';
import 'package:pishro_app/shared/widgets/jalali_range_picker.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:pishro_app/features/investment/data/investment_flow.dart';
import 'package:pishro_app/features/news/data/news_models.dart';
import 'package:pishro_app/features/news/data/news_repository.dart';

/// The two bits of real logic added while closing the deck gaps: the
/// four-part risk consent gate and the news kind/source filters.
void main() {
  test('risk consent needs all four acknowledgements, none pre-selected', () {
    const fresh = InvestmentDraft();
    expect(fresh.riskChecks, isEmpty);
    expect(fresh.riskAccepted, isFalse);

    final partial = fresh.copyWith(riskChecks: {0, 1, 2});
    expect(partial.riskAccepted, isFalse);
    expect(partial.consentsOk, isFalse);

    final all = fresh.copyWith(
      riskChecks: {for (var i = 0; i < kRiskAcknowledgements.length; i++) i},
    );
    expect(all.riskAccepted, isTrue);
    expect(all.consentsOk, isFalse, reason: 'the contract is still unread');
    expect(all.copyWith(termsAccepted: true).consentsOk, isTrue);
  });

  test('news filters narrow by content kind and by source', () {
    final items = [
      _article(id: '1', category: 'تحلیل بازار', author: 'تحریریه پیشرو'),
      _article(id: '2', category: 'اقتصاد', author: 'خبرگزاری نمونه'),
      _article(
        id: '3',
        category: 'اقتصاد',
        author: 'تحریریه پیشرو',
        tags: ['گزارش'],
      ),
    ];

    List<String> ids(NewsQuery q) =>
        applyNewsQuery(items, q).map((a) => a.id).toList();

    expect(ids(latestNews).length, 3);

    final analysisOnly = (
      search: null,
      category: null,
      sort: NewsSort.newest,
      range: NewsRange.all,
      kind: NewsKind.analysis,
      source: null,
      custom: null,
    );
    expect(ids(analysisOnly), ['1']);

    // A kind can come from the tags as well as the category.
    final reportOnly = (
      search: null,
      category: null,
      sort: NewsSort.newest,
      range: NewsRange.all,
      kind: NewsKind.report,
      source: null,
      custom: null,
    );
    expect(ids(reportOnly), ['3']);

    final onePublisher = (
      search: null,
      category: null,
      sort: NewsSort.newest,
      range: NewsRange.all,
      kind: NewsKind.all,
      source: 'خبرگزاری نمونه',
      custom: null,
    );
    expect(ids(onePublisher), ['2']);
  });

  test('a custom Jalali range filters on its own endpoints, inclusively', () {
    final today = Jalali.now();
    final yesterday = today.addDays(-1);
    final lastWeek = today.addDays(-7);

    final items = [
      _article(id: 'today', category: 'اقتصاد', at: today.toDateTime()),
      _article(id: 'yday', category: 'اقتصاد', at: yesterday.toDateTime()),
      _article(id: 'old', category: 'اقتصاد', at: lastWeek.toDateTime()),
    ];

    final range = JalaliRange(from: yesterday, to: today);
    final q = (
      search: null,
      category: null,
      sort: NewsSort.newest,
      range: NewsRange.custom,
      kind: NewsKind.all,
      source: null,
      custom: (start: range.start, end: range.end),
    );

    final ids = applyNewsQuery(items, q).map((a) => a.id).toSet();
    expect(ids, {'today', 'yday'}, reason: 'both endpoint days are included');
  });

  testWidgets('the Jalali picker orders a backwards selection', (tester) async {
    ({JalaliRange? range})? picked;
    final today = Jalali.now();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        locale: const Locale('fa', 'IR'),
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async =>
                      picked = await showJalaliRangePicker(context),
                  child: const Text('باز کن'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('باز کن'));
    await tester.pumpAndSettle();

    // Pick the later day first, then the earlier one.
    await tester.tap(find.text('۵').first);
    await tester.pump();
    await tester.tap(find.text('۲').first);
    await tester.pump();
    await tester.tap(find.text('تأیید بازه'));
    await tester.pumpAndSettle();

    expect(picked, isNotNull);
    final range = picked!.range;
    expect(range, isNotNull, reason: 'confirm returns the picked range');
    expect(range!.from.day, 2);
    expect(range.to.day, 5);
    expect(range.from.month, today.month, reason: 'opens on the current month');
    expect(range.start.isBefore(range.end), isTrue);
  });
}

NewsArticle _article({
  required String id,
  required String category,
  String? author,
  List<String> tags = const [],
  DateTime? at,
}) => NewsArticle.fromJson({
  'id': id,
  'title': 'عنوان $id',
  'slug': 'slug-$id',
  'category': category,
  'excerpt': '',
  'content': '',
  'author': author,
  'tags': tags,
  'publishedAt': (at ?? DateTime.now()).toIso8601String(),
});
