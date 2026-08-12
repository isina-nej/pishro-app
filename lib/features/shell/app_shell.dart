import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/bottom_nav.dart';

/// Hosts the five tab branches. Each branch keeps its own Navigator, which is
/// how «وضعیت هر تب هنگام جابه‌جایی حفظ می‌شود» is satisfied.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    // When the keyboard is up the nav bar would eat half the remaining screen,
    // so it follows the platform convention and hides (Frame 07).
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: keyboardOpen
          ? null
          : PishroBottomNav(
              currentIndex: navigationShell.currentIndex,
              onSelected: (i) => navigationShell.goBranch(
                i,
                // Tapping the active tab returns it to its root.
                initialLocation: i == navigationShell.currentIndex,
              ),
            ),
    );
  }
}

/// Temporary stand-in so the shell is runnable before a module lands.
/// Module agents delete these as they implement the real screens.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(child: Text(title)),
  );
}
