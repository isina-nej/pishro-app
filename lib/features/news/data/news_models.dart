import 'package:flutter/foundation.dart';

/// Models for the News module.
///
/// Shapes verified against the backend handlers:
/// * `GET /api/news`        -> `paginatedResponse` — `{items, pagination}`
///   (`app/api/news/route.ts`, Prisma `NewsArticle` rows + `relatedCategory`).
/// * `GET /api/news/[slug]` -> `successResponse` — a raw `NewsArticle` row
///   (`lib/services/news-mysql.ts`, `SELECT *`).
/// * `GET /api/user/bookmarks` -> `{items: BookmarkItem[]}`
///   (`app/api/user/bookmarks/route.ts` — already flattened server-side).
/// * `GET /api/comments`    -> a bare list of comment rows.
///
/// Every field is parsed defensively: the two news endpoints go through
/// different code paths (Prisma vs raw mysql2), so `tags` arrives as either a
/// JSON array or a JSON string, and dates as either ISO strings or nulls.
@immutable
class NewsArticle {
  const NewsArticle({
    required this.id,
    required this.title,
    required this.slug,
    required this.category,
    this.excerpt = '',
    this.content = '',
    this.coverImage,
    this.author,
    this.categoryId,
    this.tags = const [],
    this.publishedAt,
    this.createdAt,
    this.views = 0,
    this.likes = 0,
    this.readingTime,
    this.featured = false,
    this.commentCount,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    final related = json['relatedCategory'];
    return NewsArticle(
      id: '${json['id'] ?? ''}',
      title: '${json['title'] ?? ''}',
      slug: '${json['slug'] ?? ''}',
      category: related is Map
          ? '${related['title'] ?? json['category'] ?? ''}'
          : '${json['category'] ?? ''}',
      excerpt: '${json['excerpt'] ?? ''}',
      // `contentHtml` is the rendered column; `content` is the authored one.
      // Both are unsanitised HTML — see `article_body.dart`.
      content: '${json['contentHtml'] ?? json['content'] ?? ''}',
      coverImage: _nullableString(json['coverImage']),
      author: _nullableString(json['author']),
      categoryId: _nullableString(
        related is Map
            ? related['id'] ?? json['categoryId']
            : json['categoryId'],
      ),
      tags: _stringList(json['tags']),
      publishedAt: _date(json['publishedAt']),
      createdAt: _date(json['createdAt']),
      views: _int(json['views']) ?? 0,
      likes: _int(json['likes']) ?? 0,
      readingTime: _int(json['readingTime']),
      featured: json['featured'] == true || json['featured'] == 1,
      commentCount: _int(json['commentCount'] ?? json['commentsCount']),
    );
  }

  final String id;
  final String title;
  final String slug;
  final String category;
  final String excerpt;

  /// Server-rendered, **unsanitised** HTML. Never hand this to a raw-HTML
  /// renderer — go through `parseArticleBody`.
  final String content;

  final String? coverImage;
  final String? author;
  final String? categoryId;
  final List<String> tags;
  final DateTime? publishedAt;
  final DateTime? createdAt;
  final int views;
  final int likes;
  final int? readingTime;
  final bool featured;

  /// Absent from every current handler; rendered only when a future endpoint
  /// starts sending it.
  final int? commentCount;

  DateTime? get date => publishedAt ?? createdAt;

  /// The deck shows «۴ دقیقه مطالعه» on every card. `readingTime` is nullable
  /// in the schema, so fall back to a word-count estimate at 200 wpm.
  int get readingMinutes {
    if (readingTime != null && readingTime! > 0) return readingTime!;
    final words = content.split(RegExp(r'\s+')).length;
    return words < 200 ? 1 : (words / 200).ceil();
  }
}

@immutable
class NewsPage {
  const NewsPage({
    required this.items,
    this.page = 1,
    this.totalPages = 1,
    this.total = 0,
    this.hasNextPage = false,
  });

