import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/pishro_text_field.dart';
import '../../../../shared/widgets/states.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/news_models.dart';
import '../../data/news_repository.dart';
import '../widgets/article_card.dart';
import '../widgets/comment_tile.dart';

/// Screen/News/CommentThread — کیبوردایمن.
class NewsCommentThreadScreen extends ConsumerWidget {
  const NewsCommentThreadScreen({super.key, this.id = '', this.commentId = ''});

  final String id;
  final String commentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final comments = ref.watch(newsCommentsProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'رشته پاسخ',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: NewsAsync(
              value: comments,
              onRetry: () => ref.invalidate(newsCommentsProvider(id)),
              builder: (context, items) {
                NewsComment? parent;
                for (final x in items) {
                  if (x.id == commentId) parent = x;
                }
                if (parent == null) {
                  return const EmptyState(title: 'این دیدگاه پیدا نشد');
                }
                return ListView(
                  padding: const EdgeInsets.all(Space.page),
                  children: [
                    CommentTile(comment: parent),
                    const SizedBox(height: Space.s2),
                    Text(
                      'در پاسخ به ${parent.author}',
                      style: context.text.caption.copyWith(color: c.textMuted),
                    ),
                    const SizedBox(height: Space.s4),
                    Text(
                      'پاسخ‌ها (${Fmt.fa('${parent.totalReplies}')})',
                      style: context.text.bodySmall.copyWith(
                        color: c.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: Space.s3),
                    if (parent.replies.isEmpty)
                      Text(
                        'هنوز پاسخی ثبت نشده است.',
                        style: context.text.caption.copyWith(
                          color: c.textMuted,
                        ),
                      )
                    else
                      for (final r in parent.replies) ...[
                        CommentTile(comment: r, compact: true),
                        const SizedBox(height: Space.s3),
                      ],
                    // Only offered when the server reports more replies than
                    // this page carries — never a button that does nothing.
                    if (parent.totalReplies > parent.replies.length)
                      TextButton(
                        onPressed: () =>
                            ref.invalidate(newsCommentsProvider(id)),
                        child: const Text('مشاهده پاسخ‌های بیشتر'),
                      ),
                  ],
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.page,
                Space.s2,
                Space.page,
                Space.s3,
              ),
              child: const PishroTextField(
                label: 'پاسخ',
                hint: 'پاسخ خود را بنویسید…',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
