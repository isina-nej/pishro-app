# تحلیل پروژه پیشرو سرمایه

**تاریخ:** ۱۴۰۵/۰۵/۲۰ (2026-08-11)
**دامنه:** چهار مخزن زیر `~/Documents/project/pishro/` + بکند `isina-nej/pishro`
**روش:** بازخوانی ایستای سورس، اسکیما، migrationها و کانفیگ در `HEAD` فعلی. تست نفوذ زنده انجام نشده — یافته‌های امنیتی «تأییدشده از روی کد» هستند، نه «تأییدشده روی سیستم در حال اجرا».

---

## ۱. نقشه‌ی پروژه

چهار مخزن مستقل، نه یک monorepo:

| مسیر | مخزن | نقش | وضعیت |
|---|---|---|---|
| `pishro/` | `isina-nej/pishro` | **بکند + وب‌سایت اصلی** — Next.js 15 فول‌استک | فعال، آخرین کامیت ۱۴۰۵/۰۵/۱۳ |
| `pishbini/` | `isina-nej/pishbini` | کمپین پیش‌بینی جام جهانی (`wc.pishrosarmaye.com`) | جدا، وابستگی کد ندارد |
| `pishro-web-design/` | `isina-nej/pishro-web-design` | ۳۲ نسخه طراحی لندینگ (HTML ایستا) | خروجی طراحی، Vercel |
| `pishro-application/` | — | `desighn/` دک‌های طراحی اپ + `pishro-app/` اپ فلاتر | اپ تازه شروع شد |

نکته‌ی ساختاری: ریشه‌ی `pishro/` خودش working tree مخزن `pishro-web-design` است، یعنی سه پروژه‌ی دیگر داخل یک مخزن دیگر تودرتو نشسته‌اند. `.gitignore` فعلاً پوشش می‌دهد، ولی این چیدمان شکننده است.

---

## ۲. بکند — معماری

Next.js 15 App Router · React 19 · MySQL · Prisma 6 · ~۸۶٬۶۰۰ خط در `app/+components/+lib/` · ۱٬۳۲۰ فایل tracked.

| لایه | وضعیت |
|---|---|
| Route handlers | **۱۷۵** (۱۱۱ ادمین، ۶۴ عمومی) |
| مدل Prisma | **۵۷** (از ۴۵ در بازبینی قبلی) |
| Migration | ۱۵ — اولی ۱٬۰۶۰ خطی و تقریباً کل اسکیما را می‌سازد (تاریخچه squash شده) |
| احراز هویت | **دو سیستم مستقل**: NextAuth v5 برای مشتری (JWT، ۳۰ روز) + JWT دست‌ساز برای ادمین |
| دسترسی داده | **دو لایه روی یک دیتابیس**: Prisma (۹۶ روت) + pool خام `mysql2` (۹ روت) |
| ذخیره‌سازی | دیسک محلی + S3 (ArvanCloud/Liara) برای ویدیو و HLS |
| ویدیو | ffmpeg → HLS در کانتینر جدا — معماری درست |

### پیشرفت نسبت به بازبینی قبلی (`fe36dcf` → `a2c9d6f`، ۱۰۴ کامیت)

✅ **`/api/debug/*` کاملاً حذف شد.** این بحرانی‌ترین یافته‌ی بازبینی قبلی بود — ۱۶ روت بدون احراز هویت که یکی‌شان `deleteMany({})` روی کل کتابخانه اجرا می‌کرد. الان صفر روت debug وجود دارد. کار خوبی شد.

✅ CRM اضافه شد (`Lead`, `Deal`, `PipelineStage`, `SupportTicket`, `AuditLog`)، CMS لندینگ، و سرویس بازار با fallback چندارائه‌دهنده (CoinGecko → Binance → Nobitex) که واقعاً با دقت نوشته شده.

✅ پوشش envelope بهتر شد: ۱۵۶ از ۱۷۵ روت از `lib/api-response.ts` استفاده می‌کنند.

---

## ۳. یافته‌های امنیتی باز (تأییدشده در HEAD فعلی)

### 🔴 بحرانی

