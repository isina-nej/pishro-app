import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/onboarding_dots.dart';

/// Screen/Auth/Onboarding-02 — «آشنایی ۲».
///
/// Deck frame `onb2`: sample market card + «بازار و تحلیل», pager ۲ / ۳, CTA ادامه.
/// Skip → Signup; ادامه targets Onboarding-03 (no dedicated [Routes] path yet).
class Onboarding02Screen extends StatelessWidget {
  const Onboarding02Screen({super.key});

  static const _slideIndex = 1;
  static const _slideCount = 3;

  void _skip(BuildContext context) => context.go(Routes.signup);

  void _continue(BuildContext context) => context.go(Routes.onboarding3);

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
                    onTap: () => _skip(context),
                    borderRadius: BorderRadius.circular(Radii.sm),
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
                    const Expanded(child: Center(child: _MarketPreviewCard())),
                    const SizedBox(height: Space.s3),
                    Text(
                      'بازار و تحلیل',
                      style: context.text.h1.copyWith(
                        color: c.textPrimary,
                        fontSize: 26,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: Space.s3 + 2),
                    Text(
                      'قیمت ارزها، داده‌های بازار و تحلیل کاربران حرفه‌ای را '
                      'دنبال کنید.',
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
                    onPressed: () => _continue(context),
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

/// Illustration block — BTC row, sample sparkline, sample analyst chip.
class _MarketPreviewCard extends StatelessWidget {
  const _MarketPreviewCard();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      width: double.infinity,
      height: 320,
      padding: const EdgeInsets.all(Space.s5),
      decoration: BoxDecoration(
        color: c.surfacePrimary,
        borderRadius: BorderRadius.circular(Radii.xl),
        border: Border.all(color: c.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.surfaceSecondary,
                  shape: BoxShape.circle,
                  border: Border.all(color: c.borderDefault),
                ),
                child: Text(
                  'BTC',
                  style: context.text.micro.copyWith(
                    fontFamily: AppFonts.latin,
                    fontSize: 9,
                    height: 1,
                    color: c.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: Space.s2 + 1),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'بیت‌کوین',
                      style: context.text.caption.copyWith(
                        color: c.textPrimary,
                      ),
                    ),
                    Text(
                      'BTC / USDT',
                      style: context.text.micro.copyWith(
                        fontFamily: AppFonts.latin,
                        fontSize: 9,
                        height: 1.2,
                        color: c.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Fmt.grouped(64751),
                    style: context.text.numeric.copyWith(
                      fontSize: 14,
                      height: 1.2,
                      color: c.textPrimary,
                    ),
                  ),
                  const MarketDelta(0.2, compact: true),
                ],
              ),
            ],
          ),
          const SizedBox(height: Space.s3 + 2),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: c.surfaceSecondary,
                borderRadius: BorderRadius.circular(Radii.md),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _SampleSparklinePainter(color: c.marketUp),
                    ),
                  ),
                  PositionedDirectional(
                    start: 10,
                    bottom: 8,
                    child: Text(
                      '۷ روز · داده نمونه',
                      style: context.text.micro.copyWith(
                        fontFamily: AppFonts.latin,
                        fontSize: 9,
                        height: 1.2,
                        color: c.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Space.s3 + 2),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Space.s3,
              vertical: Space.s2 + 2,
            ),
            decoration: BoxDecoration(
              // TODO(token): deck uses Neutral/850 (#14181D); surfacePrimary
              // is Neutral/900 (#101318) — nearest semantic slot.
              color: c.surfacePrimary,
              borderRadius: BorderRadius.circular(Radii.md),
              border: Border.all(color: c.borderDefault),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: c.surfaceSecondary,
                    shape: BoxShape.circle,
                    border: Border.all(color: c.borderDefault),
                  ),
                ),
                const SizedBox(width: Space.s2 + 1),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'تحلیلگر نمونه',
                            style: context.text.caption.copyWith(
                              color: c.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Icon(Icons.check_rounded, size: 12, color: c.info),
                        ],
                      ),
                      Text(
                        'تحلیل تکنیکال · افق میان‌مدت',
                        style: context.text.micro.copyWith(
                          fontSize: 10,
                          height: 1.4,
                          color: c.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'نمونه',
                  style: context.text.micro.copyWith(
                    fontFamily: AppFonts.latin,
                    fontSize: 9,
                    height: 1.2,
                    color: c.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SampleSparklinePainter extends CustomPainter {
  _SampleSparklinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Deck polyline viewBox 300×130 — scale to the paint area.
    const points = <Offset>[
      Offset(4, 104),
      Offset(34, 86),
      Offset(64, 94),
      Offset(94, 58),
      Offset(124, 72),
      Offset(154, 40),
      Offset(184, 52),
      Offset(214, 28),
      Offset(244, 38),
      Offset(296, 14),
    ];
    const vbW = 300.0;
    const vbH = 130.0;
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final p = Offset(
        points[i].dx / vbW * size.width,
        points[i].dy / vbH * size.height,
      );
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SampleSparklinePainter oldDelegate) =>
      oldDelegate.color != color;
}
