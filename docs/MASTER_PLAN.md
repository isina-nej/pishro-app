# MASTER PLAN — پیاده‌سازی ۱۰۰٪ صفحات موبایل پیشرو سرمایه

> **هدف:** تبدیل تک‌تک فریم‌های موبایل دک‌های طراحی (`desighn/_capture`) به صفحهٔ Flutter قابل‌اجرا روی **Android**، با کیفیت production، RTL فارسی، و پوش مداوم به GitHub.
>
> **ریپو:** https://github.com/isina-nej/pishro-app  
> **تعداد صفحه:** 108 (`S001`…`S108`)  
> **تمرکز رندر:** Android phone (logical width ≈ ۳۹۰dp مطابق دک)

---

## ۰. اصول غیرقابل‌مذاکره

1. **منبع حقیقت UI:** فقط `_capture/*.html` — هیچ layout اختراعی.
2. **RTL همیشه.** ارقام فارسی در متن (`Fmt.fa`)، لاتین در تیکر؛ ورودی قبل از API با `Fmt.toAscii`.
3. **تم معنایی:** فقط `context.colors` / `context.text` — بدون hex خام در ویجت.
4. **Gold فقط** برای VIP / کوین پیشرو / گواهی.
5. **هرگز فقط با رنگ** برای جهت قیمت/ریسک/وضعیت — آیکون + برچسب.
6. **حداقل تپ‌تارگت ۴۴×۴۴.**
7. **۵ تب ثابت** — بدون Home tab / بدون FAB مرکزی. پیش‌فرض بعد از ورود: دوره‌ها.
8. **مالکیت فایل ایجنت:** هر ایجنت فقط فایل صفحهٔ خودش (+ ویجت اختصاصی همان صفحه در صورت نیاز) را می‌سازد/ویرایش می‌کند.
9. **ممنوع برای ایجنت صفحه:** ویرایش `app_router.dart`, `routes.dart`, `pubspec.yaml`, تم مشترک، یا فایل صفحهٔ دیگر.
10. **Wiring مرکزی** بعد از هر موج توسط Coordinator انجام می‌شود (ثبت route + push).
11. **Android-first:** `flutter run` روی emulator/device اندروید؛ بدون فرض iOS.
12. **هر صفحه سبز:** بعد از اتمام صفحه، `dart format` روی فایل‌های تغییر یافته؛ هیچ error آنالایزر روی فایل مالک.

---

## ۱. معماری اجرا

```
lib/features/<module>/
  data/                  # از قبل / Coordinator تکمیل می‌کند
  presentation/
    screens/<screen>_screen.dart   ← مالک ایجنت صفحه
    widgets/<screen>_*.dart        ← فقط اگر فقط این صفحه لازم دارد
  <module>_routes.dart             ← فقط Coordinator
```

State: Riverpod (`AsyncNotifier` / `FutureProvider` برای سرور، `StateNotifier` برای فرم).  
Network: `apiClientProvider` + typed `ApiException`.  
Mock: Community کامل + KYC/Coin/Devices/Referrals/Notifications در Account وقتی endpoint نیست.

---

## ۲. موج‌بندی (Wave) — موازی‌سازی ایمن

| Wave | ماژول | Agent IDs | صفحات |
|---|---|---|---|
| 1 | auth | S001–… | 8 |
| 2 | courses-catalog-checkout | S009–… | 14 |
| 3 | courses-learning | S023–… | 8 |
| 4 | news | S031–… | 10 |
| 5 | investment | S041–… | 18 |
| 6 | market | S059–… | 12 |
| 7 | community | S071–… | 16 |
| 8 | account | S085–… | 20 |

**Wave 0 (Coordinator — قبل از همه):** فیکس analyze فعلی، فونت Vazirmatn commit، اسکلت `*_routes.dart` خالی، اتصال shell، push اولیه.

**بین موج‌ها:** Coordinator مسیرها را به `GoRouter` وصل می‌کند، `flutter analyze`، commit، **push به `main`**.

---

## ۳. قرارداد ایجنت صفحه (الگوی پلن اختصاصی)

