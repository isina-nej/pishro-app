# پیشرو سرمایه — pishro_app

کلاینت Flutter (Android-first، RTL فارسی) برای پلتفرم آموزش و سرمایه‌گذاری پیشرو سرمایه.

- **GitHub:** https://github.com/isina-nej/pishro-app
- **طراحی:** `../desighn/_capture/` (منبع حقیقت UI)
- **بک‌اند:** `../../pishro` (Next.js API)
- **پلن اجرا:** [`docs/MASTER_PLAN.md`](docs/MASTER_PLAN.md)
- **فهرست صفحات:** [`docs/SCREEN_INVENTORY.json`](docs/SCREEN_INVENTORY.json) — ۱۰۸ صفحه (`S001`…`S108`)
- **بریف ایجنت‌ها:** [`docs/agents/`](docs/agents/)

## اجرا

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
```

## کیفیت

```bash
dart format lib test
flutter analyze
flutter test
```

## معماری

طبق `CLAUDE.md`: `core/` · `shared/` · `features/<module>/` · مسیرها در `lib/routing/routes.dart` · هر ماژول `*_routes.dart` خودش را export می‌کند.