  factory NewsPage.fromJson(Map<String, dynamic> json) {
    final raw = json['items'];
    final pagination = json['pagination'];
    return NewsPage(
      items: [
        if (raw is List)
          for (final e in raw)
            if (e is Map<String, dynamic>) NewsArticle.fromJson(e),
      ],
      page: pagination is Map ? _int(pagination['page']) ?? 1 : 1,
      totalPages: pagination is Map ? _int(pagination['totalPages']) ?? 1 : 1,
      total: pagination is Map ? _int(pagination['total']) ?? 0 : 0,
      hasNextPage: pagination is Map && pagination['hasNextPage'] == true,
    );
  }

  final List<NewsArticle> items;
  final int page;
  final int totalPages;
  final int total;
  final bool hasNextPage;
}

/// A comment on an article.
///
/// The backend models article comments as `NewsComment` (`content`, `articleId`)
/// but only exposes `GET /api/comments`, which reads the unrelated `Comment`
/// table (`text`, `userName`). Both shapes are accepted so this survives
/// whichever endpoint ships.
@immutable
class NewsComment {
  const NewsComment({
    required this.id,
    required this.author,
    required this.text,
    this.avatar,
    this.createdAt,
    this.pending = false,
    this.replies = const [],
    this.replyCount,
  });

  factory NewsComment.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final rawReplies = json['replies'];
    final replies = [
      if (rawReplies is List)
        for (final e in rawReplies)
          if (e is Map<String, dynamic>) NewsComment.fromJson(e),
    ];
    return NewsComment(
      id: '${json['id'] ?? ''}',
      author:
          _nullableString(json['userName']) ??
          (user is Map ? _nullableString(user['name']) : null) ??
          'کاربر پیشرو',
      text: '${json['content'] ?? json['text'] ?? ''}',
      avatar:
          _nullableString(json['userAvatar']) ??
          (user is Map ? _nullableString(user['image']) : null),
      createdAt: _date(json['createdAt']),
      // `published: false` is the moderation queue — «در انتظار بررسی».
      pending: json.containsKey('published') && json['published'] != true,
      replies: replies,
      replyCount:
          _int(json['replyCount']) ?? (replies.isEmpty ? null : replies.length),
    );
  }

  final String id;
  final String author;
  final String text;
  final String? avatar;
  final DateTime? createdAt;
  final bool pending;
  final List<NewsComment> replies;
  final int? replyCount;

  int get totalReplies => replyCount ?? replies.length;
}

/// One row of `GET /api/user/bookmarks`, narrowed to `type == "news"`.
@immutable
class SavedArticle {
  const SavedArticle({
    required this.bookmarkId,
    required this.articleId,
    required this.title,
    required this.slug,
    this.image,
    this.author,
    this.category,
    this.savedAt,
    this.publishedAt,
  });

  factory SavedArticle.fromJson(Map<String, dynamic> json) {
    final href = '${json['href'] ?? ''}';
    return SavedArticle(
      bookmarkId: '${json['id'] ?? ''}',
      articleId: '${json['itemId'] ?? ''}',
      title: '${json['title'] ?? ''}',
      slug: href.startsWith('/news/') ? href.substring('/news/'.length) : href,
      image: _nullableString(json['image']),
      author: _nullableString(json['subtitle']),
      category: _nullableString(json['badge']),
      savedAt: _date(json['createdAt']),
      // Not in the current payload — the route drops `publishedAt` when it
      // flattens the row. Parsed anyway so the sort works the day it lands.
      publishedAt: _date(json['publishedAt']),
    );
  }

  final String bookmarkId;
  final String articleId;
  final String title;
  final String slug;
  final String? image;
  final String? author;
  final String? category;
  final DateTime? savedAt;
  final DateTime? publishedAt;
}

/// A category tile on News/Categories. There is no categories endpoint, so
/// these are folded out of the article feed — see `NewsRepository.categories`.
@immutable
class NewsCategoryGroup {
  const NewsCategoryGroup({
    required this.title,
    required this.count,
    required this.latestTitle,
    this.id,
  });

  final String title;
  final String? id;
  final int count;
  final String latestTitle;
}

