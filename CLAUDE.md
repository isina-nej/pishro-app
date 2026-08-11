# CLAUDE.md — pishro_app

Flutter client for پیشرو سرمایه (Pishro Sarmaye): a Persian, RTL, mobile-first
education + investment platform. Backend is the Next.js app at
`../../pishro` (github `isina-nej/pishro`).

## Commands

```bash
flutter analyze          # must be clean before you consider a task done
flutter test             # must pass
dart format lib test     # run before finishing
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
```

## Source of truth for design

The decks live in `../desighn/_capture/*.html` — inline-styled HTML, one file
per module. Read them; do not invent layout. Extract a deck's text with:

```bash
python3 -c "
import re,html,sys
s=open(sys.argv[1],encoding='utf-8').read()
t=re.sub(r'<(script|style)[^>]*>.*?</\1>','',s,flags=re.S)
t=re.sub(r'<[^>]+>','\n',t)
print('\n'.join(l.strip() for l in html.unescape(t).split('\n') if l.strip()))
" ../desighn/_capture/05-05-news.dc.html
```

Colours/sizes are inline `style=` attributes — grep the raw HTML for the exact
hex and px values of a given block rather than eyeballing.

## Non-negotiable design rules (from Foundations)

- **RTL always.** Persian text right-aligned. Never letter-space Persian, never
  uppercase it, never compress lines.
- **Never colour alone.** Price direction, risk level and status must always
  carry an icon/arrow *and* a text label. `MarketDelta` and `RiskBadge` already
  do this — use them.
- **Gold (`colors.premium`) is for VIP badges, Pishro Coin and certificates
  only.** It is not a general accent and never appears as text on a light
  surface.
- **Persian digits in prose, Latin in tickers.** Use `Fmt.fa` / `Fmt.toman` /
  `Fmt.grouped`. Normalise user input with `Fmt.toAscii` before it hits the API.
- **Dark is the default theme.** Every screen must render correctly in both.
- Depth comes from tonal difference + a hairline border, not heavy shadows.
- Minimum tap target 44×44 (WCAG 2.2 AA).
- No home tab, no centre FAB. Five destinations, fixed order.

## Layers

```
lib/
  core/
    config/app_config.dart      API base URL, mock toggle
    network/api_client.dart     Dio + JSend unwrapping  -> throws ApiException
    network/api_exception.dart  NetworkException | UnauthorizedException | ...
    storage/token_storage.dart  secure storage for bearer tokens
    theme/                      tokens.dart · app_colors.dart · app_typography.dart
    utils/formatters.dart       Fmt.*
  routing/routes.dart           EVERY path string lives here
  shared/widgets/               the component library — reuse, don't re-create
  shared/providers/             sessionProvider, themeModeProvider
  features/<module>/
    data/       models + repository (+ mock repository where no API exists)
    presentation/screens/       one file per screen
    presentation/widgets/       widgets used only by this module
    <module>_routes.dart        exports `List<RouteBase> <module>Routes`
```

## Theme access

```dart
final c = context.colors;   // AppColors  — semantic only
final t = context.text;     // AppTextStyles
```

Never reference `Neutral.*` / `Gold.*` primitives from a widget, and never
hardcode a hex. If a deck colour has no semantic slot, add one to `AppColors`
(both palettes) rather than inlining it.

## Existing components — reuse these

`PishroButton` (primary/secondary/ghost/danger/premium, `loading` blocks
re-submit) · `PishroTextField` (+`.phone()` `.amount()` factories) ·
`PishroBadge` (`.vip()` `.regular()` `.verified()` `.sampleData()`) ·
`RiskBadge` · `PishroChip` / `PishroChipBar` · `PishroCard` · `SectionHeader` ·
`MarketDelta` · `PishroProgress` · `Skeleton` (`.line` `.box` `.cover`) ·
`EmptyState` · `ErrorStateView` · `NoticeBanner` · `PagePadding`.

## Networking

```dart
final api = ref.read(apiClientProvider);
final data = await api.get<Map<String, dynamic>>('/courses');
```

`ApiClient` already unwraps the backend's JSend envelope (`{status, data,
message}`) and maps failures to typed `ApiException`s. Repositories translate
JSON to models and let `ApiException` propagate; screens render
`ErrorStateView` for `NetworkException` and re-auth for `UnauthorizedException`.

`ValidationException.fieldErrors` maps a field name to its message — feed it
straight into `PishroTextField.errorText`.

## Routing contract (avoids cross-agent conflicts)

Each module exports its own routes and **does not edit `app_router.dart`**:

```dart
// lib/features/news/news_routes.dart
final List<RouteBase> newsRoutes = [
  GoRoute(path: Routes.newsTrending, builder: (_, __) => const TrendingScreen()),
  ...
];
```

Add any new path to `lib/routing/routes.dart` under your module's section only.

## State

Riverpod. Prefer `AsyncNotifierProvider` / `FutureProvider` for server data and
`StateNotifierProvider` for form/flow state. Do not snapshot server entities
into long-lived client state — refetch instead.

## Modules with no backend

`AppConfig.useMockForMissingApis` is true by default. Community (all of it) and
the KYC / Pishro Coin / devices / referrals / notifications slice of Account
have no endpoints. Define the repository as an abstract interface, ship a mock
implementation, and pick between them in the provider — so swapping in the real
API later is a one-line change.

## Deck ↔ API map

| Module | Endpoints |
|---|---|
| Auth | `/auth/login` `/auth/signup` `/auth/send-sms-otp` `/otp/send` `/otp/verify` `/auth/forgot-password/*` |
| Courses | `/courses` `/courses/free-enroll` `/user/enrolled-courses` `/user/enrollment` `/video/token` `/user/lessons/{id}/stream` `/quiz/*` |
| Checkout | `/cart` `/checkout` `/payment/verify` `/user/orders` `/user/pay` |
| News | `/news` `/news/{slug}` `/comments` `/user/bookmarks` |
| Investment | `/investment-models` `/investment-funds` `/landing/investment-plans` `/cart/add-portfolio` |
| Market | `/public/crypto-market` `/public/crypto-market/{id}` |
| Community | **none — mock** |
| Account | `/user/me` `/user/personal` `/user/orders` `/user/transactions` `/user/bookmarks` `/user/avatar` `/auth/change-password`; KYC/coin/devices/referrals **mock** |

Verify a response shape against the handler in `../../pishro/app/api/...`
before writing a model — several handlers bypass the envelope.
