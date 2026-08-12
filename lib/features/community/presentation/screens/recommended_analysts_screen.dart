import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/states.dart';

import '../../../../core/utils/formatters.dart';
import '../../data/community_repository.dart';

class RecommendedAnalystsScreen extends ConsumerWidget {
  const RecommendedAnalystsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final list = ref.watch(recommendedAnalystsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تحلیلگران پیشنهادی',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: list.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ErrorStateView(
          onRetry: () => ref.invalidate(recommendedAnalystsProvider),
        ),
        data: (items) => ListView.separated(
          padding: const EdgeInsets.all(Space.page),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: Space.s3),
          itemBuilder: (_, i) {
            final a = items[i];
            return PishroCard(
              onTap: () => context.push(Routes.analystProfile(a.id)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a.displayName,
                    style: context.text.bodyMedium.copyWith(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${a.specialty} · ${Fmt.fa(a.rating.toStringAsFixed(1))} از ۵',
                    style: context.text.caption.copyWith(color: c.textMuted),
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
