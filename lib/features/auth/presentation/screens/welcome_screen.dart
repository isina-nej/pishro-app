import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/brand_mark.dart';

/// ۰۲ · خوش‌آمد — Screen/Auth/Welcome.
///
/// «بدون ناوبری پایین · اقدام اصلی چسبیده به پایین». «ورود به‌عنوان مهمان» is
/// dropped: the deck makes it conditional on business rules and the backend has
/// no guest session.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const _features = [
    (Icons.menu_book_outlined, 'دوره‌های عادی و VIP'),
    (Icons.bar_chart_rounded, 'داده زنده بازار و تحلیل کاربران'),
    (Icons.trending_up_rounded, 'بررسی شفاف طرح‌های سرمایه‌گذاری'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AuthScaffold.gutter,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: Space.s5),
              const Align(
                alignment: AlignmentDirectional.centerStart,
                child: BrandMark(size: 52, axis: Axis.horizontal),
              ),
              const SizedBox(height: Space.s8 + 2),
              Text(
                'آموزش، تحلیل و سرمایه‌گذاری در یک مسیر حرفه‌ای',
                style: context.text.displaySmall.copyWith(
                  color: c.textPrimary,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: Space.s4),
              Text(
                'از دوره‌های تخصصی تا داده‌های بازار و تحلیل کارشناسان، '
                'همه‌چیز را یک‌جا دنبال کنید.',
                style: context.text.bodyLarge.copyWith(
                  color: c.textSecondary,
                  fontSize: 15,
                  height: 2,
                ),
              ),
              const SizedBox(height: Space.s6 + 4),
              for (final (icon, label) in _features) ...[
                _FeatureRow(icon: icon, label: label),
                const SizedBox(height: Space.s2 + 2),
              ],
              const Spacer(),
              PishroButton(
                label: 'ورود',
                onPressed: () => context.go(Routes.login),
              ),
              const SizedBox(height: Space.s3),
              PishroButton(
                label: 'ساخت حساب',
                variant: PishroButtonVariant.secondary,
                // Flow A: Welcome → Onboarding-01 → … → Signup.
                onPressed: () => context.go(Routes.onboarding),
              ),
              const SizedBox(height: Space.s3),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Space.s4 - 1,
        vertical: Space.s3 + 2,
      ),
      decoration: BoxDecoration(
        color: c.surfacePrimary,
        borderRadius: BorderRadius.circular(Radii.lg - 2),
        border: Border.all(color: c.borderDefault),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: c.surfaceSecondary,
              borderRadius: BorderRadius.circular(Radii.md - 1),
              border: Border.all(color: c.borderDefault),
            ),
            child: Icon(icon, size: 20, color: c.actionPrimary),
          ),
          const SizedBox(width: Space.s3),
          Expanded(
            child: Text(
              label,
              style: context.text.bodyMedium.copyWith(color: c.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
