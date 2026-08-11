import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/tokens.dart';
import 'routing/app_router.dart';
import 'shared/providers/theme_provider.dart';

void main() {
  runApp(const ProviderScope(child: PishroApp()));
}

class PishroApp extends ConsumerWidget {
  const PishroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'پیشرو سرمایه',
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(routerProvider),

      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      // Dark is the product default, not the system's preference.
      themeMode: ref.watch(themeModeProvider),

      locale: const Locale('fa', 'IR'),
      supportedLocales: const [Locale('fa', 'IR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: _CenteredMobileColumn(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}

/// The design canvas is 390×844. On anything wider (tablet, desktop, a rotated
/// phone) the app renders as a centred column rather than stretching layouts
/// that were never designed to be wide.
class _CenteredMobileColumn extends StatelessWidget {
  const _CenteredMobileColumn({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width <= Layout.designWidth * 1.4) return child;

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: SizedBox(width: Layout.designWidth * 1.15, child: child),
      ),
    );
  }
}