هر ایجنت فایل `docs/agents/<ID>_<slug>.md` را دارد و باید:

### A. Discovery (اجباری قبل از کد)
1. دک مشخص‌شده را با اسکریپت استخراج متن بخواند.
2. hex/px همان بلوک را از `style=` خام grep کند — حدس نزند.
3. کامپوننت‌های مشترک موجود را لیست کند و **reuse** کند.

### B. Implementation
1. فقط فایل مالک را بسازد (`file` در inventory).
2. UI pixel-faithful به دک در عرض ۳۹۰؛ Dark default + Light صحیح.
3. Loading / Empty / Error با `Skeleton` / `EmptyState` / `ErrorStateView` اگر در دک هست.
4. Navigation فقط با `Routes.*` موجود — مسیر جدید اختراع نکند.
5. داده از repository/provider موجود؛ اگر provider نیست، UI را با mock محلی موقت نسازد مگر ماژول mock باشد — در آن صورت از interface ماژول استفاده کند.

### C. Definition of Done
- [ ] صفحه با `const` constructor عمومی
- [ ] RTL و فارسی صحیح
- [ ] بدون hardcode hex
- [ ] تپ‌تارگت ≥ ۴۴
- [ ] `dart format` روی فایل‌ها
- [ ] هیچ analyzer error روی فایل مالک
- [ ] کامنت بالای فایل: `/// Screen/... — «عنوان فارسی»`

### D. Out of scope
- commit/push (Coordinator)
- تغییر روتر سراسری
- پیاده‌سازی صفحهٔ دیگر

---

## ۴. استاندارد بصری Android

- بوم مرجع: **۳۹۰ × ۸۴۴**
- Safe area / status bar: احترام به `MediaQuery.padding`
- کیبورد: bottom nav مخفی (موجود در `AppShell`)
- فونت: Vazirmatn (۴۰۰–۸۰۰)
- عمق: tonal + hairline border — نه سایهٔ سنگین

---

## ۵. نقشهٔ پوش Git

```
main
  └─ بعد از Wave 0: foundation push
  └─ بعد از هر Wave: merge screens → wire routes → analyze → commit → push
```

پیام کامیت موج:
`feat(<module>): implement screens S0xx–S0yy from design decks`

پیام کامیت صفحه (اگر جدا):
`feat(<module>): add <ScreenPath> (S0xx)`

---

## ۶. فهرست کامل صفحات

