import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import 'news_models.dart';

/// Reads for the News module.
///
/// Only four endpoints exist:
/// `GET /news` · `GET /news/{slug}` · `GET|POST|DELETE /user/bookmarks`.
/// Everything else the deck asks for (trending order, categories, date range,
/// sort) is folded out of the feed client-side — see [applyNewsQuery].
abstract class NewsRepository {
  Future<NewsPage> feed({
    int page,
    int limit,
    String? search,
    String? category,
  });

  Future<NewsArticle> article(String slug);

  /// There is no categories endpoint; the tiles on News/Categories are grouped
  /// out of the newest page of the feed.
  Future<List<NewsCategoryGroup>> categories();

  Future<List<SavedArticle>> bookmarks();

  Future<void> addBookmark(String articleId);

  Future<void> removeBookmark(String articleId);
}

class ApiNewsRepository implements NewsRepository {
  const ApiNewsRepository(this._api);

  final ApiClient _api;

  @override
  Future<NewsPage> feed({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
  }) async {
    final data = await _api.get<Map<String, dynamic>>(
      '/news',
      query: {
        'page': page,
        // The handler clamps `limit` to 50.
        'limit': limit.clamp(1, 50),
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (category != null && category.isNotEmpty) 'category': category,
      },
    );
    return NewsPage.fromJson(data);
  }

  @override
  Future<NewsArticle> article(String slug) async {
    final data = await _api.get<Map<String, dynamic>>('/news/$slug');
    return NewsArticle.fromJson(data);
  }

  @override
  Future<List<NewsCategoryGroup>> categories() async {
    final page = await feed(limit: 50);
    return groupCategories(page.items);
  }

  @override
  Future<List<SavedArticle>> bookmarks() async {
    final data = await _api.get<Map<String, dynamic>>('/user/bookmarks');
    final items = data['items'];
    return [
      if (items is List)
        for (final e in items)
          if (e is Map<String, dynamic> && e['type'] == 'news')
            SavedArticle.fromJson(e),
    ];
  }

  @override
  Future<void> addBookmark(String articleId) => _api.post<dynamic>(
    '/user/bookmarks',
    body: {'type': 'news', 'itemId': articleId},
  );

  @override
  Future<void> removeBookmark(String articleId) => _api.delete<dynamic>(
    '/user/bookmarks',
    body: {'type': 'news', 'itemId': articleId},
  );
}

/// Groups a loaded feed into the «۱۲۴ خبر · آخرین: …» tiles of Frame 03.
/// The feed is already ordered newest-first, so the first hit per category is
/// its latest article.
List<NewsCategoryGroup> groupCategories(List<NewsArticle> items) {
  final byTitle = <String, ({String? id, int count, String latest})>{};
  for (final a in items) {
    if (a.category.isEmpty) continue;
    final seen = byTitle[a.category];
    byTitle[a.category] = seen == null
        ? (id: a.categoryId, count: 1, latest: a.title)
        : (
            id: seen.id ?? a.categoryId,
            count: seen.count + 1,
            latest: seen.latest,
          );
  }
  final groups = [
    for (final e in byTitle.entries)
      NewsCategoryGroup(
        title: e.key,
        id: e.value.id,
        count: e.value.count,
        latestTitle: e.value.latest,
      ),
  ]..sort((a, b) => b.count.compareTo(a.count));
  return groups;
}

/// `GET /news` only orders by `publishedAt desc` and knows nothing about date
/// windows, so the deck's sort and range controls are applied here.
List<NewsArticle> applyNewsQuery(
  List<NewsArticle> items,
  NewsQuery query, {
  DateTime? now,
}) {
  final window = query.range.window;
  final cutoff = window == null
      ? null
      : (now ?? DateTime.now()).subtract(window);

  final out = [
    for (final a in items)
      if (cutoff == null || (a.date?.isAfter(cutoff) ?? false)) a,
  ];

  out.sort(switch (query.sort) {
    NewsSort.newest => (a, b) => (b.date ?? DateTime(0)).compareTo(
      a.date ?? DateTime(0),
    ),
    NewsSort.mostViewed => (a, b) => b.views.compareTo(a.views),
    NewsSort.mostCommented => (a, b) => (b.commentCount ?? 0).compareTo(
      a.commentCount ?? 0,
    ),
  });
  return out;
}

/// Article comments have **no endpoint**: `GET /api/comments` reads the
/// unrelated course `Comment` table and cannot be scoped to an article, and
/// there is no POST at all. Per CLAUDE.md this sits behind an interface with a
/// mock implementation so swapping in the real route is a provider change.
abstract class NewsCommentsRepository {
  Future<List<NewsComment>> forArticle(String articleId);

  Future<NewsComment> add(String articleId, String text, {String? parentId});
}

class MockNewsCommentsRepository implements NewsCommentsRepository {
  MockNewsCommentsRepository();

  final _byArticle = <String, List<NewsComment>>{};
  var _nextId = 0;

  @override
  Future<List<NewsComment>> forArticle(String articleId) async =>
      List.unmodifiable(_byArticle[articleId] ?? const <NewsComment>[]);

