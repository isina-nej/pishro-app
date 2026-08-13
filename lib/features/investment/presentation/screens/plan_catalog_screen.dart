import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/investment_repository.dart';
import '../widgets/plan_tile.dart';

/// Screen/Investment/PlanCatalog.
class PlanCatalogScreen extends ConsumerWidget {
  const PlanCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final plans = ref.watch(plansProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'فهرست طرح‌ها',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: plans.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(Space.page),
          children: const [
            Skeleton.box(height: 96),
            SizedBox(height: Space.s3),
            Skeleton.box(height: 96),
          ],
        ),
        error: (e, _) => ErrorStateView(
          message: e is ApiException ? e.message : 'طرح‌ها بارگذاری نشد.',
          onRetry: () => ref.invalidate(plansProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyState(title: 'طرحی برای نمایش نیست');
          }
          return ListView(
            padding: const EdgeInsets.all(Space.page),
            children: [
              for (final p in items) ...[
                PlanTile(
                  plan: p,
                  onTap: () => context.push(Routes.planDetails(p.id)),
                ),
                const SizedBox(height: Space.s3),
              ],
              if (items.length > 1) ...[
                const SizedBox(height: Space.s2),
                PishroButton(
                  label: 'مقایسه هر دو طرح',
                  variant: PishroButtonVariant.secondary,
                  onPressed: () => context.push(Routes.planComparison),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
