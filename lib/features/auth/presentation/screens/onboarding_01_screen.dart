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

/// Screen/Auth/Onboarding-01 — «آشنایی ۱».
///
/// Slide ۲ / ۳ of Flow A (بازار و تحلیل). «رد کردن» jumps to Signup; «ادامه»
/// advances to Onboarding-02 once the Coordinator wires a dedicated path.
class Onboarding01Screen extends StatelessWidget {
  const Onboarding01Screen({super.key});

  static const _slideIndex = 1;
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
                    const Expanded(child: Center(child: _MarketIllustration())),
                    const SizedBox(height: Space.s5),
                    Text(
                      'بازار و تحلیل',
                      style: context.text.displaySmall.copyWith(
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

/// Sample market + analyst card from the deck illustration (not live data).
class _MarketIllustration extends StatelessWidget {
  const _MarketIllustration();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
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
                    // Deck: ۶۴,۷۵۱ — Persian digits; western comma in capture.
                    Fmt.fa('64,751'),
                    style: context.text.numeric.copyWith(
                      fontSize: 14,
                      height: 1.2,
                      color: c.textPrimary,
                    ),
                  ),
                  // Deck shows +۰٫۲٪ (one decimal); MarketDelta keeps arrow+label.
                  const MarketDelta(0.2, compact: true),
                ],
              ),
            ],
          ),
          const SizedBox(height: Space.s3 + 2),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Radii.md),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(painter: _HatchPainter(c)),
                  CustomPaint(painter: _SparklinePainter(c.marketUp)),
                  PositionedDirectional(
                    start: 10,
                    bottom: 8,
                    child: Text(
                      '۷ روز · داده نمونه',
                      style: context.text.micro.copyWith(
                        fontFamily: AppFonts.latin,
                        fontSize: 9,
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
              color: c.surfaceSecondary,
              borderRadius: BorderRadius.circular(Radii.md),
              border: Border.all(color: c.borderDefault),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: c.surfacePrimary,
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
                          Text(
                            '✓',
                            style: context.text.micro.copyWith(
                              fontSize: 9,
                              color: c.info,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'تحلیل تکنیکال · افق میان‌مدت',
                        style: context.text.micro.copyWith(
                          fontSize: 10,
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

class _HatchPainter extends CustomPainter {
  _HatchPainter(this.colors);

  final AppColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    final a = Paint()..color = colors.surfaceSecondary;
    final b = Paint()..color = colors.surfacePrimary;
    const stripe = 10.0;
    // Deck: repeating-linear-gradient(135deg, n800 0 10px, n850 10px 20px).
    for (var x = -size.height; x < size.width + size.height; x += stripe * 2) {
      final pathA = Path()
        ..moveTo(x, 0)
        ..lineTo(x + size.height, size.height)
        ..lineTo(x + size.height + stripe, size.height)
        ..lineTo(x + stripe, 0)
        ..close();
      canvas.drawPath(pathA, a);
      final pathB = Path()
        ..moveTo(x + stripe, 0)
        ..lineTo(x + stripe + size.height, size.height)
        ..lineTo(x + size.height + stripe * 2, size.height)
        ..lineTo(x + stripe * 2, 0)
        ..close();
      canvas.drawPath(pathB, b);
    }
  }

  @override
  bool shouldRepaint(covariant _HatchPainter oldDelegate) =>
      oldDelegate.colors != colors;
}

/// Sample sparkline matching the deck polyline (viewBox 300×130).
class _SparklinePainter extends CustomPainter {
  _SparklinePainter(this.color);

  final Color color;

  static const _points = <Offset>[
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

  @override
  void paint(Canvas canvas, Size size) {
    const vbW = 300.0;
    const vbH = 130.0;
    final path = Path();
    for (var i = 0; i < _points.length; i++) {
      final p = Offset(
        _points[i].dx / vbW * size.width,
        _points[i].dy / vbH * size.height,
      );
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.color != color;
}
