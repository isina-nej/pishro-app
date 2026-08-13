import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';

/// The «منبع: … · آخرین به‌روزرسانی: …» line the market deck puts at the foot
/// of every data screen. Market numbers are never shown without saying where
/// they came from and how fresh they are, so this is one widget rather than a
/// line rewritten per screen.
class DataSourceNote extends StatelessWidget {
  const DataSourceNote({super.key, this.source, this.generatedAt, this.extra});

  /// Provider name, e.g. «سرویس داده نمونه». Omitted when unknown.
  final String? source;

  /// When the snapshot was produced, rendered as «۲ دقیقه پیش».
  final DateTime? generatedAt;

  /// Screen-specific tail, e.g. «بازه انتخاب‌شده: ۲۴ ساعت».
  final String? extra;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final parts = [
      if (source != null && source!.isNotEmpty) 'منبع: $source',
      if (generatedAt != null)
        'آخرین به‌روزرسانی: ${Fmt.relative(generatedAt!)}',
      if (extra != null && extra!.isNotEmpty) extra!,
    ];
    if (parts.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: Space.s4),
      child: Text(
        parts.join(' · '),
        style: context.text.caption.copyWith(color: c.textMuted),
      ),
    );
  }
}

/// «داده‌ها با تأخیر نمایش داده می‌شوند.» — the delay disclaimer, which the
/// deck requires wherever a price is listed outside the live detail screen.
class DelayedDataNote extends StatelessWidget {
  const DelayedDataNote({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: Space.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.schedule_rounded, size: 14, color: c.textMuted),
          const SizedBox(width: Space.s2),
          Expanded(
            child: Text(
              message ?? 'داده‌ها با تأخیر نمایش داده می‌شوند.',
              style: context.text.caption.copyWith(color: c.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
