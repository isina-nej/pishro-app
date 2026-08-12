import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/article_body.dart';
import '../../data/news_repository.dart';
import '../widgets/article_card.dart';

/// Screen/News/Details — بدنه متن ساده، هرگز HTML خام.
class NewsDetailsScreen extends ConsumerWidget {
  const NewsDetailsScreen({super.key, this.id = ''});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final article = ref.watch(newsArticleProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'جزئیات خبر',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: NewsAsync(
        value: article,
        skeleton: const Padding(
          padding: EdgeInsets.all(Space.page),
          child: Column(
            children: [
              Skeleton.cover(),
              SizedBox(height: Space.s4),
              Skeleton.line(),
              SizedBox(height: Space.s2),
              Skeleton.line(width: 200),
            ],
          ),
        ),
        onRetry: () => ref.invalidate(newsArticleProvider(id)),
        builder: (context, a) {
          final paras = parseArticleBody(a.content);
          if (paras.isEmpty) {
            return const EmptyState(
              title: 'این خبر دیگر در دسترس نیست',
              icon: Icons.article_outlined,
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              Space.page,
              Space.s3,
              Space.page,
              Space.s8,
            ),
            children: [
              if (a.coverImage != null)
                ArticleCover(url: a.coverImage, height: 180, radius: Radii.lg),
              const SizedBox(height: Space.s4),
              Text(
                a.title,
                style: context.text.h2.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: Space.s2),
              ArticleMetaLine(
                parts: [
                  if (a.category.isNotEmpty) a.category,
                  if (a.author != null) a.author!,
                  if (a.date != null) Fmt.relative(a.date!),
                  '${Fmt.fa('${a.readingMinutes}')} دقیقه مطالعه',
                ],
              ),
              const SizedBox(height: Space.s2),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: SaveButton(article: a),
              ),
              const SizedBox(height: Space.s5),
              for (final p in paras) ...[
                Text(
                  p,
                  style: context.text.bodyMedium.copyWith(
                    color: c.textSecondary,
                    height: 1.9,
                  ),
                ),
                const SizedBox(height: Space.s4),
              ],
              Text(
                'این مطلب جنبه اطلاع‌رسانی دارد و توصیه سرمایه‌گذاری نیست.',
                style: context.text.caption.copyWith(color: c.textMuted),
              ),
              const SizedBox(height: Space.s4),
              PishroButton(
                label: 'دیدگاه‌ها',
                variant: PishroButtonVariant.secondary,
                onPressed: () => context.push(Routes.newsComments(a.slug)),
              ),
            ],
          );
        },
      ),
    );
  }
}
