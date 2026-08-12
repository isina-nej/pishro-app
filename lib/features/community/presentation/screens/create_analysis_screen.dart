import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/pishro_chip.dart';
import '../../../../shared/widgets/pishro_text_field.dart';
import '../../../../shared/widgets/states.dart';

import '../../data/community_models.dart';
import '../../data/community_repository.dart';

class CreateAnalysisScreen extends ConsumerWidget {
  const CreateAnalysisScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final draft = ref.watch(analysisDraftProvider);
    final assets = ref.watch(communityAssetsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تحلیل جدید',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          Text(
            'نوع تحلیل',
            style: context.text.bodySmall.copyWith(color: c.textSecondary),
          ),
          Wrap(
            spacing: Space.s2,
            children: [
              for (final k in AnalysisKind.values)
                PishroChip(
                  label: k.label,
                  selected: draft.kind == k,
                  onTap: () => ref
                      .read(analysisDraftProvider.notifier)
                      .update((d) => d.copyWith(kind: k)),
                ),
            ],
          ),
          const SizedBox(height: Space.s4),
          assets.when(
            loading: () => const Skeleton.line(),
            error: (_, __) => const SizedBox.shrink(),
            data: (list) => Wrap(
              spacing: Space.s2,
              children: [
                for (final a in list)
                  PishroChip(
                    label: a.symbol,
                    selected: draft.asset?.symbol == a.symbol,
                    onTap: () => ref
                        .read(analysisDraftProvider.notifier)
                        .update((d) => d.copyWith(asset: a)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Space.s4),
          PishroTextField(
            label: 'عنوان',
            hint: 'بدون توصیه خرید/فروش',
            onChanged: (v) => ref
                .read(analysisDraftProvider.notifier)
                .update((d) => d.copyWith(title: v)),
          ),
          const SizedBox(height: Space.s4),
          Text(
            'افشای منافع — بدون پیش‌انتخاب',
            style: context.text.bodySmall.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: Space.s2),
          Text(
            'آیا در این دارایی موقعیت دارید؟',
            style: context.text.caption.copyWith(color: c.textMuted),
          ),
          Wrap(
            spacing: Space.s2,
            children: [
              PishroChip(
                label: 'بله',
                selected: draft.holdsAsset == true,
                onTap: () => ref
                    .read(analysisDraftProvider.notifier)
                    .update((d) => d.copyWith(holdsAsset: true)),
              ),
              PishroChip(
                label: 'خیر',
                selected: draft.holdsAsset == false,
                onTap: () => ref
                    .read(analysisDraftProvider.notifier)
                    .update((d) => d.copyWith(holdsAsset: false)),
              ),
            ],
          ),
          const SizedBox(height: Space.s3),
          Text(
            'آیا اسپانسر دارد؟',
            style: context.text.caption.copyWith(color: c.textMuted),
          ),
          Wrap(
            spacing: Space.s2,
            children: [
              PishroChip(
                label: 'بله',
                selected: draft.isSponsored == true,
                onTap: () => ref
                    .read(analysisDraftProvider.notifier)
                    .update((d) => d.copyWith(isSponsored: true)),
              ),
              PishroChip(
                label: 'خیر',
                selected: draft.isSponsored == false,
                onTap: () => ref
                    .read(analysisDraftProvider.notifier)
                    .update((d) => d.copyWith(isSponsored: false)),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.page),
          child: PishroButton(
            label: 'ادامه به ویرایشگر',
            onPressed: draft.canContinue
                ? () => context.push(Routes.analysisEditor)
                : null,
          ),
        ),
      ),
    );
  }
}
