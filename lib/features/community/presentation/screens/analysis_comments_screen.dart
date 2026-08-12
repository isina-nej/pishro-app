import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_badge.dart';
import '../../../../shared/widgets/states.dart';

import '../../../../core/utils/formatters.dart';
import '../../data/community_repository.dart';

class AnalysisCommentsScreen extends ConsumerWidget {
  const AnalysisCommentsScreen({super.key, this.id = ''});
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final comments = ref.watch(analysisCommentsProvider(id));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'دیدگاه‌های تحلیل',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: comments.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ErrorStateView(
          onRetry: () => ref.invalidate(analysisCommentsProvider(id)),
        ),
        data: (items) => items.isEmpty
            ? const EmptyState(title: 'دیدگاهی نیست')
            : ListView.separated(
                padding: const EdgeInsets.all(Space.page),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: Space.s3),
                itemBuilder: (_, i) {
                  final cm = items[i];
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
                        Text(
                          cm.body,
                          style: context.text.bodySmall.copyWith(
                            color: c.textPrimary,
                          ),
                        ),
                        if (cm.moderation.label != null)
                          PishroBadge(
                            label: cm.moderation.label!,
                            tone: PishroBadgeTone.warning,
                            icon: Icons.hourglass_top_rounded,
                          ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
