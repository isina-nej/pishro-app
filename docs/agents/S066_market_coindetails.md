# Agent S066 — Screen/Market/CoinDetails

## Mission
Implement **exactly one** mobile screen from the Pishro design deck as a Flutter widget for **Android**.

| Field | Value |
|---|---|
| Agent ID | `S066` |
| Design path | `Screen/Market/CoinDetails` |
| Persian title | جزئیات ارز |
| Deck file | `../desighn/_capture/08-07-market.dc.html` |
| Own file (ONLY write here) | `lib/features/market/presentation/screens/coin_details_screen.dart` |
| Module | `market` |
| Note from deck | بدون دکمه خرید/فروش |

## Your private plan (execute in order)

### Phase 1 — Extract (do not code yet)
1. Run text extraction on the deck:
```bash
python3 -c "
import re,html,sys
s=open(sys.argv[1],encoding='utf-8').read()
t=re.sub(r'<(script|style)[^>]*>.*?</\1>','',s,flags=re.S)
t=re.sub(r'<[^>]+>','\n',t)
print('\n'.join(l.strip() for l in html.unescape(t).split('\n') if l.strip()))
" ../desighn/_capture/08-07-market.dc.html
```
2. Locate the block for `Screen/Market/CoinDetails` / «جزئیات ارز».
3. Grep raw HTML for inline `style=` hex and px of that block — copy exact values into semantic tokens if missing (prefer existing `AppColors` slots; only add a slot if truly absent — but **do not edit theme files**; map to nearest semantic slot and leave a `// TODO(token):` if mismatch > trivial).
4. List reusable shared widgets you will use (`PishroButton`, `PishroTextField`, `PishroCard`, `SectionHeader`, `MarketDelta`, `RiskBadge`, `Skeleton`, `EmptyState`, `ErrorStateView`, `PagePadding`, module widgets).

### Phase 2 — Scaffold
1. Create `lib/features/market/presentation/screens/coin_details_screen.dart` (and directory if needed).
2. Header doc comment:
   `/// Screen/Market/CoinDetails — «جزئیات ارز».`
3. Public widget: `class ... extends ConsumerWidget` or `ConsumerStatefulWidget` as required.
4. Use `context.colors` / `context.text` / `Space.*` / `Radii.*` / `Layout.*` only.

### Phase 3 — Pixel UI (Android 390dp)
1. Compose the first viewport to match the deck: app bar, body sections, CTAs, bottom insets.
2. Wire tappable elements with `context.push(Routes....)` using **existing** paths in `lib/routing/routes.dart` only.
3. Implement loading/empty/error if the deck shows those states for this screen.
4. Persian copy must match the deck (do not rewrite marketing text).

### Phase 4 — Data
1. Prefer existing repositories/providers in `lib/features/market/`.
2. If Community or mock Account slice: use mock implementations behind providers (`AppConfig.useMockForMissingApis`).
3. Never call Dio directly from the widget — always repository/provider.

### Phase 5 — Verify
```bash
dart format lib/features/market/presentation/screens/coin_details_screen.dart
flutter analyze lib/features/market/presentation/screens/coin_details_screen.dart
```
Fix issues in **your file only**.

### Phase 6 — Hand-off
- Do **not** commit, push, or edit router.
- Leave a short summary: files touched, Routes used, known gaps vs deck.

## Hard rules
- ❌ Edit `app_router.dart`, `routes.dart`, other screens, pubspec, theme tokens (unless Coordinator).
- ❌ Invent pages, tabs, or FAB.
- ❌ Purple gradients / gold as general accent / colour-only status.
- ✅ RTL, Vazirmatn via theme, 44×44 targets, Android-first.

## Deck excerpt (starting point — verify against full file)
- 42B33; color: #D9DEE3; font-size: 11px; padding: 10px; border-radius: 8px; min-height: 40px;">هشدار قیمت
- ۰۸ · جزئیات ارز
- Screen/Market/CoinDetails · بدون دکمه خرید/فروش
- 07_MARKET
- صفحه ۰۹–۱۲
- Bitcoin — BTC
- ۳٬۴۲۰٬۰۰۰٬۰۰۰
- +۲٫۴۸٪
- داده‌ها با تأخیر نمایش داده می‌شوند · به‌روزرسانی: ۲ دقیقه پیش
- ۶ تیر
- ۱۳ تیر
- ۲۰ تیر
- امروز
- بیشترین
- ۳٬۴۵۰٬۰۰۰٬۰۰۰
- کمترین
- ۳٬۳۶۰٬۰۰۰٬۰۰۰
- شروع دوره
- ۳٬۳۸۰٬۰۰۰٬۰۰۰
- ۱ ماه
- ۳ ماه
- همه
- در بازه انتخاب‌شده، قیمت از مقدار آغازین به مقدار پایانی تغییر کرده است.
- ۰۹ · نمودار قیمت
- Screen/Market/PriceChart
- آمار بازار — Bitcoin
- ارزش بازار
- ۶۷٬۰۰۰٬۰۰۰٬۰۰۰٬۰۰۰ تومان
- حجم ۲۴ ساعت
- ۲٬۸۰۰٬۰۰۰٬۰۰۰٬۰۰۰ تومان
- عرضه در گردش
- ۱۹٬۷۰۰٬۰۰۰ BTC
- حداکثر عرضه
- ۲۱٬۰۰۰٬۰۰۰ BTC
- بیشترین قیمت روز
- <span style="font-family: Inter, sans-serif; font-size: 12px; co

## Definition of Done checklist
- [ ] File exists at owned path
- [ ] Matches deck structure & Persian labels
- [ ] Semantic colors only
- [ ] Analyzer clean on owned file
- [ ] Formatted
