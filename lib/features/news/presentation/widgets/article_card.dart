import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/news_models.dart';
import '../../data/news_repository.dart';

/// The three card shapes of Frame 02 — Featured (cover on top), Compact (68px
/// thumb in a row) and Trending (rank + 52px thumb).
///
/// Every meta line is dot-separated exactly as the deck words it:
/// «ارز دیجیتال · ۴۵ دقیقه پیش · ۱۲ دیدگاه».
class FeaturedArticleCard extends StatelessWidget {
  const FeaturedArticleCard({
    super.key,
    required this.article,
    this.onTap,
  });

  final NewsArticle article;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Radii.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ArticleCover(
                url: article.coverImage,
                height: 150,
                radius: Radii.lg - 2,
              ),
              if (article.category.isNotEmpty)
                PositionedDirectional(
                  top: Space.s2 + 2,
                  start: Space.s2 + 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Space.s2 + 1,
                      vertical: Space.s1,
                    ),
                    decoration: BoxDecoration(
                      color: c.backgroundApp.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(Radii.pill),
                    ),
                    child: Text(
                      article.category,
                      style: context.text.micro.copyWith(color: c.textSecondary),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: Space.s2),
          Text(
            article.title,
            style: context.text.bodyLarge.copyWith(
              fontSize: 15,
              height: 1.6,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (article.excerpt.isNotEmpty) ...[
            const SizedBox(height: Space.s2),
            Text(
              article.excerpt,
              style: context.text.micro.copyWith(
                height: 1.8,
                color: c.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: Space.s2),
          ArticleMetaLine(
            parts: [
              if (article.author != null) article.author!,
              if (article.date != null) Fmt.relative(article.date!),
              '${Fmt.fa('${article.readingMinutes}')} دقیقه مطالعه',
            ],
          ),
        ],
      ),
    );
  }
}

/// «آخرین اخبار» row — 68px thumb, title, meta, save button.
class CompactArticleCard extends StatelessWidget {
  const CompactArticleCard({
    super.key,
    required this.article,
    this.onTap,
    this.showSaveButton = true,
  });

  final NewsArticle article;
  final VoidCallback? onTap;
  final bool showSaveButton;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Radii.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Space.s1),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ArticleCover(
              url: article.coverImage,
              height: 68,
              width: 68,
              radius: Radii.sm + 2,
            ),
            const SizedBox(width: Space.s2 + 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: context.text.bodySmall.copyWith(
                      height: 1.6,
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: Space.s1),
                  ArticleMetaLine(parts: _metaOf(article)),
                ],
              ),
            ),
            if (showSaveButton) ...[
              const SizedBox(width: Space.s2),
              SaveButton(article: article),
            ],
          ],
        ),
      ),
    );
  }
}

/// News/SearchResults row — bordered card with an 82px thumb.
class SearchResultCard extends StatelessWidget {
  const SearchResultCard({super.key, required this.article, this.onTap});

