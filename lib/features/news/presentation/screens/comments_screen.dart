import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/pishro_text_field.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/news_repository.dart';
import '../widgets/article_card.dart';
import '../widgets/comment_tile.dart';

/// Screen/News/Comments.
class NewsCommentsScreen extends ConsumerStatefulWidget {
  const NewsCommentsScreen({super.key, this.id = ''});

  final String id;

  @override
  ConsumerState<NewsCommentsScreen> createState() => _NewsCommentsScreenState();
}

class _NewsCommentsScreenState extends ConsumerState<NewsCommentsScreen> {
  final _text = TextEditingController();
  var _sending = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final body = _text.text.trim();
    if (body.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await ref.read(newsCommentsRepositoryProvider).add(widget.id, body);
      _text.clear();
      ref.invalidate(newsCommentsProvider(widget.id));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final comments = ref.watch(newsCommentsProvider(widget.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'دیدگاه‌ها',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: NewsAsync(
              value: comments,
              onRetry: () => ref.invalidate(newsCommentsProvider(widget.id)),
              builder: (context, items) {
                if (items.isEmpty) {
                  return const EmptyState(
                    title: 'اولین نفری باشید که نظر می‌دهد',
                    message: 'دیدگاه‌ها پس از بررسی منتشر می‌شوند.',
                    icon: Icons.chat_bubble_outline_rounded,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(Space.page),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: Space.s3),
                  itemBuilder: (_, i) {
                    final comment = items[i];
                    return CommentTile(
                      comment: comment,
                      onReplies: comment.totalReplies == 0
                          ? null
                          : () => context.push(
                              Routes.newsCommentThread(widget.id, comment.id),
                            ),
                    );
                  },
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
              child: Row(
                children: [
                  Expanded(
                    child: PishroTextField(
                      controller: _text,
                      label: 'دیدگاه شما',
                      hint: 'متن دیدگاه…',
                    ),
                  ),
                  IconButton(
                    tooltip: _sending ? 'در حال ارسال' : 'ثبت دیدگاه',
                    onPressed: _sending ? null : _send,
                    icon: Icon(
                      Icons.send_rounded,
                      color: _sending ? c.textMuted : c.actionPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