**S2 — تأیید پرداخت جعلی است و احراز هویت ندارد.**
`app/api/payment/verify/route.ts` — کل مسیر واقعی زرین‌پال کامنت شده (خطوط ۳۴–۷۵). چیزی که اجرا می‌شود:

```
GET /api/payment/verify?orderId=<id>&Authority=<هرچیزی>&Status=OK
```

بدون session، بدون امضا، بدون بررسی مالکیت سفارش → `status: "PAID"` + تراکنش `SUCCESS` + `createEnrollmentsFromOrder()`. هرکسی که `orderId` را حدس بزند دوره‌ی پولی رایگان می‌گیرد.

**S3 — `checkout` به `userId` سمت کلاینت اعتماد می‌کند.**
`app/api/checkout/route.ts:16` — `userId` مستقیم از body می‌آید، هیچ `auth()` ای صدا زده نمی‌شود. سفارش به نام هر کاربری قابل ساخت است.
نکته‌ی مثبت: `total` از روی قیمت واقعی DB محاسبه می‌شود، نه از کلاینت — آن بخش درست است. مسیر موازی `app/api/user/pay/route.ts` session را درست چک می‌کند؛ الگوی درست همان‌جاست.

> S2 و S3 با هم یک زنجیره‌ی کامل «ثبت‌نام رایگان در دوره‌ی پولی به نام هر کاربر» می‌سازند.

### 🟠 مهم

**S4 — XSS ذخیره‌شده در رندر اخبار.** `components/news/NewsDetail.tsx:108` و `NewsArticleDetail.tsx:349,372` محتوا را با `dangerouslySetInnerHTML` بدون sanitize رندر می‌کنند. تنها فیلتر موجود یک regex ضعیف (`lib/sanitize-content.ts`) در *زمان ساخت* است، نه رندر. `isomorphic-dompurify` در پروژه هست ولی به این مسیر وصل نیست.

**S5 — fallback رمز دیتابیس هنوز هاردکد است.** `lib/db.ts:12` → `process.env.DB_PASSWORD || 'pishro_password'`. الان یک `console.warn` اضافه شده ولی **fail-fast نمی‌کند** — یک deploy با env ناقص بی‌صدا با رمز پیش‌فرض وصل می‌شود. `.env.example` هنوز وجود ندارد.

### 🟡 متوسط

- **S7** — `admin_access_token` عمداً `httpOnly: false` است (`login/route.ts:132`). هر XSS در پنل ادمین = سرقت کامل توکن. مکانیزم revocation سمت سرور هم وجود ندارد.
- **S9** — Rate limiting روی **صفر از ۵** روت OTP/SMS. روی `checkout` و `payment/verify` هم نیست. فقط ۳ روت در کل پروژه از `checkRateLimit` استفاده می‌کنند — و روت لاگین ادمین limiter دست‌ساز خودش را دارد.
- **S8** — `addSecurityHeaders` روی **۲ از ۱۷۵** روت وصل است. CSP موجود هم `'unsafe-inline'` می‌دهد.
- **S10** — `UserInvestmentPortfolio.userId` هنوز `onDelete: Cascade` است. حذف کاربر، رکورد سرمایه‌گذاری‌اش را نابود می‌کند — برخلاف `Order`/`Transaction` که درست `SetNull` هستند.

---

## ۴. عملکرد

- **`Order` و `Transaction` هیچ `@@index` ندارند.** اسکیما در مجموع ۸۲ ایندکس دارد، ولی صفر تا روی دو جدول مالی — دقیقاً همان‌هایی که داشبورد ادمین بر اساس `status`/`createdAt` فیلتر می‌کند. `User` هم فقط `archivedAt` دارد.
- **`new PrismaClient()` در ۲ روت** (`api/news`, `api/newsletter/subscribe`) به‌جای singleton — ریسک اتمام connection pool.
- **پنل ادمین ۳۹/۳۹ صفحه `"use client"`** است. صفر SSR در فریم‌ورکی که برای SSR انتخاب شده.
- **۳ مرز `loading.tsx`/`error.tsx` برای ۶۵ صفحه.** یک `not-found.tsx` ریشه.
- **`next/dynamic` فقط در ۵ فایل** — باندل ادیتور Tiptap روی هر صفحه‌ی ادمین می‌رود.
- **`graphify-out/` داخل `app/`, `lib/`, `components/` ریخته** (~۱٫۴MB `graph.json` داخل درخت سورس). `.gitignore` فقط ریشه را می‌گیرد؛ این‌ها را Next اسکن می‌کند.
- **۳٫۱GB** بین `.next` و بکاپ‌هایش روی دیسک.

