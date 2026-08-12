import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_badge.dart';
import '../../../../shared/widgets/pishro_chip.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/community_models.dart';
import '../../data/community_repository.dart';

/// Screen/AnalysisComments.
class AnalysisCommentsScreen extends ConsumerStatefulWidget {
  const AnalysisCommentsScreen({super.key, this.id = ''});

  final String id;

  @override
  ConsumerState<AnalysisCommentsScreen> createState() =>
      _AnalysisCommentsScreenState();
}

class _AnalysisCommentsScreenState
    extends ConsumerState<AnalysisCommentsScreen> {
  var _sort = CommentSort.newest;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final comments = ref.watch(analysisCommentsProvider(widget.id));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'دیدگاه‌های تحلیل',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: Column(
        children: [
          PishroChipBar(
            labels: [for (final s in CommentSort.values) s.label],
            selectedIndex: _sort.index,
            onSelected: (i) => setState(() => _sort = CommentSort.values[i]),
          ),
          Expanded(
            child: comments.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => ErrorStateView(
                onRetry: () =>
                    ref.invalidate(analysisCommentsProvider(widget.id)),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const EmptyState(title: 'دیدگاهی نیست');
                }
                final sorted = [...items];
                sorted.sort(
                  (a, b) => switch (_sort) {
                    CommentSort.newest => b.publishedAt.compareTo(
                      a.publishedAt,
                    ),
                    CommentSort.oldest => a.publishedAt.compareTo(
                      b.publishedAt,
                    ),
                    CommentSort.mostHelpful => b.replyCount.compareTo(
                      a.replyCount,
                    ),
                  },
                );
                return ListView.separated(
                  padding: const EdgeInsets.all(Space.page),
                  itemCount: sorted.length,
                  separatorBuilder: (_, __) => const SizedBox(height: Space.s3),
                  itemBuilder: (_, i) {
                    final cm = sorted[i];
                    return PishroCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${cm.authorName} · ${Fmt.relative(cm.publishedAt)}',
                            style: context.text.caption.copyWith(
                              color: c.textMuted,
                            ),
                          ),
                          const SizedBox(height: Space.s2),
                          Text(
                            cm.body,
                            style: context.text.bodySmall.copyWith(
                              color: c.textPrimary,
                            ),
                          ),
                          if (cm.replyCount > 0) ...[
                            const SizedBox(height: Space.s2),
                            Text(
                              '${Fmt.fa('${cm.replyCount}')} پاسخ',
                              style: context.text.caption.copyWith(
                                color: c.actionPrimary,
                              ),
                            ),
                          ],
                          if (cm.moderation.label != null) ...[
                            const SizedBox(height: Space.s2),
                            PishroBadge(
                              label: cm.moderation.label!,
                              tone: PishroBadgeTone.warning,
                              icon: Icons.hourglass_top_rounded,
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
