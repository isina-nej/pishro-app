import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/tokens.dart';
import 'pishro_button.dart';

/// SKELETON from Frame 06. Every list/detail screen in the decks ships a
/// skeleton variant, so this is the shared primitive for all of them.
class Skeleton extends StatelessWidget {
  const Skeleton({
    super.key,
    this.width,
    this.height = 16,
    this.radius = Radii.sm,
  });

  const Skeleton.line({super.key, this.width, this.height = 14})
    : radius = Radii.xs;

  const Skeleton.box({super.key, this.width, this.height = 120})
    : radius = Radii.card;

  /// 16:9 course/news cover placeholder.
  const Skeleton.cover({super.key})
    : width = double.infinity,
      height = 180,
      radius = Radii.card;

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Shimmer.fromColors(
      baseColor: c.surfaceSecondary,
      highlightColor: c.borderDefault,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: c.surfaceSecondary,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// FEEDBACK/empty — «هنوز دوره‌ای شروع نکرده‌اید» pattern.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Space.s6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: c.surfaceSecondary,
                borderRadius: BorderRadius.circular(Radii.xl),
              ),
              child: Icon(icon, size: 32, color: c.textMuted),
            ),
            const SizedBox(height: Space.s4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.text.h3.copyWith(color: c.textPrimary),
            ),
            if (message != null) ...[
              const SizedBox(height: Space.s2),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: context.text.bodySmall.copyWith(color: c.textMuted),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: Space.s6),
              PishroButton(
                label: actionLabel!,
                onPressed: onAction,
                expanded: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// FEEDBACK/error — «اتصال اینترنت برقرار نیست.» + «تلاش دوباره».
class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    super.key,
    this.message = 'اتصال اینترنت برقرار نیست.',
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Space.s6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 40, color: c.danger),
            const SizedBox(height: Space.s4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.text.bodyMedium.copyWith(color: c.textSecondary),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: Space.s5),
              PishroButton(
                label: 'تلاش دوباره',
                variant: PishroButtonVariant.secondary,
                onPressed: onRetry,
                expanded: false,
                icon: Icons.refresh_rounded,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// FEEDBACK/notice — the risk disclaimer banner used across Investment.
class NoticeBanner extends StatelessWidget {
  const NoticeBanner({
    super.key,
    required this.message,
    this.tone = NoticeTone.warning,
  });

  final String message;
  final NoticeTone tone;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (color, icon) = switch (tone) {
      NoticeTone.info => (c.info, Icons.info_outline_rounded),
      NoticeTone.warning => (c.warning, Icons.warning_amber_rounded),
      NoticeTone.success => (c.success, Icons.check_circle_outline_rounded),
      NoticeTone.danger => (c.danger, Icons.error_outline_rounded),
    };

    return Container(
      padding: const EdgeInsets.all(Space.s3 + 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: Space.s2 + 2),
          Expanded(
            child: Text(
              message,
              style: context.text.bodySmall.copyWith(color: c.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

enum NoticeTone { info, warning, success, danger }
