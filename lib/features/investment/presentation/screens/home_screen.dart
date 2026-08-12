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
import '../../../../core/utils/formatters.dart';
import '../../data/investment_models.dart';
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
          const SizedBox(height: Space.s4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.page),
            child: _PortfolioSummary(txs: ref.watch(transactionsProvider)),
          ),
          SectionHeader(
            title: 'طرح‌های فعال',
            onSeeAll: () => context.push(Routes.activeInvestments),
          ),
          _ActivePreview(txs: ref.watch(transactionsProvider)),
          SectionHeader(
            title: 'طرح‌های سرمایه‌گذاری',
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
                  title: const Text('اطلاع‌رسانی ریسک'),
                  trailing: const Icon(Icons.chevron_left_rounded),
                  onTap: () => context.push(Routes.riskDisclosure),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('قراردادها'),
                  trailing: const Icon(Icons.chevron_left_rounded),
                  onTap: () => context.push(Routes.terms),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// «سرمایه فعال · دریافتی ثبت‌شده · پرداخت بعدی» — the deck's header trio.
///
/// Totals are summed from the user's own transactions; there is no portfolio
/// endpoint, so nothing here is a projection. «دریافتی ثبت‌شده» counts only
/// settled payouts, never pending ones.
class _PortfolioSummary extends StatelessWidget {
  const _PortfolioSummary({required this.txs});

  final AsyncValue<List<InvestmentTransaction>> txs;

  @override
  Widget build(BuildContext context) {
    return txs.when(
      loading: () => const Skeleton.box(height: 84),
      error: (_, __) => const SizedBox.shrink(),
      data: (items) {
        final active = [
          for (final t in items)
            if (t.status == TxStatus.success) t,
        ];
        final invested = active.fold<int>(0, (sum, t) => sum + t.amount);

        return PishroCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _SummaryCell(
                  label: 'سرمایه فعال',
                  value: invested == 0 ? kSampleValue : Fmt.toman(invested),
                ),
              ),
              Expanded(
                child: _SummaryCell(
                  label: 'دریافتی ثبت‌شده',
                  // No payout ledger exists yet — never guess a return.
                  value: kSampleValue,
                ),
              ),
              const Expanded(
                child: _SummaryCell(
                  label: 'پرداخت بعدی',
                  value: 'طبق برنامه قرارداد',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryCell extends StatelessWidget {
  const _SummaryCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.text.caption.copyWith(color: c.textMuted)),
        const SizedBox(height: Space.s1),
        Text(
          value,
          style: context.text.bodySmall.copyWith(
            color: c.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// The single most recent active plan, matching the deck's «طرح‌های فعال» row.
class _ActivePreview extends StatelessWidget {
  const _ActivePreview({required this.txs});

  final AsyncValue<List<InvestmentTransaction>> txs;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return txs.maybeWhen(
      data: (items) {
        final active = [
          for (final t in items)
            if (t.status == TxStatus.success) t,
        ];
        if (active.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: Space.page),
            child: EmptyState(title: 'هنوز طرح فعالی ندارید'),
          );
        }
        final t = active.first;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.page),
          child: PishroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.title,
                  style: context.text.bodyMedium.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: Space.s1),
                Text(
                  'شروع: ${Fmt.jalaliLong(t.createdAt)} · نرخ اعلام‌شده طرح',
                  style: context.text.caption.copyWith(color: c.textMuted),
                ),
              ],
            ),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}
