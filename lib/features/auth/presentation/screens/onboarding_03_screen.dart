import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/pishro_badge.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/onboarding_dots.dart';

/// Screen/Auth/Onboarding-03 — «آشنایی ۳».
///
/// Final onboarding slide (۳ / ۳). Prototype: «شروع» and «رد کردن» both go to
/// Signup; swipe between slides is owned by the pager wiring (Coordinator).
class Onboarding03Screen extends StatelessWidget {
  const Onboarding03Screen({super.key});

  void _toSignup(BuildContext context) => context.go(Routes.signup);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return AuthScaffold(
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const OnboardingDots(count: 3, index: 2),
          const SizedBox(height: Space.s5),
          PishroButton(label: 'شروع', onPressed: () => _toSignup(context)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: InkWell(
              onTap: () => _toSignup(context),
              borderRadius: BorderRadius.circular(Radii.sm),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: Layout.minTapTarget,
                  minHeight: Layout.minTapTarget,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Space.s3),
                  child: Center(
                    child: Text(
                      'رد کردن',
                      style: context.text.bodyMedium.copyWith(
                        color: c.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: Space.s2),
          const _InvestmentPreview(),
          const SizedBox(height: Space.s6 - 2),
          Text(
            'سرمایه‌گذاری آگاهانه',
            style: context.text.displaySmall.copyWith(
              color: c.textPrimary,
              fontSize: 26,
              height: 1.55,
            ),
          ),
          const SizedBox(height: Space.s3 + 2),
          Text(
            'طرح‌ها، شرایط، ریسک‌ها و سوابق سرمایه‌گذاری خود را شفاف بررسی کنید.',
            style: context.text.bodyLarge.copyWith(
              color: c.textSecondary,
              fontSize: 15,
              height: 2,
            ),
          ),
          const SizedBox(height: Space.s4),
        ],
      ),
    );
  }
}

/// Deck illustration panel — two sample plans + risk notice (not live data).
class _InvestmentPreview extends StatelessWidget {
  const _InvestmentPreview();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      height: 320,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.surfacePrimary,
        borderRadius: BorderRadius.circular(Radii.xl),
        border: Border.all(color: c.borderDefault),
      ),
      // The deck fixes this panel at 320. Sample content plus Persian line
      // heights overran it by 16px on a Pixel, so the panel keeps its size and
      // the content scales down to fit instead — no clipped risk notice, and
      // no growth that would push the slide's own copy off screen.
      child: LayoutBuilder(
        builder: (context, box) => FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.topCenter,
          child: SizedBox(width: box.maxWidth, child: _panelContent(context)),
        ),
      ),
    );
  }

  Widget _panelContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _PlanCard(
          title: 'طرح دریافت ماهیانه ۸٪',
          risk: RiskLevel.medium,
          rows: [
            ('مدت', 'طبق شرایط قرارداد'),
            ('حداقل مبلغ', 'اطلاعات تکمیلی طرح'),
          ],
        ),
        const SizedBox(height: Space.s3),
        const _PlanCard(
          title: 'طرح هولد با سود داینامیک',
          risk: RiskLevel.high,
          body: 'بازدهی داینامیک است و می‌تواند افزایش یا کاهش یابد.',
        ),
        const SizedBox(height: Space.s3),
        const _RiskNotice(),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.risk,
    this.rows = const [],
    this.body,
  });

  final String title;
  final RiskLevel risk;
  final List<(String, String)> rows;
  final String? body;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        // TODO(token): deck inner card #14181D (n850) — nearest surfaceSecondary
        color: c.surfaceSecondary,
        borderRadius: BorderRadius.circular(Radii.lg - 2),
        border: Border.all(color: c.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: context.text.bodySmall.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: Space.s2),
              RiskBadge(risk),
            ],
          ),
          if (rows.isNotEmpty) ...[
            const SizedBox(height: Space.s2 + 2),
            for (final (label, value) in rows) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: Space.s1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: context.text.micro.copyWith(color: c.textMuted),
                    ),
                    Flexible(
                      child: Text(
                        value,
                        textAlign: TextAlign.start,
                        style: context.text.micro.copyWith(
                          color: c.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
          if (body != null) ...[
            const SizedBox(height: Space.s2 + 2),
            Text(
              body!,
              style: context.text.micro.copyWith(
                color: c.textMuted,
                height: 1.85,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RiskNotice extends StatelessWidget {
  const _RiskNotice();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      padding: const EdgeInsets.all(Space.s3),
      decoration: BoxDecoration(
        color: c.warning.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: c.warning.withValues(alpha: 0.24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(Icons.warning_amber_rounded, size: 18, color: c.warning),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'سرمایه‌گذاری همراه با ریسک است. شرایط و قرارداد هر طرح را مطالعه کنید.',
              // TODO(token): deck notice text #E7DCC4 — nearest textSecondary
              style: context.text.micro.copyWith(
                color: c.textSecondary,
                height: 1.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
