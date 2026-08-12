import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/pishro_badge.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/pishro_chip.dart';
import '../../../../shared/widgets/pishro_text_field.dart';
import '../../data/community_models.dart';
import '../../data/community_repository.dart';

/// Screen/Community/AnalysisEditor — نوار پایین اسکرول.
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
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: Space.s3),
            child: Center(
              child: Text(
                'ذخیره خودکار شد',
                style: context.text.caption.copyWith(color: c.textMuted),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Space.page,
          Space.s3,
          Space.page,
          120,
        ),
        children: [
          Text(
            draft.title.isEmpty ? 'بدون عنوان' : draft.title,
            style: context.text.h3.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: Space.s4),
          PishroTextField(
            label: 'خلاصه',
            hint: 'در حال نوشتن…',
            onChanged: (v) => ref
                .read(analysisDraftProvider.notifier)
                .update((d) => d.copyWith(summary: v)),
          ),
          const SizedBox(height: Space.s4),
          PishroTextField(
            label: 'متن تحلیل',
            hint: 'متن اصلی تحلیل در این بخش نوشته می‌شود…',
            onChanged: (v) => ref
                .read(analysisDraftProvider.notifier)
                .update((d) => d.copyWith(body: v)),
          ),
          const SizedBox(height: Space.s4),
          PishroTextField(
            label: 'شرط بی‌اعتبارشدن',
            hint: 'مثلاً شکست سطح نمونه',
            onChanged: (v) => ref
                .read(analysisDraftProvider.notifier)
                .update((d) => d.copyWith(invalidation: v)),
          ),
          const SizedBox(height: Space.s4),
          PishroTextField(
            label: 'منابع داده',
            onChanged: (v) => ref
                .read(analysisDraftProvider.notifier)
                .update((d) => d.copyWith(sources: v)),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: Space.page),
                children: [
                  _Tool('B'),
                  _Tool('I'),
                  _Tool('سناریوها'),
                  _Tool('شرط'),
                  _Tool('منابع'),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Space.s3),
                      child: Text(
                        '${Fmt.fa('${draft.characterCount}')} نویسه',
                        style: context.text.caption.copyWith(
                          color: c.textMuted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.page,
                Space.s2,
                Space.page,
                Space.s3,
              ),
              child: PishroButton(
                label: 'پیش‌نمایش',
                onPressed: () => context.push(Routes.analysisPreview),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tool extends StatelessWidget {
  const _Tool(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: Space.s2),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Space.s3,
            vertical: Space.s2,
          ),
          decoration: BoxDecoration(
            color: c.surfaceSecondary,
            borderRadius: BorderRadius.circular(Radii.pill),
            border: Border.all(color: c.borderDefault),
          ),
          child: Text(
            label,
            style: context.text.caption.copyWith(color: c.textPrimary),
          ),
        ),
      ),
    );
  }
}
