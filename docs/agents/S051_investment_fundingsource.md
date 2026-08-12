# Agent S051 — Screen/Investment/FundingSource

## Mission
Implement **exactly one** mobile screen from the Pishro design deck as a Flutter widget for **Android**.

| Field | Value |
|---|---|
| Agent ID | `S051` |
| Design path | `Screen/Investment/FundingSource` |
| Persian title | منبع تأمین وجه |
| Deck file | `../desighn/_capture/07-06-investment-part-2.dc.html` |
| Own file (ONLY write here) | `lib/features/investment/presentation/screens/funding_source_screen.dart` |
| Module | `investment` |
| Note from deck | — |

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
" ../desighn/_capture/07-06-investment-part-2.dc.html
```
2. Locate the block for `Screen/Investment/FundingSource` / «منبع تأمین وجه».
3. Grep raw HTML for inline `style=` hex and px of that block — copy exact values into semantic tokens if missing (prefer existing `AppColors` slots; only add a slot if truly absent — but **do not edit theme files**; map to nearest semantic slot and leave a `// TODO(token):` if mismatch > trivial).
4. List reusable shared widgets you will use (`PishroButton`, `PishroTextField`, `PishroCard`, `SectionHeader`, `MarketDelta`, `RiskBadge`, `Skeleton`, `EmptyState`, `ErrorStateView`, `PagePadding`, module widgets).

### Phase 2 — Scaffold
1. Create `lib/features/investment/presentation/screens/funding_source_screen.dart` (and directory if needed).
2. Header doc comment:
   `/// Screen/Investment/FundingSource — «منبع تأمین وجه».`
3. Public widget: `class ... extends ConsumerWidget` or `ConsumerStatefulWidget` as required.
4. Use `context.colors` / `context.text` / `Space.*` / `Radii.*` / `Layout.*` only.

### Phase 3 — Pixel UI (Android 390dp)
1. Compose the first viewport to match the deck: app bar, body sections, CTAs, bottom insets.
2. Wire tappable elements with `context.push(Routes....)` using **existing** paths in `lib/routing/routes.dart` only.
3. Implement loading/empty/error if the deck shows those states for this screen.
4. Persian copy must match the deck (do not rewrite marketing text).

### Phase 4 — Data
1. Prefer existing repositories/providers in `lib/features/investment/`.
2. If Community or mock Account slice: use mock implementations behind providers (`AppConfig.useMockForMissingApis`).
3. Never call Dio directly from the widget — always repository/provider.

### Phase 5 — Verify
```bash
dart format lib/features/investment/presentation/screens/funding_source_screen.dart
flutter analyze lib/features/investment/presentation/screens/funding_source_screen.dart
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
- ۰۳ · منبع تأمین وجه
- Screen/Investment/FundingSource
- مرور نهایی سرمایه‌گذاری
- طرح
- دریافت ماهیانه ۸٪
- مبلغ سرمایه‌گذاری
- ۵۰٬۰۰۰٬۰۰۰ تومان
- ویرایش
- منبع تأمین وجه
- کیف پول داخلی
- تغییر
- نرخ اعلام‌شده
- ۸٪ ماهیانه
- برآورد پرداخت ماهانه
- ۴٬۰۰۰٬۰۰۰ تومان
- کارمزد
- ۰ تومان
- سطح ریسک
- متوسط
- نرخ اعلام‌شده به معنای تضمین پرداخت نیست. تمامی مقادیر برآورد است.
- مشاهده ریسک‌ها
- مشاهده قرارداد
- ادامه برای تأیید قرارداد
- ۰۴ · مرور نهایی
- Screen/Investment/FinalReview
- 06_INVESTMENT
- صفحه ۰۵–۰۸
- تأیید قرارداد
- قرارداد طرح دریافت ماهیانه ۸٪ — نسخه ۱٫۲
- کاربر: نام کاربر نمونه · مبلغ: ۵۰٬۰۰۰٬۰۰۰ تومان
- دانلود قرارداد

## Definition of Done checklist
- [ ] File exists at owned path
- [ ] Matches deck structure & Persian labels
- [ ] Semantic colors only
- [ ] Analyzer clean on owned file
- [ ] Formatted
