# Agent S102 — Screen/Account/Referrals

## Mission
Implement **exactly one** mobile screen from the Pishro design deck as a Flutter widget for **Android**.

| Field | Value |
|---|---|
| Agent ID | `S102` |
| Design path | `Screen/Account/Referrals` |
| Persian title | معرفی به دوستان |
| Deck file | `../desighn/_capture/11-09-account-part-2.dc.html` |
| Own file (ONLY write here) | `lib/features/account/presentation/screens/referrals_screen.dart` |
| Module | `account` |
| Note from deck | بدون درآمد تضمینی |

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
" ../desighn/_capture/11-09-account-part-2.dc.html
```
2. Locate the block for `Screen/Account/Referrals` / «معرفی به دوستان».
3. Grep raw HTML for inline `style=` hex and px of that block — copy exact values into semantic tokens if missing (prefer existing `AppColors` slots; only add a slot if truly absent — but **do not edit theme files**; map to nearest semantic slot and leave a `// TODO(token):` if mismatch > trivial).
4. List reusable shared widgets you will use (`PishroButton`, `PishroTextField`, `PishroCard`, `SectionHeader`, `MarketDelta`, `RiskBadge`, `Skeleton`, `EmptyState`, `ErrorStateView`, `PagePadding`, module widgets).

### Phase 2 — Scaffold
1. Create `lib/features/account/presentation/screens/referrals_screen.dart` (and directory if needed).
2. Header doc comment:
   `/// Screen/Account/Referrals — «معرفی به دوستان».`
3. Public widget: `class ... extends ConsumerWidget` or `ConsumerStatefulWidget` as required.
4. Use `context.colors` / `context.text` / `Space.*` / `Radii.*` / `Layout.*` only.

### Phase 3 — Pixel UI (Android 390dp)
1. Compose the first viewport to match the deck: app bar, body sections, CTAs, bottom insets.
2. Wire tappable elements with `context.push(Routes....)` using **existing** paths in `lib/routing/routes.dart` only.
3. Implement loading/empty/error if the deck shows those states for this screen.
4. Persian copy must match the deck (do not rewrite marketing text).

### Phase 4 — Data
1. Prefer existing repositories/providers in `lib/features/account/`.
2. If Community or mock Account slice: use mock implementations behind providers (`AppConfig.useMockForMissingApis`).
3. Never call Dio directly from the widget — always repository/provider.

### Phase 5 — Verify
```bash
dart format lib/features/account/presentation/screens/referrals_screen.dart
flutter analyze lib/features/account/presentation/screens/referrals_screen.dart
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
- r: #8D97A2; line-height: 1.8;">برای جلوگیری از سوءاستفاده، دعوت‌های مشکوک بررسی و ممکن است رد شوند.
- ۱۸ · معرفی به دوستان
- Screen/Account/Referrals · بدون درآمد تضمینی
- 09_ACCOUNT
- صفحه ۱۹–۲۰
- تنظیمات
- زبان
- فارسی
- حالت نمایش
- هماهنگ با دستگاه
- پخش خودکار ویدیو
- حالت کاهش مصرف داده
- بازه پیش‌فرض نمودار
- ۲۴ ساعت
- کاهش انیمیشن
- بازنشانی تنظیمات به حالت پیش‌فرض
- ۱۹ · تنظیمات
- Screen/Account/Preferences · بدون تغییر پالت RoyalGreen
- اسناد و قوانین
- قوانین و شرایط استفاده
- نسخه ۲٫۱ · ۱ تیر ۱۴۰۵
- پذیرفته‌شده
- شرایط طرح سرمایه‌گذاری و ریسک
- نسخه جدید نیازمند بررسی و تأیید است.
- سیاست حریم خصوصی
- نسخه ۱٫۴ · ۱۵ خرداد ۱۴۰۵
- پذیرفته‌شده
- قوانین کوین پیشرو
- نسخه ۱٫۰

## Definition of Done checklist
- [ ] File exists at owned path
- [ ] Matches deck structure & Persian labels
- [ ] Semantic colors only
- [ ] Analyzer clean on owned file
- [ ] Formatted
