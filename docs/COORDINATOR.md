# Coordinator Playbook

Owns everything screen agents must **not** touch.

## Responsibilities
1. Wave 0: analyzer green, fonts committed, empty `*_routes.dart` stubs, shell placeholders replaced progressively.
2. After each wave’s agents finish: register their screens in `<module>_routes.dart` and merge into `app_router.dart` (or a single aggregator).
3. `dart format lib test` · `flutter analyze` · `flutter test`
4. Commit + **push to GitHub** after every wave (and after Wave 0).
5. Resolve merge conflicts; never rewrite an agent’s screen UI without cause.

## Router aggregation pattern
```dart
// lib/routing/app_router.dart
routes: [
  ...authRoutes,
  StatefulShellRoute.indexedStack(
    branches: [
      StatefulShellBranch(routes: coursesRoutes),
      StatefulShellBranch(routes: newsRoutes),
      // ...
    ],
  ),
],
```

Each module exports `final List<RouteBase> <module>Routes`.

## Push cadence
- After Wave 0 foundation
- After each Wave 1…8 completes wiring
- Hotfix: cherry-pick single screen commit if blocker

## Android verification
```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
```
Target: Android emulator / physical device. Design width 390 logical px.