/// Sort order of a feed. `GET /news` only ever orders by `publishedAt desc`,
/// so anything else is applied to the loaded pages client-side.
enum NewsSort { newest, mostViewed, mostCommented }

/// «امروز · ۷ روز گذشته · ۳۰ روز گذشته · بازه دلخواه» — also client-side.
enum NewsRange { all, today, week, month, custom }

extension NewsRangeX on NewsRange {
  String get label => switch (this) {
    NewsRange.all => 'همه',
    NewsRange.today => 'امروز',
    NewsRange.week => 'این هفته',
    NewsRange.month => 'این ماه',
    NewsRange.custom => 'بازه دلخواه',
  };

  /// Label used inside the filter sheet, which words the same ranges as spans.
  String get spanLabel => switch (this) {
    NewsRange.all => 'همه زمان‌ها',
    NewsRange.today => 'امروز',
    NewsRange.week => '۷ روز گذشته',
    NewsRange.month => '۳۰ روز گذشته',
    NewsRange.custom => 'بازه دلخواه',
  };

  Duration? get window => switch (this) {
    NewsRange.all => null,
    NewsRange.today => const Duration(days: 1),
    NewsRange.week => const Duration(days: 7),
    NewsRange.month => const Duration(days: 30),
    // Explicit endpoints instead of a rolling window — see NewsQuery.custom.
    NewsRange.custom => null,
  };
}

extension NewsSortX on NewsSort {
  String get label => switch (this) {
    NewsSort.newest => 'جدیدترین',
    NewsSort.mostViewed => 'پربازدیدترین',
    NewsSort.mostCommented => 'بیشترین دیدگاه',
  };
}

/// «نوع محتوا» from the filter sheet. `GET /news` has no content-type column,
/// so a kind is matched against the article's own tags and category text —
/// the only signal the payload carries.
enum NewsKind { all, news, analysis, report, tutorial }

extension NewsKindX on NewsKind {
  String get label => switch (this) {
    NewsKind.all => 'همه',
    NewsKind.news => 'خبر',
    NewsKind.analysis => 'تحلیل',
    NewsKind.report => 'گزارش',
    NewsKind.tutorial => 'آموزش',
  };

  bool matches(NewsArticle a) {
    if (this == NewsKind.all) return true;
    final needle = label;
    return a.category.contains(needle) || a.tags.any((t) => t.contains(needle));
  }
}

/// Identity of a feed request. A record so `FutureProvider.family` gets value
/// equality for free.
typedef NewsQuery = ({
  String? search,
  String? category,
  NewsSort sort,
  NewsRange range,
  NewsKind kind,

  /// Publisher name as it appears in `NewsArticle.author`; null = همه منابع.
  String? source,

  /// Endpoints of «بازه دلخواه». Only read when [range] is
  /// [NewsRange.custom]; a custom range without one falls back to همه زمان‌ها.
  ({DateTime start, DateTime end})? custom,
});

const NewsQuery latestNews = (
  search: null,
  category: null,
  sort: NewsSort.newest,
  range: NewsRange.all,
  kind: NewsKind.all,
  source: null,
  custom: null,
);

String? _nullableString(dynamic value) {
  if (value == null) return null;
  final s = '$value'.trim();
  return s.isEmpty || s == 'null' ? null : s;
}

int? _int(dynamic value) => switch (value) {
  int v => v,
  num v => v.round(),
  String v => int.tryParse(v),
  _ => null,
};

DateTime? _date(dynamic value) =>
    value is String ? DateTime.tryParse(value)?.toLocal() : null;

/// `tags` is a MySQL JSON column: Prisma decodes it to a `List`, the raw
/// mysql2 path can hand back the encoded string.
List<String> _stringList(dynamic value) {
  if (value is List) return value.map((e) => '$e').toList();
  if (value is String && value.trim().startsWith('[')) {
    final inner = value.trim();
    return inner
        .substring(1, inner.length - 1)
        .split(',')
        .map((e) => e.trim().replaceAll('"', ''))
        .where((e) => e.isNotEmpty)
        .toList();
  }
  return const [];
}
