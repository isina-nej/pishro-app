import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';

/// Chrome shared by the four form screens of the Auth deck.
///
/// The deck's auth frames use a 24px gutter rather than the 16px of
/// [PagePadding], a 52px header whose back affordance is a 44×44 chevron
/// pointing to the reading direction, and a footer glued to the bottom with the
/// «فاصله ایمن ۱۲px» the Welcome spec note calls out.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.child,
    this.title,
    this.footer,
    this.onBack,
  });

  final Widget child;
  final String? title;

  /// Pinned above the gesture bar; rides up with the keyboard.
  final Widget? footer;

  final VoidCallback? onBack;

  /// The deck gutter for auth screens.
  static const gutter = Space.s6;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null)
              SizedBox(
                height: 52,
                child: Row(
                  children: [
                    const SizedBox(width: Space.s3),
                    if (onBack != null || context.canPop())
                      InkWell(
                        onTap: onBack ?? () => context.pop(),
                        borderRadius: BorderRadius.circular(Radii.md),
                        child: SizedBox(
                          width: Layout.minTapTarget,
                          height: Layout.minTapTarget,
                          child: Semantics(
                            button: true,
                            label: 'بازگشت',
                            // RTL: the deck draws the back chevron pointing
                            // towards the start of the line, i.e. to the right.
                            child: Icon(
                              Icons.chevron_right_rounded,
                              color: c.textSecondary,
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: Space.s1),
                    Expanded(
                      child: Text(
                        title!,
                        style: context.text.bodyLarge.copyWith(
                          color: c.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: Space.s3),
                  ],
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(gutter, Space.s3, gutter, 0),
                child: child,
              ),
            ),
            if (footer != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  gutter,
                  Space.s3,
                  gutter,
                  Space.s3,
                ),
                child: footer,
              ),
          ],
        ),
      ),
    );
  }
}

/// Title + supporting line — «خوش برگشتید» / «برای ادامه، وارد حساب خود شوید.»
class AuthHeadline extends StatelessWidget {
  const AuthHeadline({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.text.h2.copyWith(color: c.textPrimary)),
        if (subtitle != null) ...[
          const SizedBox(height: Space.s2),
          Text(
            subtitle!,
            style: context.text.bodyMedium.copyWith(color: c.textMuted),
          ),
        ],
      ],
    );
  }
}
