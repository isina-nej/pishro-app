import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/providers/app_preferences_provider.dart';
import '../../../../shared/providers/session_provider.dart';
import '../../../../shared/widgets/states.dart';
import '../widgets/brand_mark.dart';

/// ۰۱ · شروع — Screen/Auth/Splash.
///
/// Resolves the stored session, then routes: «نشست معتبر → Courses/Home ·
/// بدون نشست → Welcome». The deck caps the wait at three seconds and falls
/// back to the network-error state, and forbids a bouncy animation
/// («بدون انیمیشن پرشی · احترام به reduced-motion»).
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const _maxWait = Duration(seconds: 3);

  Timer? _timeout;
  bool _timedOut = false;

  @override
  void initState() {
    super.initState();
    _arm();
  }

  void _arm() {
    _timeout?.cancel();
    _timeout = Timer(_maxWait, () {
      if (mounted) setState(() => _timedOut = true);
    });
  }

  /// Routes once the stored session is known: «نشست معتبر → Courses/Home ·
  /// بدون نشست → Welcome». Safe to call more than once — the first call
  /// navigates away and the timer is already cancelled.
  void _resolve(SessionState session) {
    if (!session.isResolved || !mounted) return;
    _timeout?.cancel();
    final target = session.isAuthenticated
        ? Routes.homeAfterLogin
        : Routes.welcome;
    // Navigating during build is not allowed; defer to the end of the frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go(target);
    });
  }

  @override
  void dispose() {
    _timeout?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // `listen` only reports *changes*. The notifier is created by the router
    // before this screen builds, so a fast token read can land first and no
    // event ever arrives — hence the same handler on the current value too.
    ref.listen(sessionProvider, (_, next) => _resolve(next));
    _resolve(ref.read(sessionProvider));

    final c = context.colors;

    return Scaffold(
      body: SafeArea(
        child: _timedOut
            ? ErrorStateView(
                onRetry: () {
                  setState(() => _timedOut = false);
                  _arm();
                  ref.invalidate(sessionProvider);
                },
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  const Center(child: BrandMark(size: 96)),
                  Positioned(
                    bottom: Space.s16 + Space.s5,
                    child: Column(
                      children: [
                        _PulsingDots(
                          stillness: ref
                              .watch(appPreferencesProvider)
                              .reduceMotion,
                        ),
                        const SizedBox(height: Space.s4 + 2),
                        Text(
                          'v1.0.0',
                          style: context.text.micro.copyWith(
                            color: c.textMuted,
                            fontFamily: AppFonts.latin,
                          ),
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

/// Three 7px dots fading in sequence. Held still when the platform asks for
/// reduced motion.
class _PulsingDots extends StatefulWidget {
  const _PulsingDots({required this.stillness});

  /// The user's own «کاهش انیمیشن» switch, on top of the platform flag.
  final bool stillness;

  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _applyMotionSetting();
  }

  @override
  void didUpdateWidget(covariant _PulsingDots oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stillness != widget.stillness) _applyMotionSetting();
  }

  void _applyMotionSetting() {
    if (widget.stillness || MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) const SizedBox(width: 7),
            Opacity(
              opacity: _controller.isAnimating
                  ? 0.35 + 0.65 * _wave((_controller.value + i * 0.15) % 1)
                  : 1,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: c.actionPrimary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 0 → 1 → 0, no overshoot: the deck bans a bouncy curve.
  static double _wave(double t) => t < 0.5 ? t * 2 : (1 - t) * 2;
}