  @override
  Future<NewsComment> add(
    String articleId,
    String text, {
    String? parentId,
  }) async {
    final comment = NewsComment(
      id: 'local-${_nextId++}',
      author: 'شما',
      text: text,
      createdAt: DateTime.now(),
      // The web moderation queue holds every new comment, so the app shows the
      // «در انتظار بررسی» badge rather than pretending it is live.
      pending: true,
    );
    final list = _byArticle.putIfAbsent(articleId, () => <NewsComment>[]);
    if (parentId == null) {
      list.insert(0, comment);
      return comment;
    }
    final i = list.indexWhere((c) => c.id == parentId);
    if (i < 0) return comment;
    final parent = list[i];
    list[i] = NewsComment(
      id: parent.id,
      author: parent.author,
      text: parent.text,
      avatar: parent.avatar,
      createdAt: parent.createdAt,
      pending: parent.pending,
      replies: [...parent.replies, comment],
    );
    return comment;
  }
}

/// «جستجوهای اخیر» on News/Search. No endpoint — kept on the device.
class RecentSearches {
  const RecentSearches();

  static const _key = 'news.recentSearches';
  static const _max = 8;

  Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? const [];
  }

  Future<List<String>> remember(String term) async {
    final t = term.trim();
    if (t.isEmpty) return load();
    final prefs = await SharedPreferences.getInstance();
    final next = [
      t,
      ...(prefs.getStringList(_key) ?? const []).where((e) => e != t),
    ].take(_max).toList();
    await prefs.setStringList(_key, next);
    return next;
  }

  Future<List<String>> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    return const [];
  }
}

// ---- Providers ----

final newsRepositoryProvider = Provider<NewsRepository>(
  (ref) => ApiNewsRepository(ref.watch(apiClientProvider)),
);

/// Only the mock exists today. When the article-comments route ships, this
/// provider picks between it and the mock on [AppConfig.useMockForMissingApis].
final newsCommentsRepositoryProvider = Provider<NewsCommentsRepository>(
  (ref) => MockNewsCommentsRepository(),
);

final recentSearchesProvider = Provider<RecentSearches>(
  (ref) => const RecentSearches(),
);

/// The feed for one [NewsQuery]. Sort and range are applied to the loaded page.
final newsFeedProvider = FutureProvider.family<List<NewsArticle>, NewsQuery>((
  ref,
  query,
) async {
  final page = await ref
      .watch(newsRepositoryProvider)
      .feed(search: query.search, category: query.category);
  return applyNewsQuery(page.items, query);
});

final newsArticleProvider = FutureProvider.family<NewsArticle, String>(
  (ref, slug) => ref.watch(newsRepositoryProvider).article(slug),
);

final newsCategoriesProvider = FutureProvider<List<NewsCategoryGroup>>(
  (ref) => ref.watch(newsRepositoryProvider).categories(),
);

final newsCommentsProvider = FutureProvider.family<List<NewsComment>, String>(
  (ref, articleId) =>
      ref.watch(newsCommentsRepositoryProvider).forArticle(articleId),
);

final recentSearchListProvider = FutureProvider<List<String>>(
  (ref) => ref.watch(recentSearchesProvider).load(),
);

/// Saved articles + the optimistic bookmark toggle used by every save button.
class BookmarksNotifier extends AsyncNotifier<List<SavedArticle>> {
  @override
  Future<List<SavedArticle>> build() =>
      ref.watch(newsRepositoryProvider).bookmarks();

  bool isSaved(String articleId) =>
      (state.value ?? const []).any((s) => s.articleId == articleId);

  Future<void> toggle(NewsArticle article) async {
    final repo = ref.read(newsRepositoryProvider);
    final current = state.value ?? const <SavedArticle>[];
    final saved = current.where((s) => s.articleId == article.id).toList();

    if (saved.isNotEmpty) {
      state = AsyncData([
        for (final s in current)
          if (s.articleId != article.id) s,
      ]);
      await _guard(() => repo.removeBookmark(article.id), current);
      return;
    }

    state = AsyncData([
      SavedArticle(
        bookmarkId: 'pending-${article.id}',
        articleId: article.id,
        title: article.title,
        slug: article.slug,
        image: article.coverImage,
        author: article.author,
        category: article.category,
        savedAt: DateTime.now(),
        publishedAt: article.date,
      ),
      ...current,
    ]);
    await _guard(() => repo.addBookmark(article.id), current);
  }

  Future<void> removeSaved(SavedArticle saved) async {
    final current = state.value ?? const <SavedArticle>[];
    state = AsyncData([
      for (final s in current)
        if (s.articleId != saved.articleId) s,
    ]);
    await _guard(
      () => ref.read(newsRepositoryProvider).removeBookmark(saved.articleId),
      current,
    );
  }

  /// Roll the optimistic list back if the write failed, so the bookmark icon
  /// never claims a state the server does not have.
  Future<void> _guard(
    Future<void> Function() write,
    List<SavedArticle> rollback,
  ) async {
    try {
      await write();
    } catch (_) {
      state = AsyncData(rollback);
      rethrow;
    }
  }
}

final bookmarksProvider =
    AsyncNotifierProvider<BookmarksNotifier, List<SavedArticle>>(
      BookmarksNotifier.new,
    );
