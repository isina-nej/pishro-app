import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/onboarding_dots.dart';

/// Screen/Auth/Onboarding-01 — «آشنایی ۱».
///
/// Slide ۱ / ۳ of Flow A (آموزش‌های تخصصی). «رد کردن» jumps to Signup;
/// «ادامه» advances to Onboarding-02 (بازار و تحلیل).
class Onboarding01Screen extends StatelessWidget {
  const Onboarding01Screen({super.key});

  static const _slideIndex = 0;
  static const _slideCount = 3;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 52,
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(end: Space.s3),
                  child: InkWell(
                    onTap: () => context.go(Routes.signup),
                    borderRadius: BorderRadius.circular(Radii.md),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: Layout.minTapTarget,
                        minHeight: Layout.minTapTarget,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Space.s3,
                        ),
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
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AuthScaffold.gutter,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Expanded(
                      child: Center(child: _CoursesIllustration()),
                    ),
                    const SizedBox(height: Space.s5),
                    Text(
                      'آموزش‌های تخصصی',
                      style: context.text.displaySmall.copyWith(
                        color: c.textPrimary,
                        fontSize: 26,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: Space.s3 + 2),
                    Text(
                      'دوره‌های عادی و VIP را متناسب با مسیر یادگیری خود '
                      'انتخاب کنید.',
                      style: context.text.bodyLarge.copyWith(
                        color: c.textSecondary,
                        fontSize: 15,
                        height: 2,
                      ),
                    ),
                    const SizedBox(height: Space.s2),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AuthScaffold.gutter,
                Space.s6,
                AuthScaffold.gutter,
                Space.s3,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const OnboardingDots(count: _slideCount, index: _slideIndex),
                  const SizedBox(height: Space.s5),
                  PishroButton(
                    label: 'ادامه',
                    onPressed: () => context.go(Routes.onboarding2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The deck ships slide ۱ with a placeholder illustration frame, not artwork:
/// a hatched panel holding an outlined mark and a mono caption.
class _CoursesIllustration extends StatelessWidget {
  const _CoursesIllustration();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: c.surfacePrimary,
        borderRadius: BorderRadius.circular(Radii.xl),
        border: Border.all(color: c.borderDefault),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: c.surfaceSecondary,
              borderRadius: BorderRadius.circular(Radii.xl),
              border: Border.all(color: c.actionPrimary),
            ),
            child: Icon(
              Icons.menu_book_outlined,
              size: 34,
              color: c.actionPrimary,
            ),
          ),
          const SizedBox(height: Space.s4 + 2),
          Text(
            'ILLUSTRATION · COURSES',
            style: context.text.micro.copyWith(
              fontFamily: AppFonts.latin,
              fontSize: 10,
              letterSpacing: 0.6,
              color: c.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