| ID | Module | Design path | FA | Target file |
|---|---|---|---|---|
| S001 | auth | `Screen/Auth/Splash` | شروع | `lib/features/auth/presentation/screens/splash_screen.dart` |
| S002 | auth | `Screen/Auth/Welcome` | خوش‌آمد | `lib/features/auth/presentation/screens/welcome_screen.dart` |
| S003 | auth | `Screen/Auth/Onboarding-01` | آشنایی ۱ | `lib/features/auth/presentation/screens/onboarding_01_screen.dart` |
| S004 | auth | `Screen/Auth/Onboarding-02` | آشنایی ۲ | `lib/features/auth/presentation/screens/onboarding_02_screen.dart` |
| S005 | auth | `Screen/Auth/Onboarding-03` | آشنایی ۳ | `lib/features/auth/presentation/screens/onboarding_03_screen.dart` |
| S006 | auth | `Screen/Auth/Login` | ورود | `lib/features/auth/presentation/screens/login_screen.dart` |
| S007 | auth | `Screen/Auth/Signup` | ثبت‌نام | `lib/features/auth/presentation/screens/signup_screen.dart` |
| S008 | auth | `Screen/Auth/OTP` | کد تأیید | `lib/features/auth/presentation/screens/o_t_p_screen.dart` |
| S009 | courses | `Screen/Courses/Home` | دوره‌ها (خانه) | `lib/features/courses/presentation/screens/home_screen.dart` |
| S010 | courses | `Screen/Courses/Categories` | دسته‌بندی‌ها | `lib/features/courses/presentation/screens/categories_screen.dart` |
| S011 | courses | `Screen/Courses/Search` | جست‌وجو | `lib/features/courses/presentation/screens/search_screen.dart` |
| S012 | courses | `Screen/Courses/Filters` | فیلترها | `lib/features/courses/presentation/screens/filters_screen.dart` |
| S013 | courses | `Screen/Courses/SearchResults` | نتایج جست‌وجو | `lib/features/courses/presentation/screens/search_results_screen.dart` |
| S014 | courses | `Screen/Course/Details` | جزئیات دوره | `lib/features/courses/presentation/screens/details_screen.dart` |
| S015 | courses | `Screen/Course/PackageComparison` | مقایسه بسته | `lib/features/courses/presentation/screens/package_comparison_screen.dart` |
| S016 | courses | `Screen/Checkout/Course-Regular` | پرداخت بسته عادی | `lib/features/courses/presentation/screens/course__regular_screen.dart` |
| S017 | courses | `Screen/Checkout/Course-VIP` | پرداخت بسته VIP | `lib/features/courses/presentation/screens/course__v_i_p_screen.dart` |
| S018 | courses | `Screen/Checkout/PaymentMethod` | روش پرداخت | `lib/features/courses/presentation/screens/payment_method_screen.dart` |
| S019 | courses | `Screen/Checkout/DiscountAndCoin` | تخفیف و کوین | `lib/features/courses/presentation/screens/discount_and_coin_screen.dart` |
| S020 | courses | `Screen/Checkout/PaymentProcessing` | در حال پردازش | `lib/features/courses/presentation/screens/payment_processing_screen.dart` |
| S021 | courses | `Screen/Checkout/PaymentSuccess` | پرداخت موفق | `lib/features/courses/presentation/screens/payment_success_screen.dart` |
| S022 | courses | `Screen/Checkout/PaymentFailure` | پرداخت ناموفق | `lib/features/courses/presentation/screens/payment_failure_screen.dart` |
| S023 | courses | `Screen/Courses/MyCourses` | دوره‌های من | `lib/features/courses/presentation/screens/my_courses_screen.dart` |
| S024 | courses | `Screen/Course/LearningDashboard` | داشبورد یادگیری | `lib/features/courses/presentation/screens/learning_dashboard_screen.dart` |
| S025 | courses | `Screen/Course/Chapters` | سرفصل‌های دوره | `lib/features/courses/presentation/screens/chapters_screen.dart` |
| S026 | courses | `Screen/Course/LessonDetails` | جزئیات جلسه | `lib/features/courses/presentation/screens/lesson_details_screen.dart` |
| S027 | courses | `Screen/Course/DownloadsAndResources` | دانلودها و منابع | `lib/features/courses/presentation/screens/downloads_and_resources_screen.dart` |
| S028 | courses | `Screen/Course/VIPInstructorChat` | گفت‌وگوی VIP | `lib/features/courses/presentation/screens/v_i_p_instructor_chat_screen.dart` |
| S029 | courses | `Screen/Course/Completion` | تکمیل دوره | `lib/features/courses/presentation/screens/completion_screen.dart` |
| S030 | courses | `Screen/Course/Certificate` | گواهی | `lib/features/courses/presentation/screens/certificate_screen.dart` |
| S031 | news | `Screen/News/Home` | اخبار (خانه) | `lib/features/news/presentation/screens/home_screen.dart` |
| S032 | news | `Screen/News/Trending` | پربازدید | `lib/features/news/presentation/screens/trending_screen.dart` |
| S033 | news | `Screen/News/Categories` | دسته‌بندی | `lib/features/news/presentation/screens/categories_screen.dart` |
| S034 | news | `Screen/News/Filters` | فیلتر | `lib/features/news/presentation/screens/filters_screen.dart` |
| S035 | news | `Screen/News/Search` | جستجو | `lib/features/news/presentation/screens/search_screen.dart` |
| S036 | news | `Screen/News/SearchResults` | نتایج جستجو | `lib/features/news/presentation/screens/search_results_screen.dart` |
| S037 | news | `Screen/News/Details` | جزئیات خبر | `lib/features/news/presentation/screens/details_screen.dart` |
| S038 | news | `Screen/News/Comments` | دیدگاه‌ها | `lib/features/news/presentation/screens/comments_screen.dart` |
| S039 | news | `Screen/News/CommentThread` | رشته پاسخ | `lib/features/news/presentation/screens/comment_thread_screen.dart` |
| S040 | news | `Screen/News/Saved` | ذخیره‌شده‌ها | `lib/features/news/presentation/screens/saved_screen.dart` |
| S041 | investment | `Screen/Investment/Home` | سرمایه‌گذاری (خانه) | `lib/features/investment/presentation/screens/home_screen.dart` |
| S042 | investment | `Screen/Investment/PlanCatalog` | فهرست طرح‌ها | `lib/features/investment/presentation/screens/plan_catalog_screen.dart` |
| S043 | investment | `Screen/Investment/FixedMonthlyPlanDetails` | طرح ماهیانه ۸٪ | `lib/features/investment/presentation/screens/fixed_monthly_plan_details_screen.dart` |
| S044 | investment | `Screen/Investment/DynamicHoldPlanDetails` | طرح هولد داینامیک | `lib/features/investment/presentation/screens/dynamic_hold_plan_details_screen.dart` |
| S045 | investment | `Screen/Investment/PlanComparison` | مقایسه طرح‌ها | `lib/features/investment/presentation/screens/plan_comparison_screen.dart` |
| S046 | investment | `Screen/Investment/Calculator` | محاسبه‌گر | `lib/features/investment/presentation/screens/calculator_screen.dart` |
| S047 | investment | `Screen/Investment/RiskDisclosure` | اطلاع‌رسانی ریسک | `lib/features/investment/presentation/screens/risk_disclosure_screen.dart` |
| S048 | investment | `Screen/Investment/TermsAndContract` | شرایط و قرارداد | `lib/features/investment/presentation/screens/terms_and_contract_screen.dart` |
| S049 | investment | `Screen/Investment/EligibilityAndKYC` | احراز شرایط | `lib/features/investment/presentation/screens/eligibility_and_k_y_c_screen.dart` |
| S050 | investment | `Screen/Investment/AmountEntry` | مبلغ سرمایه‌گذاری | `lib/features/investment/presentation/screens/amount_entry_screen.dart` |
| S051 | investment | `Screen/Investment/FundingSource` | منبع تأمین وجه | `lib/features/investment/presentation/screens/funding_source_screen.dart` |
| S052 | investment | `Screen/Investment/FinalReview` | مرور نهایی | `lib/features/investment/presentation/screens/final_review_screen.dart` |
| S053 | investment | `Screen/Investment/ContractConfirmation` | تأیید قرارداد | `lib/features/investment/presentation/screens/contract_confirmation_screen.dart` |
| S054 | investment | `Screen/Investment/Processing` | پردازش | `lib/features/investment/presentation/screens/processing_screen.dart` |
| S055 | investment | `Screen/Investment/Success` | موفقیت (فعال‌شده) | `lib/features/investment/presentation/screens/success_screen.dart` |
| S056 | investment | `Screen/Investment/ActiveInvestments` | سرمایه‌گذاری‌های من | `lib/features/investment/presentation/screens/active_investments_screen.dart` |
| S057 | investment | `Screen/Investment/ActiveInvestmentDetails` | جزئیات سرمایه‌گذاری | `lib/features/investment/presentation/screens/active_investment_details_screen.dart` |
| S058 | investment | `Screen/Investment/PaymentSchedule` | برنامه پرداخت | `lib/features/investment/presentation/screens/payment_schedule_screen.dart` |
| S059 | market | `Screen/Market/Home` | بازار (خانه) | `lib/features/market/presentation/screens/home_screen.dart` |
| S060 | market | `Screen/Market/AllAssets` | همه ارزها | `lib/features/market/presentation/screens/all_assets_screen.dart` |
| S061 | market | `Screen/Market/Favorites` | علاقه‌مندی‌ها | `lib/features/market/presentation/screens/favorites_screen.dart` |
| S062 | market | `Screen/Market/Trending` | پرطرفدار | `lib/features/market/presentation/screens/trending_screen.dart` |
| S063 | market | `Screen/Market/TopGainers` | بیشترین رشد | `lib/features/market/presentation/screens/top_gainers_screen.dart` |
| S064 | market | `Screen/Market/TopLosers` | بیشترین کاهش | `lib/features/market/presentation/screens/top_losers_screen.dart` |
| S065 | market | `Screen/Market/Search` | جستجوی ارز | `lib/features/market/presentation/screens/search_screen.dart` |
| S066 | market | `Screen/Market/CoinDetails` | جزئیات ارز | `lib/features/market/presentation/screens/coin_details_screen.dart` |
| S067 | market | `Screen/Market/PriceChart` | نمودار قیمت | `lib/features/market/presentation/screens/price_chart_screen.dart` |
| S068 | market | `Screen/Market/Statistics` | آمار بازار | `lib/features/market/presentation/screens/statistics_screen.dart` |
| S069 | market | `Screen/Market/HistoricalData` | داده‌های تاریخی | `lib/features/market/presentation/screens/historical_data_screen.dart` |
| S070 | market | `Screen/Market/PriceAlerts` | هشدارهای قیمت | `lib/features/market/presentation/screens/price_alerts_screen.dart` |
| S071 | community | `Screen/Community/Home` | جامعه (خانه) | `lib/features/community/presentation/screens/home_screen.dart` |
| S072 | community | `Screen/Community/FollowingFeed` | دنبال‌شده‌ها | `lib/features/community/presentation/screens/following_feed_screen.dart` |
| S073 | community | `Screen/Community/RecommendedAnalysts` | تحلیلگران پیشنهادی | `lib/features/community/presentation/screens/recommended_analysts_screen.dart` |
| S074 | community | `Screen/Community/Leaderboard` | رتبه‌بندی | `lib/features/community/presentation/screens/leaderboard_screen.dart` |
| S075 | community | `Screen/Community/Search` | جستجو در جامعه | `lib/features/community/presentation/screens/search_screen.dart` |
| S076 | community | `Screen/Community/AnalystProfile` | پروفایل تحلیلگر | `lib/features/community/presentation/screens/analyst_profile_screen.dart` |
| S077 | community | `Screen/Community/AnalystRatings` | امتیازها و نظرات | `lib/features/community/presentation/screens/analyst_ratings_screen.dart` |
| S078 | community | `Screen/Community/AnalysisDetails` | جزئیات تحلیل | `lib/features/community/presentation/screens/analysis_details_screen.dart` |
| S079 | community | `Screen/Community/PremiumSignals` | سیگنال‌های اشتراکی | `lib/features/community/presentation/screens/premium_signals_screen.dart` |
| S080 | community | `Screen/Community/Subscriptions` | اشتراک‌های من | `lib/features/community/presentation/screens/subscriptions_screen.dart` |
| S081 | community | `Screen/Community/CreateAnalysis` | ایجاد تحلیل | `lib/features/community/presentation/screens/create_analysis_screen.dart` |
| S082 | community | `Screen/Community/AnalysisEditor` | ویرایشگر تحلیل | `lib/features/community/presentation/screens/analysis_editor_screen.dart` |
| S083 | community | `Screen/Community/AnalysisPreview` | پیش‌نمایش تحلیل | `lib/features/community/presentation/screens/analysis_preview_screen.dart` |
| S084 | community | `Screen/Community/PublishResult` | نتیجه انتشار | `lib/features/community/presentation/screens/publish_result_screen.dart` |
| S085 | account | `Screen/Account/Home` | حساب کاربری (خانه) | `lib/features/account/presentation/screens/home_screen.dart` |
| S086 | account | `Screen/Account/Profile` | اطلاعات حساب | `lib/features/account/presentation/screens/profile_screen.dart` |
| S087 | account | `Screen/Account/EditProfile` | ویرایش اطلاعات | `lib/features/account/presentation/screens/edit_profile_screen.dart` |
| S088 | account | `Screen/Account/KYCOverview` | احراز هویت — نمای کلی | `lib/features/account/presentation/screens/k_y_c_overview_screen.dart` |
| S089 | account | `Screen/Account/KYCVerification` | احراز هویت — تکمیل | `lib/features/account/presentation/screens/k_y_c_verification_screen.dart` |
| S090 | account | `Screen/Account/Wallet` | کیف پول | `lib/features/account/presentation/screens/wallet_screen.dart` |
| S091 | account | `Screen/Account/WalletTransactions` | تراکنش‌های کیف پول | `lib/features/account/presentation/screens/wallet_transactions_screen.dart` |
| S092 | account | `Screen/Account/PishroCoin` | کوین پیشرو | `lib/features/account/presentation/screens/pishro_coin_screen.dart` |
| S093 | account | `Screen/Account/PurchaseHistory` | سوابق خرید | `lib/features/account/presentation/screens/purchase_history_screen.dart` |
| S094 | account | `Screen/Account/InvestmentHistory` | سوابق سرمایه‌گذاری | `lib/features/account/presentation/screens/investment_history_screen.dart` |
| S095 | account | `Screen/Account/Subscriptions` | اشتراک‌ها | `lib/features/account/presentation/screens/subscriptions_screen.dart` |
| S096 | account | `Screen/Account/SavedItems` | ذخیره‌شده‌ها | `lib/features/account/presentation/screens/saved_items_screen.dart` |
| S097 | account | `Screen/Account/Notifications` | اعلان‌ها | `lib/features/account/presentation/screens/notifications_screen.dart` |
| S098 | account | `Screen/Account/Security` | امنیت حساب | `lib/features/account/presentation/screens/security_screen.dart` |
| S099 | account | `Screen/Account/Devices` | دستگاه‌ها و نشست‌ها | `lib/features/account/presentation/screens/devices_screen.dart` |
| S100 | account | `Screen/Account/Privacy` | حریم خصوصی | `lib/features/account/presentation/screens/privacy_screen.dart` |
| S101 | account | `Screen/Account/Support` | پشتیبانی | `lib/features/account/presentation/screens/support_screen.dart` |
| S102 | account | `Screen/Account/Referrals` | معرفی به دوستان | `lib/features/account/presentation/screens/referrals_screen.dart` |
| S103 | account | `Screen/Account/Preferences` | تنظیمات | `lib/features/account/presentation/screens/preferences_screen.dart` |
| S104 | account | `Screen/Account/LegalDocuments` | اسناد و قوانین | `lib/features/account/presentation/screens/legal_documents_screen.dart` |
| S105 | community | `Screen/Community/AssetFeed` | فید دارایی در جامعه | `lib/features/community/presentation/screens/asset_feed_screen.dart` |
| S106 | courses | `Screen/Checkout/Processing` | پرداخت — پردازش (شبکه) | `lib/features/courses/presentation/screens/processing_screen.dart` |
| S107 | courses | `Screen/Checkout/NetworkError` | پرداخت — خطای شبکه | `lib/features/courses/presentation/screens/network_error_screen.dart` |
| S108 | community | `Screen/AnalysisComments` | دیدگاه‌های تحلیل | `lib/features/community/presentation/screens/analysis_comments_screen.dart` |

---

## ۷. ریسک‌ها و کنترل تعارض

| ریسک | کنترل |
|---|---|
| دو ایجنت یک فایل را ویرایش کنند | مالکیت تک‌فایلی سخت |
| `*_routes.dart` conflict | فقط Coordinator |
| API ناقص (Community/Account slice) | mock repository پشت interface |
| پرداخت جعلی سمت سرور (S2/S3) | UI کامل؛ تأیید واقعی پشت feature flag تا بک‌اند fix شود |
| حجم موازی زیاد | حداکثر ۸–۱۲ ایجنت همزمان در هر موج |

---

## ۸. ترتیب اولویت کسب‌وکار

1. Auth (ورود واقعی)  
2. Courses Home + News Home (دو تب اصلی)  
3. بقیهٔ Courses/News  
4. Market  
5. Investment  
6. Account  
7. Community (mock)

این ترتیب همان موج‌هاست.
