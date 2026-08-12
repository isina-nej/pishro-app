import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/investment_repository.dart';
import '../widgets/plan_tile.dart';

/// Screen/Investment/Home.
class InvestmentHomeScreen extends ConsumerWidget {
  const InvestmentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final plans = ref.watch(plansProvider);
    final intro = ref.watch(catalogIntroProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'سرمایه‌گذاری',
          style: context.text.h2.copyWith(color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: Space.s8),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Space.page,
              Space.s4,
              Space.page,
              0,
            ),
            child: intro.maybeWhen(
              data: (i) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    i.title,
                    style: context.text.h3.copyWith(color: c.textPrimary),
                  ),
                  const SizedBox(height: Space.s2),
                  Text(
                    i.description,
                    style: context.text.bodySmall.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
                ],
              ),
              orElse: () => Text(
                'طرح‌های سرمایه‌گذاری پیشرو',
                style: context.text.h3.copyWith(color: c.textPrimary),
              ),
            ),
          ),
          const SizedBox(height: Space.s3),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: Space.page),
            child: NoticeBanner(
              message: 'اعداد نمایش‌داده‌شده برآورد است، تضمین سود نیست.',
              tone: NoticeTone.warning,
            ),
          ),
          SectionHeader(
            title: 'طرح‌ها',
            onSeeAll: () => context.push(Routes.planCatalog),
          ),
          plans.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(Space.page),
              child: Skeleton.box(height: 96),
            ),
            error: (e, _) => ErrorStateView(
              message: e is ApiException ? e.message : 'طرح‌ها بارگذاری نشد.',
              onRetry: () => ref.invalidate(plansProvider),
            ),
            data: (items) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.page),
              child: Column(
                children: [
                  for (final p in items.take(3)) ...[
                    PlanTile(
                      plan: p,
                      onTap: () => context.push(Routes.planDetails(p.id)),
                    ),
                    const SizedBox(height: Space.s3),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Space.page),
            child: Column(
              children: [
                PishroButton(
                  label: 'مقایسه طرح‌ها',
                  variant: PishroButtonVariant.secondary,
                  onPressed: () => context.push(Routes.planComparison),
                ),
                const SizedBox(height: Space.s3),
                PishroButton(
                  label: 'ماشین‌حساب برآورد',
                  variant: PishroButtonVariant.ghost,
                  onPressed: () => context.push(Routes.calculator),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('سرمایه‌گذاری‌های فعال'),
                  trailing: const Icon(Icons.chevron_left_rounded),
                  onTap: () => context.push(Routes.activeInvestments),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('افشای ریسک'),
                  trailing: const Icon(Icons.chevron_left_rounded),
                  onTap: () => context.push(Routes.riskDisclosure),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
