import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/pishro_badge.dart';
import '../../data/news_models.dart';

/// Comment/Card from Frame 02 — avatar, name, time, body, action bar.
///
/// The moderation state is a badge with its own words («در انتظار بررسی»), not
/// a tint on the card, per the deck's «برچسب تعدیل مستقل از رنگ برند».
class CommentTile extends StatelessWidget {
  const CommentTile({
    super.key,
    required this.comment,
    this.onReplies,
    this.onReport,
    this.compact = false,
  });

  final NewsComment comment;
  final VoidCallback? onReplies;
  final VoidCallback? onReport;

  /// Nested replies drop the surface and shrink one step.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _Avatar(url: comment.avatar, size: compact ? 24 : 28),
            const SizedBox(width: Space.s2),
            Flexible(
              child: Text(
                comment.author,
                style: (compact ? context.text.micro : context.text.caption)
                    .copyWith(
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: Space.s2),
            if (comment.pending)
              const PishroBadge(
                label: 'در انتظار بررسی',
                tone: PishroBadgeTone.warning,
                icon: Icons.schedule_rounded,
              )
            else if (comment.createdAt != null)
              Text(
                Fmt.relative(comment.createdAt!),
                style: context.text.micro.copyWith(color: c.textMuted),
              ),
          ],
        ),
        SizedBox(height: compact ? 5 : Space.s1 + 2),
        Text(
          comment.text,
          style: (compact ? context.text.caption : context.text.bodySmall)
              .copyWith(height: 1.8, color: c.textSecondary),
        ),
        if (!compact && (onReplies != null || onReport != null)) ...[
          const SizedBox(height: Space.s1 + 2),
          Row(
            children: [
              if (onReplies != null)
                _Action(
                  label: 'پاسخ‌ها (${Fmt.fa('${comment.totalReplies}')})',
                  onTap: onReplies,
                ),
              if (onReplies != null && onReport != null)
                const SizedBox(width: Space.s3 + 2),
              if (onReport != null)
                _Action(label: 'گزارش', onTap: onReport),
            ],
          ),
        ],
      ],
    );

    if (compact) return body;

    return Container(
      padding: const EdgeInsets.all(Space.s3),
      decoration: BoxDecoration(
        color: c.surfaceSecondary,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: c.borderDefault),
      ),
      child: body,
    );
  }
}

/// The reply composer on News/CommentThread.
///
/// It carries its own [MediaQuery.viewInsetsOf] padding so it sits directly on
/// top of the software keyboard — the deck marks this screen «کیبوردایمن».
/// Hosts must set `resizeToAvoidBottomInset: false` so the inset is applied
/// once, not twice.
class CommentComposer extends StatelessWidget {
  const CommentComposer({
    super.key,
    required this.controller,
    required this.onSend,
    this.hint = 'پاسخ خود را بنویسید…',
    this.replyingTo,
    this.onCancelReply,
    this.sending = false,
    this.autofocus = false,
    this.maxLength = 300,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSend;
  final String hint;
  final String? replyingTo;
  final VoidCallback? onCancelReply;
  final bool sending;
  final bool autofocus;
  final int maxLength;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      key: const Key('news.composer'),
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            Space.page,
            Space.s2 + 2,
            Space.page,
            Space.s3,
          ),
          decoration: BoxDecoration(
            color: c.backgroundApp,
            border: Border(top: BorderSide(color: c.divider)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (replyingTo != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'در پاسخ به $replyingTo',
                        style: context.text.micro.copyWith(color: c.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (onCancelReply != null)
                      _Action(
                        label: 'لغو',
                        color: c.danger,
                        onTap: onCancelReply,
                      ),
                  ],
                ),
                const SizedBox(height: Space.s1 + 2),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('news.composerField'),
                      controller: controller,
                      autofocus: autofocus,
                      enabled: !sending,
                      maxLength: maxLength,
                      maxLines: 4,
                      minLines: 1,
                      textInputAction: TextInputAction.newline,
                      style: context.text.bodySmall.copyWith(
                        color: c.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: hint,
                        counterText: '',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: Space.s3 + 2,
                          vertical: Space.s3,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: Space.s2),
                  _SendButton(
                    sending: sending,
                    onTap: () {
                      final text = controller.text.trim();
                      if (text.isEmpty) return;
                      onSend(text);
                    },
                  ),
                ],
              ),
              const SizedBox(height: Space.s1),
              ValueListenableBuilder(
                valueListenable: controller,
                builder: (context, value, _) => Text(
                  '${Fmt.fa('${value.text.characters.length}')} از ${Fmt.fa('$maxLength')} نویسه',
                  style: context.text.micro.copyWith(color: c.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.sending, required this.onTap});

  final bool sending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: 'ارسال دیدگاه',
      child: Material(
        color: c.actionPrimary,
        shape: const CircleBorder(),
        child: InkWell(
          key: const Key('news.composerSend'),
          onTap: sending ? null : onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: Layout.minTapTarget,
            height: Layout.minTapTarget,
            child: sending
                ? Padding(
                    padding: const EdgeInsets.all(Space.s3),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: c.onAction,
                    ),
                  )
                : Icon(Icons.send_rounded, size: 18, color: c.onAction),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.size});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: url == null || url!.isEmpty
            ? ColoredBox(
                color: c.surfacePrimary,
                child: Icon(
                  Icons.person_rounded,
                  size: size * 0.6,
                  color: c.textMuted,
                ),
              )
            : CachedNetworkImage(
                imageUrl: url!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => ColoredBox(
                  color: c.surfacePrimary,
                  child: Icon(
                    Icons.person_rounded,
                    size: size * 0.6,
                    color: c.textMuted,
                  ),
                ),
              ),
      ),
    );
  }
}

/// Inline text action with a 44px-tall hit box.
class _Action extends StatelessWidget {
  const _Action({required this.label, this.onTap, this.color});

  final String label;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(Radii.xs),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Space.s1,
        vertical: Space.s2 + 2,
      ),
      child: Text(
        label,
        style: context.text.micro.copyWith(
          color: color ?? context.colors.textMuted,
        ),
      ),
    ),
  );
}