  final NewsArticle article;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return _Surface(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ArticleCover(
            url: article.coverImage,
            height: 82,
            width: 82,
            radius: Radii.sm + 2,
          ),
          const SizedBox(width: Space.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  style: context.text.bodySmall.copyWith(
                    height: 1.6,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Space.s1 + 1),
                ArticleMetaLine(parts: _metaOf(article)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// News/Trending row — «۱» rank, 52px thumb, views + comments.
class TrendingArticleCard extends StatelessWidget {
  const TrendingArticleCard({
    super.key,
    required this.article,
    required this.rank,
    this.onTap,
  });

  final NewsArticle article;
  final int rank;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return _Surface(
      onTap: onTap,
      padding: const EdgeInsets.all(Space.s3 - 1),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Text(
              Fmt.fa('$rank'),
              textAlign: TextAlign.center,
              style: context.text.h3.copyWith(
                fontWeight: FontWeight.w700,
                // Top three are the ranked ones the deck highlights.
                color: rank == 1 ? c.actionPrimary : c.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: Space.s2 + 2),
          ArticleCover(
            url: article.coverImage,
            height: 52,
            width: 52,
            radius: Radii.sm,
          ),
          const SizedBox(width: Space.s2 + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  style: context.text.caption.copyWith(
                    height: 1.6,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                ArticleMetaLine(
                  parts: [
                    '${Fmt.grouped(article.views)} بازدید',
                    if (article.commentCount != null)
                      '${Fmt.fa('${article.commentCount}')} دیدگاه',
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// News/Saved row — «ذخیره‌شده: ۲ روز پیش · انتشار: ۳ روز پیش» + a filled mark.
class SavedArticleCard extends StatelessWidget {
  const SavedArticleCard({
    super.key,
    required this.saved,
    this.onTap,
    this.onRemove,
  });

  final SavedArticle saved;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return _Surface(
      onTap: onTap,
      padding: const EdgeInsets.all(Space.s3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ArticleCover(
            url: saved.image,
            height: 72,
            width: 72,
            radius: Radii.sm + 2,
          ),
          const SizedBox(width: Space.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  saved.title,
                  style: context.text.bodySmall.copyWith(
                    height: 1.6,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Space.s1),
                ArticleMetaLine(
                  parts: [
                    if (saved.savedAt != null)
                      'ذخیره‌شده: ${Fmt.relative(saved.savedAt!)}',
                    if (saved.publishedAt != null)
                      'انتشار: ${Fmt.relative(saved.publishedAt!)}',
                    if (saved.savedAt == null && saved.publishedAt == null)
                      saved.category ?? 'اخبار',
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: Space.s2),
          IconButton(
            onPressed: onRemove,
            iconSize: 18,
            tooltip: 'حذف از ذخیره‌شده‌ها',
            constraints: const BoxConstraints(
              minWidth: Layout.minTapTarget,
              minHeight: Layout.minTapTarget,
            ),
            icon: Icon(Icons.bookmark_rounded, color: c.actionPrimary),
          ),
        ],
      ),
    );
  }
}

/// Bookmark toggle. Icon *and* semantics label change, never colour alone.
class SaveButton extends ConsumerWidget {
  const SaveButton({super.key, required this.article, this.dense = true});

  final NewsArticle article;
  final bool dense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final saved = ref.watch(
      bookmarksProvider.select(
        (v) => (v.value ?? const <SavedArticle>[])
            .any((s) => s.articleId == article.id),
      ),
    );

    return IconButton(
      key: const Key('news.saveButton'),
      iconSize: dense ? 18 : 22,
      tooltip: saved ? 'حذف از ذخیره‌شده‌ها' : 'ذخیره خبر',
      constraints: const BoxConstraints(
        minWidth: Layout.minTapTarget,
        minHeight: Layout.minTapTarget,
      ),
      onPressed: () async {
        try {
          await ref.read(bookmarksProvider.notifier).toggle(article);
        } catch (_) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ذخیره خبر انجام نشد.')),
          );
        }
      },
      icon: Icon(
        saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
        color: saved ? c.actionPrimary : c.textMuted,
        semanticLabel: saved ? 'ذخیره شده' : 'ذخیره نشده',
      ),
    );
  }
}

/// Dot-separated meta line. Persian «·» separators come from the deck.
class ArticleMetaLine extends StatelessWidget {
  const ArticleMetaLine({super.key, required this.parts});

  final List<String> parts;

  @override
  Widget build(BuildContext context) => Text(
    parts.where((p) => p.isNotEmpty).join(' · '),
    style: context.text.micro.copyWith(color: context.colors.textMuted),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
}

/// Cover image. A missing/failed image falls back to the neutral diagonal
/// stripe the deck specifies («پترن راه‌راه خنثی به‌جای شکستگی تصویر») rather
/// than a broken-image glyph.
class ArticleCover extends StatelessWidget {
  const ArticleCover({
    super.key,
    required this.url,
    required this.height,
    this.width,
    this.radius = Radii.md,
  });

  final String? url;
  final double height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final placeholder = _StripePattern(height: height, width: width);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        height: height,
        width: width ?? double.infinity,
        child: url == null || url!.isEmpty
            ? placeholder
            : CachedNetworkImage(
                imageUrl: url!,
                fit: BoxFit.cover,
                placeholder: (_, __) => placeholder,
                errorWidget: (_, __, ___) => placeholder,
              ),
      ),
    );
  }
}

class _StripePattern extends StatelessWidget {
  const _StripePattern({required this.height, this.width});

  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return CustomPaint(
      size: Size(width ?? double.infinity, height),
      painter: _StripePainter(base: c.surfaceSecondary, stripe: c.borderDefault),
    );
  }
}

class _StripePainter extends CustomPainter {
  const _StripePainter({required this.base, required this.stripe});

  final Color base;
  final Color stripe;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = base);
    final paint = Paint()
      ..color = stripe
      ..strokeWidth = 8;
    // 135° stripes, 16px pitch — matches the deck's repeating-linear-gradient.
    for (var x = -size.height; x < size.width + size.height; x += 16) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_StripePainter old) =>
      old.base != base || old.stripe != stripe;
}

/// List skeleton for News/Home, SearchResults and Saved.
class ArticleListSkeleton extends StatelessWidget {
  const ArticleListSkeleton({super.key, this.rows = 4, this.featured = false});

  final int rows;
  final bool featured;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(Space.page, Space.s3, Space.page, Space.s6),
    children: [
      if (featured) ...[
        const Skeleton(height: 150, radius: Radii.lg),
        const SizedBox(height: Space.s2),
        const Skeleton.line(width: 260),
        const SizedBox(height: Space.s2),
        const Skeleton.line(width: 180),
        const SizedBox(height: Space.s5),
      ],
      for (var i = 0; i < rows; i++) ...[
        const Row(
          children: [
            Skeleton(width: 68, height: 68, radius: Radii.sm),
            SizedBox(width: Space.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeleton.line(),
                  SizedBox(height: Space.s2),
                  Skeleton.line(width: 120),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: Space.s4),
      ],
    ],
  );
}

/// Loading / error / data for every News screen — skeleton while fetching,
/// [ErrorStateView] with «تلاش دوباره» on failure, matching the
/// Home-Loading / Home-Error frames.
class NewsAsync<T> extends StatelessWidget {
  const NewsAsync({
    super.key,
    required this.value,
    required this.builder,
    this.onRetry,
    this.skeleton,
    this.message = 'بارگذاری اخبار انجام نشد.',
  });

  final AsyncValue<T> value;
  final Widget Function(BuildContext context, T data) builder;
  final VoidCallback? onRetry;
  final Widget? skeleton;
  final String message;

  @override
  Widget build(BuildContext context) => value.when(
    data: (data) => builder(context, data),
    loading: () => skeleton ?? const ArticleListSkeleton(),
    error: (error, _) => ErrorStateView(
      // Offline gets the connectivity copy; anything else keeps the screen's
      // own wording («بارگذاری اخبار انجام نشد.»).
      message: error is NetworkException
          ? 'اتصال اینترنت برقرار نیست.'
          : message,
      onRetry: onRetry,
    ),
  );
}

/// Tonal surface + hairline border. [PishroCard] hardcodes 16px padding and a
/// 16px radius; the news rows are 13px/14px, so this keeps the deck's metrics
/// without touching the shared component.
class _Surface extends StatelessWidget {
  const _Surface({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(Space.s3 + 1),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.surfaceSecondary,
      borderRadius: BorderRadius.circular(Radii.lg - 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.lg - 2),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Radii.lg - 2),
            border: Border.all(color: c.borderDefault),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

List<String> _metaOf(NewsArticle a) => [
  if (a.category.isNotEmpty) a.category,
  if (a.date != null) Fmt.relative(a.date!),
  if (a.commentCount != null) '${Fmt.fa('${a.commentCount}')} دیدگاه',
];
