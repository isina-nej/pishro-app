# Agent S028 — Screen/Course/VIPInstructorChat

## Mission
Implement **exactly one** mobile screen from the Pishro design deck as a Flutter widget for **Android**.

| Field | Value |
|---|---|
| Agent ID | `S028` |
| Design path | `Screen/Course/VIPInstructorChat` |
| Persian title | گفت‌وگوی VIP |
| Deck file | `../desighn/_capture/04-04-courses-part-3.dc.html` |
| Own file (ONLY write here) | `lib/features/courses/presentation/screens/v_i_p_instructor_chat_screen.dart` |
| Module | `courses` |
| Note from deck | نشان VIP طلایی، بقیه سبز |

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
" ../desighn/_capture/04-04-courses-part-3.dc.html
```
2. Locate the block for `Screen/Course/VIPInstructorChat` / «گفت‌وگوی VIP».
3. Grep raw HTML for inline `style=` hex and px of that block — copy exact values into semantic tokens if missing (prefer existing `AppColors` slots; only add a slot if truly absent — but **do not edit theme files**; map to nearest semantic slot and leave a `// TODO(token):` if mismatch > trivial).
4. List reusable shared widgets you will use (`PishroButton`, `PishroTextField`, `PishroCard`, `SectionHeader`, `MarketDelta`, `RiskBadge`, `Skeleton`, `EmptyState`, `ErrorStateView`, `PagePadding`, module widgets).

### Phase 2 — Scaffold
1. Create `lib/features/courses/presentation/screens/v_i_p_instructor_chat_screen.dart` (and directory if needed).
2. Header doc comment:
   `/// Screen/Course/VIPInstructorChat — «گفت‌وگوی VIP».`
3. Public widget: `class ... extends ConsumerWidget` or `ConsumerStatefulWidget` as required.
4. Use `context.colors` / `context.text` / `Space.*` / `Radii.*` / `Layout.*` only.

### Phase 3 — Pixel UI (Android 390dp)
1. Compose the first viewport to match the deck: app bar, body sections, CTAs, bottom insets.
2. Wire tappable elements with `context.push(Routes....)` using **existing** paths in `lib/routing/routes.dart` only.
3. Implement loading/empty/error if the deck shows those states for this screen.
4. Persian copy must match the deck (do not rewrite marketing text).

### Phase 4 — Data
1. Prefer existing repositories/providers in `lib/features/courses/`.
2. If Community or mock Account slice: use mock implementations behind providers (`AppConfig.useMockForMissingApis`).
3. Never call Dio directly from the widget — always repository/provider.

### Phase 5 — Verify
```bash
dart format lib/features/courses/presentation/screens/v_i_p_instructor_chat_screen.dart
flutter analyze lib/features/courses/presentation/screens/v_i_p_instructor_chat_screen.dart
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
- ; place-items: center; flex: none;">
- ۰۳ · گفت‌وگوی VIP
- Screen/Course/VIPInstructorChat · نشان VIP طلایی، بقیه سبز
- 04_COURSES
- صفحه ۰۴–۰۵ · تکمیل دوره و گواهی
- ۹:۴۱
- دوره را با موفقیت به پایان رساندید
- تحلیل تکنیکال از صفر تا معامله‌گری
- جلسات تکمیل‌شده
- ۱۲ از ۱۲
- زمان کل صرف‌شده
- ۸ ساعت و ۱۰ دقیقه
- تاریخ تکمیل
- ۶ مرداد ۱۴۰۵
- یادداشت‌های ثبت‌شده
- ۵ یادداشت
- فایل‌های دانلودشده
- ۳ فایل
- ثبت نظر درباره این دوره
- مشاهده گواهی
- بازگشت به دوره‌های من
- ۰۴ · تکمیل دوره
- Screen/Course/Completion · بدون کانفتی
- ۹:۴۱
- گواهی پایان دوره
- <div style="font-family: 'IBM Plex Mo

## Definition of Done checklist
- [ ] File exists at owned path
- [ ] Matches deck structure & Persian labels
- [ ] Semantic colors only
- [ ] Analyzer clean on owned file
- [ ] Formatted
