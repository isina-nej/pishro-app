import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/investment_flow.dart';

/// Screen/Investment/Success — سفارش ثبت شد، نه لزوماً فعال.
class InvestmentSuccessScreen extends ConsumerWidget {
  const InvestmentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final draft = ref.watch(investmentFlowProvider);
    final id = draft.orderId;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.page),
          child: Column(
            children: [
              const Spacer(),
              Icon(
                Icons.check_circle_outline_rounded,
                size: 56,
                color: c.success,
              ),
              const SizedBox(height: Space.s4),
              Text(
                'درخواست ثبت شد',
                style: context.text.h2.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: Space.s2),
              Text(
                'این یک سفارش در انتظار فعال‌سازی است، نه سرمایه‌گذاری قطعی.',
                textAlign: TextAlign.center,
                style: context.text.bodySmall.copyWith(color: c.textSecondary),
              ),
              if (id != null && id.isNotEmpty) ...[
                const SizedBox(height: Space.s3),
                Text(
                  'شناسه سفارش: ${Fmt.fa(id)}',
                  style: context.text.caption.copyWith(color: c.textMuted),
                ),
              ],
              const SizedBox(height: Space.s4),
              const NoticeBanner(
                message:
                    'وضعیت نامشخص هرگز به‌عنوان ناموفق نمایش داده نمی‌شود.',
                tone: NoticeTone.info,
              ),
              const Spacer(),
              PishroButton(
                label: 'سرمایه‌گذاری‌های من',
                onPressed: () => context.go(Routes.activeInvestments),
              ),
              const SizedBox(height: Space.s3),
              PishroButton(
                label: 'بازگشت به خانه',
                variant: PishroButtonVariant.secondary,
                onPressed: () => context.go(Routes.investment),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
