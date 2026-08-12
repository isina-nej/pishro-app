import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/brand_mark.dart';

/// Screen/Auth/Welcome — «خوش‌آمد».
///
/// Deck: no bottom nav · primary actions pinned with ۱۲px safe inset.
/// «ورود به‌عنوان مهمان» is omitted — business rules / backend have no guest
/// session, and the router redirects signed-out users off tab roots.
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
      backgroundColor: c.backgroundApp,
      body: Stack(
        children: [
          // Soft brand glow — deck radial at top-inline-end.
          PositionedDirectional(
            top: -60,
            end: -80,
            child: IgnorePointer(
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      c.actionPrimary.withValues(alpha: 0.14),
                      c.actionPrimary.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
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
                  // Deck: margin-top 34px under brand row.
                  const SizedBox(height: Space.s8 + 2),
                  Text(
                    'آموزش، تحلیل و سرمایه‌گذاری در یک مسیر حرفه‌ای',
                    style: context.text.displaySmall.copyWith(
                      color: c.textPrimary,
                      height: 1.55,
                    ),
                  ),
                  // Deck: 16px gap between title and body.
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
                  // Deck: margin-top 28px before feature list.
                  const SizedBox(height: Space.s6 + 4),
                  for (var i = 0; i < _features.length; i++) ...[
                    if (i > 0) const SizedBox(height: Space.s2 + 2),
                    _FeatureRow(icon: _features[i].$1, label: _features[i].$2),
                  ],
                  const Spacer(),
                  // Pinned CTAs — gap 12px, bottom inset ۱۲px + gesture bar.
                  PishroButton(
                    label: 'ورود',
                    onPressed: () => context.push(Routes.login),
                  ),
                  const SizedBox(height: Space.s3),
                  // Deck secondary is green outline (borderActive), not the
                  // shared neutral secondary — match Welcome frame locally.
                  _SignupOutlineButton(
                    onPressed: () => context.push(Routes.onboarding),
                  ),
                  const SizedBox(height: Space.s3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// «ساخت حساب» — outlined RoyalGreen per Welcome frame (not shared secondary).
class _SignupOutlineButton extends StatelessWidget {
  const _SignupOutlineButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: 'ساخت حساب',
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(Radii.button),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(Radii.button),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Radii.button),
                border: Border.all(color: c.borderActive),
              ),
              child: Center(
                child: Text(
                  'ساخت حساب',
                  style: context.text.bodyLarge.copyWith(
                    color: c.actionPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
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
    // Deck: radius 14 · padding 14×15 · icon tile 38 / radius 11.
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
              // Deck dark #D9DEE3 / light #142119 → nearest: textPrimary.
              // TODO(token): dark feature label is Neutral.n200, not n100.
              style: context.text.bodyMedium.copyWith(color: c.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
