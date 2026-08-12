import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/pishro_badge.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/pishro_chip.dart';
import '../../../../shared/widgets/pishro_text_field.dart';

import '../../data/community_models.dart';
import '../../data/community_repository.dart';

class AnalysisEditorScreen extends ConsumerWidget {
  const AnalysisEditorScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final draft = ref.watch(analysisDraftProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ویرایشگر تحلیل',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          PishroTextField(
            label: 'خلاصه',
            onChanged: (v) => ref
                .read(analysisDraftProvider.notifier)
                .update((d) => d.copyWith(summary: v)),
          ),
          const SizedBox(height: Space.s4),
          PishroTextField(
            label: 'متن',
            onChanged: (v) => ref
                .read(analysisDraftProvider.notifier)
                .update((d) => d.copyWith(body: v)),
          ),
          const SizedBox(height: Space.s4),
          PishroTextField(
            label: 'شرط بی‌اعتبار شدن',
            onChanged: (v) => ref
                .read(analysisDraftProvider.notifier)
                .update((d) => d.copyWith(invalidation: v)),
          ),
          const SizedBox(height: Space.s4),
          Text(
            'افق زمانی',
            style: context.text.caption.copyWith(color: c.textMuted),
          ),
          Wrap(
            spacing: Space.s2,
            children: [
              for (final t in Timeframe.values)
                PishroChip(
                  label: t.label,
                  selected: draft.timeframe == t,
                  onTap: () => ref
                      .read(analysisDraftProvider.notifier)
                      .update((d) => d.copyWith(timeframe: t)),
                ),
            ],
          ),
          const SizedBox(height: Space.s3),
          Text(
            'ریسک',
            style: context.text.caption.copyWith(color: c.textMuted),
          ),
          Wrap(
            spacing: Space.s2,
            children: [
              PishroChip(
                label: 'کم',
                selected: draft.risk == RiskLevel.low,
                onTap: () => ref
                    .read(analysisDraftProvider.notifier)
                    .update((d) => d.copyWith(risk: RiskLevel.low)),
              ),
              PishroChip(
                label: 'متوسط',
                selected: draft.risk == RiskLevel.medium,
                onTap: () => ref
                    .read(analysisDraftProvider.notifier)
                    .update((d) => d.copyWith(risk: RiskLevel.medium)),
              ),
              PishroChip(
                label: 'بالا',
                selected: draft.risk == RiskLevel.high,
                onTap: () => ref
                    .read(analysisDraftProvider.notifier)
                    .update((d) => d.copyWith(risk: RiskLevel.high)),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.page),
          child: PishroButton(
            label: 'پیش‌نمایش',
            onPressed: () => context.push(Routes.analysisPreview),
          ),
        ),
      ),
    );
  }
}
