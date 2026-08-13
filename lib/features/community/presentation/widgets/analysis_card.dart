import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_badge.dart';
import '../../data/community_models.dart';

/// One analysis in a feed — Community Home, AssetFeed and Search all use it.
/// Locked (subscriber-only) analyses are not tappable and carry the premium
/// badge with a lock icon, so the gate is never colour alone.
class AnalysisCard extends StatelessWidget {
  const AnalysisCard(this.a, {super.key});

  final Analysis a;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return PishroCard(
      onTap: a.isLocked
          ? null
          : () => context.push(Routes.analysisDetails(a.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                a.assetSymbol,
                style: context.text.caption.copyWith(color: c.textMuted),
              ),
              const Spacer(),
              if (a.risk != null) RiskBadge(a.risk!),
            ],
          ),
          const SizedBox(height: Space.s2),
          Text(
            a.title,
            style: context.text.bodyMedium.copyWith(
              color: c.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: Space.s1),
          Text(
            '${a.author.displayName} · ${a.kind.label} · ${Fmt.relative(a.publishedAt)}',
            style: context.text.caption.copyWith(color: c.textMuted),
          ),
          if (a.summary != null && !a.isLocked) ...[
            const SizedBox(height: Space.s2),
            Text(
              a.summary!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodySmall.copyWith(
                color: c.textSecondary,
                height: 1.8,
              ),
            ),
          ],
          if (a.isLocked) ...[
            const SizedBox(height: Space.s2),
            const PishroBadge(
              label: 'مخصوص مشترکان',
              tone: PishroBadgeTone.premium,
              icon: Icons.lock_outline_rounded,
            ),
            const SizedBox(height: Space.s2),
            Text(
              'مشاهده کامل نیازمند اشتراک است',
              style: context.text.caption.copyWith(color: c.textMuted),
            ),
          ]
          // Engagement figures are null wherever the deck shows none — on a
          // locked preview there is nothing to count yet.
          else if (a.helpfulCount != null || a.commentCount != null) ...[
            const SizedBox(height: Space.s3),
            Row(
              children: [
                if (a.helpfulCount != null)
                  _Metric(
                    icon: Icons.thumb_up_outlined,
                    label: 'مفید',
                    count: a.helpfulCount!,
                  ),
                if (a.commentCount != null) ...[
                  const SizedBox(width: Space.s4),
                  _Metric(
                    icon: Icons.mode_comment_outlined,
                    label: 'دیدگاه',
                    count: a.commentCount!,
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// «مفید (۱۸)» — icon, word and number together, never a bare count.
class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label, required this.count});

  final IconData icon;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: c.textMuted),
        const SizedBox(width: Space.s1),
        Text(
          '$label (${Fmt.fa('$count')})',
          style: context.text.caption.copyWith(color: c.textMuted),
        ),
      ],
    );
  }
}
