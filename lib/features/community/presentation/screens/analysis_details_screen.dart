import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/pishro_badge.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/states.dart';

import '../../../../core/utils/formatters.dart';
import '../../data/community_repository.dart';

class AnalysisDetailsScreen extends ConsumerWidget {
  const AnalysisDetailsScreen({super.key, this.id = ''});
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final analysis = ref.watch(analysisProvider(id));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'جزئیات تحلیل',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: analysis.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            ErrorStateView(onRetry: () => ref.invalidate(analysisProvider(id))),
        data: (a) {
          if (a == null) return const EmptyState(title: 'تحلیل یافت نشد');
          if (a.isLocked) {
            return EmptyState(
              title: 'این تحلیل مخصوص مشترکان است',
              actionLabel: 'اشتراک‌ها',
              onAction: () => context.push(Routes.subscriptions),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(Space.page),
            children: [
              Text(
                a.title,
                style: context.text.h2.copyWith(color: c.textPrimary),
              ),
              Text(
                '${a.assetSymbol} · ${a.author.displayName} · ${Fmt.relative(a.publishedAt)}',
                style: context.text.caption.copyWith(color: c.textMuted),
              ),
              if (a.risk != null) ...[
                const SizedBox(height: Space.s3),
                RiskBadge(a.risk!),
              ],
              if (a.summary != null) ...[
                const SizedBox(height: Space.s4),
                Text(
                  a.summary!,
                  style: context.text.bodySmall.copyWith(
                    color: c.textSecondary,
                  ),
                ),
              ],
              if (a.body != null) ...[
                const SizedBox(height: Space.s3),
                Text(
                  a.body!,
                  style: context.text.bodySmall.copyWith(
                    color: c.textSecondary,
                    height: 1.8,
                  ),
                ),
              ],
              if (a.scenarios.isNotEmpty) ...[
                const SizedBox(height: Space.s4),
                Text(
                  'سناریوها (هم‌وزن)',
                  style: context.text.bodySmall.copyWith(
                    color: c.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                for (final s in a.scenarios)
                  Text(
                    '• ${s.label}${s.note == null ? '' : ' — ${s.note}'}',
                    style: context.text.caption.copyWith(color: c.textMuted),
                  ),
              ],
              if (a.invalidation != null) ...[
                const SizedBox(height: Space.s4),
                NoticeBanner(
                  message: a.invalidation!,
                  tone: NoticeTone.warning,
                ),
              ],
              const SizedBox(height: Space.s5),
              PishroButton(
                label: 'دیدگاه‌ها',
                variant: PishroButtonVariant.secondary,
                onPressed: () => context.push(Routes.analysisComments(id)),
              ),
            ],
          );
        },
      ),
    );
  }
}