---

## ۵. بدهی فنی

1. **دو لایه‌ی دسترسی داده به‌صورت دائمی.** الگوی `<domain>-mysql.ts` + `<domain>-service.ts` در news/library/investment-models/skyroom یعنی دو پیاده‌سازی از فیلتر/صفحه‌بندی که از هم جدا می‌افتند.
2. **دو سیستم کامنت** (`Comment` و `NewsComment`) و **دو نمایش تگ** (فیلد JSON + جدول join) روی یک مدل.
3. **`Order.items: Json` موازی جدول `OrderItem`** — دو منبع حقیقت برای اقلام سفارش در یک ردیف.
4. **پوشه‌ی مرده‌ی `app/admin/library/\[id\]`** (براکت escape شده، از یک `mkdir` اشتباه) کنار `[id]` واقعی.
5. **ادیتورهای خبر بلااستفاده** هنوز سر جایشان‌اند: `RichNewsEditor.tsx` (۵۶۶ خط)، `MDXNewsEditor.tsx` (۵۰۹ خط).
6. **۹ تغییر OpenSpec باز**، از جمله `enterprise-architecture-refactor` که همین مشکلات را تشخیص داده و اجرا نشده.

---

## ۶. شکاف طراحی ↔ بکند (برای اپ فلاتر)

از ~۹۵ صفحه‌ی دک‌های طراحی:

| ماژول | پوشش API |
|---|---|
| Auth، Courses، News، Investment، Market | ✅ کامل |
| **Community** (۱۵ صفحه) | ❌ **هیچ endpoint ای وجود ندارد** |
| Account (۲۰ صفحه) | ⚠️ جزئی — پروفایل/سفارش/تراکنش/بوکمارک هست؛ KYC، کوین پیشرو، دستگاه‌ها، معرف‌ها، اعلان‌ها نیست |

اپ فلاتر این‌ها را پشت repository interface با mock می‌سازد، تا وقتی API آمد فقط implementation عوض شود.

---

## ۷. اولویت‌بندی پیشنهادی

**همین هفته (امنیتی، دیف کوچک، ریسک بزرگ):**
1. `payment/verify` — احراز هویت + بررسی مالکیت سفارش + فعال‌کردن تأیید واقعی زرین‌پال.
2. `checkout` — اضافه‌کردن `auth()` دقیقاً مثل `user/pay`.
3. sanitize محتوای خبر با DOMPurify در زمان رندر.
4. حذف fallback رمز DB → fail-fast + افزودن `.env.example`.

**این اسپرینت:**
5. Rate limiting واقعی (ذخیره‌ی مشترک، نه `Map` در حافظه) روی OTP/login/checkout/payment.
6. ایندکس روی `Order.status/createdAt`، `Transaction.status/type/createdAt`، `User.role/createdAt`.
7. `UserInvestmentPortfolio` → `SetNull`.
8. `addSecurityHeaders` سراسری از `middleware.ts`.
9. حذف `graphify-out/` از داخل `app/`, `lib/`, `components/`.

**اسپرینت بعد:**
10. یک لایه‌ی داده به‌ازای هر دامنه انتخاب شود، دیگری حذف.
11. حذف ادیتورهای مرده و پوشه‌ی `\[id\]`.
12. `error.tsx`/`loading.tsx` برای مسیرهای پرترافیک.
13. تعیین تکلیف `enterprise-architecture-refactor`.

---

*این تحلیل یک بازخوانی ایستا در یک نقطه‌ی زمانی است. پیش از اقدام روی یافته‌های بحرانی، آن‌ها را روی محیط در حال اجرا بازتولید کنید — ممکن است بعضی با کنترل‌های زیرساختی (مثلاً reverse proxy) پوشش داده شده باشند که از سورس دیده نمی‌شود.*
