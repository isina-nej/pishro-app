import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';

/// The «OFFICIAL LOGO SLOT» of Splash and Welcome, plus the wordmark under it.
///
/// The deck ships a slot rather than artwork and `assets/images/` is still
/// empty, so the slot is what renders until the logo lands — swapping in an
/// `Image.asset` here is the only change needed.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 96, this.axis = Axis.vertical});

  final double size;

  /// Vertical on Splash, horizontal on the Welcome header.
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final vertical = axis == Axis.vertical;

    final slot = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: c.surfacePrimary,
        borderRadius: BorderRadius.circular(size * 0.27),
        border: Border.all(color: c.borderActive),
      ),
      alignment: Alignment.center,
      child: Text(
        vertical ? 'OFFICIAL\nLOGO\nSLOT' : 'LOGO\nSLOT',
        textAlign: TextAlign.center,
        style: context.text.micro.copyWith(
          fontFamily: AppFonts.latin,
          fontSize: vertical ? 10 : 8,
          height: 1.4,
          color: c.actionPrimary,
        ),
      ),
    );

    final wordmark = Column(
      crossAxisAlignment: vertical
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'پیشرو سرمایه',
          style: (vertical ? context.text.displaySmall : context.text.h3)
              .copyWith(
                color: c.textPrimary,
                fontSize: vertical ? 26 : 17,
                fontWeight: FontWeight.w700,
              ),
        ),
        SizedBox(height: vertical ? Space.s2 : 2),
        Text(
          'PISHRO SARMAYE',
          style: context.text.micro.copyWith(
            fontFamily: AppFonts.latin,
            fontSize: vertical ? 11 : 10,
            // Latin only — Persian is never letter-spaced.
            letterSpacing: vertical ? 1.76 : 1,
            color: c.textMuted,
          ),
        ),
      ],
    );

    return vertical
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              slot,
              const SizedBox(height: Space.s5 + 2),
              wordmark,
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              slot,
              const SizedBox(width: Space.s3 + 1),
              wordmark,
            ],
          );
  }
}
