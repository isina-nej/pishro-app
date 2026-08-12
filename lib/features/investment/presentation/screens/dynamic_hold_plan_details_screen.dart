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
import '../../../../shared/widgets/states.dart';
import '../../data/investment_flow.dart';
import '../../data/investment_repository.dart';

/// A deck spec row: muted label on one side, value on the other.
class _SpecRow extends StatelessWidget {
  const _SpecRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: context.text.caption.copyWith(color: c.textMuted),
          ),
        ),
        const SizedBox(width: Space.s3),
        Text(
          value,
          style: context.text.bodySmall.copyWith(color: c.textPrimary),
        ),
      ],
    );
  }
}

/// Screen/Investment/DynamicHoldPlanDetails — بدون درصد اختراعی.
class DynamicHoldPlanDetailsScreen extends ConsumerWidget {
  const DynamicHoldPlanDetailsScreen({super.key, this.id = ''});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final plan = ref.watch(planProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'طرح هولد داینامیک',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: plan.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            ErrorStateView(onRetry: () => ref.invalidate(planProvider(id))),
        data: (p) {
          if (p == null) {
            return const EmptyState(title: 'این طرح یافت نشد');
          }
          return ListView(
            padding: const EdgeInsets.all(Space.page),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      p.name,
                      style: context.text.h2.copyWith(color: c.textPrimary),
                    ),
                  ),
                  RiskBadge(p.riskLevel),
                ],
              ),
              const SizedBox(height: Space.s2),
              Text(
                'سطح ریسک: وابسته به نوسان بازار',
                style: context.text.caption.copyWith(color: c.textMuted),
              ),
              const SizedBox(height: Space.s3),
              const _SpecRow(label: 'مدل بازده', value: 'داینامیک'),
              const SizedBox(height: Space.s3),
              Text(
                p.description ??
                    'بازده این طرح متغیر است و ممکن است افزایش یا کاهش یابد.',
                style: context.text.bodySmall.copyWith(
                  color: c.textSecondary,
                  height: 1.8,
                ),
              ),
              const SizedBox(height: Space.s4),
              const NoticeBanner(
                message: 'داده تاریخی تأییدشده برای نمایش در دسترس نیست.',
                tone: NoticeTone.info,
              ),
              const SizedBox(height: Space.s5),
              Text(
                'سناریوهای برآوردی (نمونه)',
                style: context.text.bodyMedium.copyWith(
                  color: c.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: Space.s3),
              // Three scenarios, all unvalued until the service ships one.
              // The deck forbids a dedicated green for the upside row, so all
              // three render identically.
              for (final s in const ['کاهشی', 'میانه', 'افزایشی']) ...[
                _SpecRow(label: s, value: 'داده نیاز است'),
                const SizedBox(height: Space.s2),
              ],
              const SizedBox(height: Space.s3),
              _SpecRow(
                label: 'دوره هولد',
                value:
                    '${Fmt.fa('${p.minDurationMonths}')} تا ${Fmt.fa('${p.maxDurationMonths}')} ماه',
              ),
              const SizedBox(height: Space.s2),
              _SpecRow(
                label: 'حداقل / حداکثر مبلغ',
                value: '${Fmt.toman(p.minAmount)} تا ${Fmt.toman(p.maxAmount)}',
              ),
              const SizedBox(height: Space.s2),
              const _SpecRow(
                label: 'شرایط خروج زودهنگام',
                value: 'طبق شرایط قرارداد',
              ),
              const SizedBox(height: Space.s5),
              const NoticeBanner(
                message:
                    'هیچ درصد یا سود تضمینی برای طرح هولد نمایش داده نمی‌شود.',
                tone: NoticeTone.warning,
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: plan.maybeWhen(
        data: (p) => p == null
            ? null
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(Space.page),
                  child: PishroButton(
                    label: 'بررسی شرایط سرمایه‌گذاری',
                    onPressed: () {
                      ref.read(investmentFlowProvider.notifier).start(p);
                      context.push(Routes.riskDisclosure);
                    },
                  ),
                ),
              ),
        orElse: () => null,
      ),
    );
  }
}
