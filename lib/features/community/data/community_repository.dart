import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../shared/widgets/pishro_badge.dart' show RiskLevel;
import 'community_models.dart';

abstract class CommunityRepository {
  Future<List<Analysis>> feed({AnalysisFilter filter = AnalysisFilter.all});

  Future<List<Analysis>> following({FollowingSort sort = FollowingSort.newest});

  Future<List<Analyst>> recommendedAnalysts();

  Future<Analyst?> analyst(String id);

  Future<AnalystRatingSummary> ratings(String analystId);

  Future<LeaderboardPage> leaderboard({
    LeaderboardPeriod period = LeaderboardPeriod.month,
    LeaderboardMetric metric = LeaderboardMetric.userRating,
  });

  Future<CommunitySearchResults> search(String query, {SearchScope scope});

  Future<List<SignalOffer>> signals();

  Future<List<Subscription>> subscriptions();

  Future<Analysis?> analysis(String id);

  Future<List<AnalysisComment>> comments(String analysisId);

  Future<List<Analysis>> assetFeed(String symbol);

  Future<List<AssetOption>> assets();

  Future<PublishOutcome> publish(AnalysisDraft draft);

  Future<void> toggleFollow(String analystId);
}

class MockCommunityRepository implements CommunityRepository {
  MockCommunityRepository() {
    _following = {for (final a in _analysts.where((a) => a.isFollowing)) a.id};
  }

  late Set<String> _following;
  AnalysisDraft? lastDraft;
  PublishOutcome? lastPublish;

  static final _now = DateTime.now();

  static final _analysts = <Analyst>[
    Analyst(
      id: 'a1',
      displayName: 'نگار احمدی',
      specialty: 'تحلیل تکنیکال',
      publishedCount: 42,
      rating: 4.6,
      reviewCount: 128,
      followerCount: 1840,
      activeSinceJalaliYear: 1401,
      bio: 'تمرکز روی ساختار بازار و مدیریت ریسک. بدون توصیه خرید یا فروش.',
      badges: const [
        AnalystBadge(label: 'هویت تأییدشده', granted: true),
        AnalystBadge(label: 'مدرک تخصصی', granted: true),
        AnalystBadge(label: 'سابقه حرفه‌ای', granted: false, detail: 'ناقص'),
      ],
      disclosure: 'ممکن است در دارایی‌های مورد بحث موقعیت داشته باشم.',
      isFollowing: true,
      isIdentityVerified: true,
    ),
    Analyst(
      id: 'a2',
      displayName: 'کیان رضوی',
      specialty: 'تحلیل بنیادی',
      publishedCount: 19,
      rating: 4.2,
      reviewCount: 54,
      followerCount: 620,
      activeSinceJalaliYear: 1402,
      bio: 'نگاه میان‌مدت به چرخه‌های نقدینگی و همبستگی بازارها.',
      badges: const [
        AnalystBadge(label: 'هویت تأییدشده', granted: true),
        AnalystBadge(label: 'مدرک تخصصی', granted: false),
      ],
      disclosure: 'این تحلیل توصیه سرمایه‌گذاری نیست.',
      isFollowing: false,
      isIdentityVerified: true,
    ),
    Analyst(
      id: 'a3',
      displayName: 'سارا نوری',
      specialty: 'آنچین',
      publishedCount: 11,
      rating: 4.8,
      reviewCount: 37,
      followerCount: 910,
      activeSinceJalaliYear: 1403,
      bio: 'جریان نهنگ‌ها و فعالیت شبکه؛ بدون پیش‌بینی قیمت قطعی.',
      badges: const [
        AnalystBadge(label: 'هویت تأییدشده', granted: true),
        AnalystBadge(label: 'مدرک تخصصی', granted: true),
      ],
      disclosure: 'اسپانسر ندارد.',
      isFollowing: true,
      isIdentityVerified: true,
    ),
  ];

  static List<Analysis> get _analyses => [
    Analysis(
      id: 'an1',
      author: const AuthorRef(id: 'a1', displayName: 'نگار احمدی'),
      publishedAt: _now.subtract(const Duration(hours: 3)),
      title: 'ساختار بیت‌کوین پس از شکست مقاومت هفتگی',
      assetSymbol: 'BTC',
      kind: AnalysisKind.technical,
      timeframe: Timeframe.medium,
      risk: RiskLevel.high,
      summary: 'محدوده تقاضا حفظ شده؛ شرط بی‌اعتبار شدن زیر کف قبلی است.',
      body:
          'قیمت پس از چند کندل تأییدی بالای مقاومت شکسته، به محدوده تعادلی برگشته است. این یادداشت توصیه معامله نیست.',
      scenarios: const [
        Scenario(label: 'ادامه روند', note: 'حفظ محدوده تقاضا'),
        Scenario(label: 'خنثی', note: 'نوسان داخل کانال'),
        Scenario(label: 'بازگشت', note: 'از دست رفتن کف'),
      ],
      invalidation: 'بسته شدن روزانه زیر کف محدوده تقاضا.',
      helpfulCount: 86,
      commentCount: 14,
      isNew: true,
    ),
    Analysis(
      id: 'an2',
      author: const AuthorRef(id: 'a2', displayName: 'کیان رضوی'),
      publishedAt: _now.subtract(const Duration(days: 1)),
      title: 'اتریوم و هزینه شبکه در افق میان‌مدت',
      assetSymbol: 'ETH',
      kind: AnalysisKind.fundamental,
      timeframe: Timeframe.long,
      risk: RiskLevel.medium,
      summary: 'فشار کارمزد و عرضه در گردش؛ بدون رقم بازدهی.',
      body: 'تغییرات کارمزد به‌تنهایی سیگنال ورود نیست.',
      scenarios: const [
        Scenario(label: 'سناریوی اول'),
        Scenario(label: 'سناریوی دوم'),
        Scenario(label: 'سناریوی سوم'),
      ],
      invalidation: 'تغییر معنادار در سیاست کارمزد شبکه.',
      helpfulCount: 41,
      commentCount: 7,
    ),
    Analysis(
      id: 'an3',
      author: const AuthorRef(id: 'a3', displayName: 'سارا نوری'),
      publishedAt: _now.subtract(const Duration(days: 2)),
      title: 'جریان آنچین تتر و نقدینگی ریال',
      assetSymbol: 'USDT',
      kind: AnalysisKind.onchain,
      timeframe: Timeframe.short,
      risk: RiskLevel.medium,
      summary: 'افزایش انتقال‌های بزرگ؛ داده نمونه برای نمایش ساختار.',
      body: 'داده زنجیره تأخیر دارد و جایگزین تحلیل سفارش نیست.',
      access: AnalysisAccess.premiumLocked,
      commentCount: 3,
      dataOutdated: true,
    ),
    Analysis(
      id: 'an4',
      author: const AuthorRef(id: 'a1', displayName: 'نگار احمدی'),
      publishedAt: _now.subtract(const Duration(days: 4)),
      title: 'سولانا: نوسان پس از رویداد شبکه',
      assetSymbol: 'SOL',
      kind: AnalysisKind.technical,
      timeframe: Timeframe.short,
      risk: RiskLevel.high,
      summary: 'سناریوها هم‌وزن‌اند؛ رنگ اختصاصی افزایشی وجود ندارد.',
      body: 'نوسان اخیر لزوماً آغاز روند نیست.',
      helpfulCount: 22,
      commentCount: 5,
      isSaved: true,
    ),
  ];

  Analyst _withFollow(Analyst a) =>
      a.copyWith(isFollowing: _following.contains(a.id));

  @override
  Future<List<Analysis>> feed({
    AnalysisFilter filter = AnalysisFilter.all,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return [
      for (final a in _analyses)
        if (filter == AnalysisFilter.all ||
            (filter == AnalysisFilter.following &&
                _following.contains(a.author.id)) ||
            (filter == AnalysisFilter.technical &&
                a.kind == AnalysisKind.technical) ||
            (filter == AnalysisFilter.onchain &&
                a.kind == AnalysisKind.onchain))
          a,
    ];
  }

  @override
  Future<List<Analysis>> following({
    FollowingSort sort = FollowingSort.newest,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final list = [
      for (final a in _analyses)
        if (_following.contains(a.author.id)) a,
    ];
    if (sort == FollowingSort.lastUpdated) {
      list.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    }
    return list;
  }

  @override
  Future<List<Analyst>> recommendedAnalysts() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return [for (final a in _analysts) _withFollow(a)];
  }

  @override
  Future<Analyst?> analyst(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 60));
    for (final a in _analysts) {
      if (a.id == id) return _withFollow(a);
    }
    return null;
  }

  @override
  Future<AnalystRatingSummary> ratings(String analystId) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final a = await analyst(analystId);
    return AnalystRatingSummary(
      average: a?.rating ?? 0,
      reviewCount: a?.reviewCount ?? 0,
      canRate: a?.isFollowing ?? false,
      categories: const [
        CategoryScore(label: 'کیفیت تحلیل', value: 0.82),
        CategoryScore(label: 'شفافیت', value: 0.76),
        CategoryScore(label: 'توضیح ریسک', value: 0.88),
      ],
      reviews: const [
        AnalystReview(
          id: 'r1',
          authorName: 'کاربر تأییدشده',
          stars: 5,
          body: 'ریسک و شرط بی‌اعتبار شدن شفاف نوشته شده بود.',
          isVerifiedSubscriber: true,
        ),
        AnalystReview(
          id: 'r2',
          authorName: 'عضو جامعه',
          stars: 4,
          body: 'سناریوها هم‌وزن بودند؛ بدون وعده سود.',
        ),
      ],
    );
  }

  @override
  Future<LeaderboardPage> leaderboard({
    LeaderboardPeriod period = LeaderboardPeriod.month,
    LeaderboardMetric metric = LeaderboardMetric.userRating,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final ranked = [..._analysts]
      ..sort(
        (a, b) => metric == LeaderboardMetric.participation
            ? b.publishedCount.compareTo(a.publishedCount)
            : b.rating.compareTo(a.rating),
      );
    return LeaderboardPage(
      entries: [
        for (var i = 0; i < ranked.length; i++)
          LeaderboardEntry(
            rank: i + 1,
            analystId: ranked[i].id,
            displayName: ranked[i].displayName,
            analysisCount: ranked[i].publishedCount,
            reviewCount: ranked[i].reviewCount,
            rating: ranked[i].rating,
          ),
      ],
      performanceDataAvailable: false,
      notice:
          'رتبه‌بندی فقط بر اساس امتیاز کاربران و مشارکت است — بدون معیار بازدهی.',
    );
  }

  @override
  Future<CommunitySearchResults> search(
    String query, {
    SearchScope scope = SearchScope.all,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final q = query.trim();
    bool hit(String s) => q.isEmpty || s.contains(q);
    final analysts = [
      if (scope != SearchScope.analyses)
        for (final a in _analysts)
          if (hit(a.displayName) || hit(a.specialty)) _withFollow(a),
    ];
    final analyses = [
      if (scope != SearchScope.analysts)
        for (final a in _analyses)
          if (hit(a.title) || hit(a.assetSymbol) || hit(a.author.displayName))
            a,
    ];
    return CommunitySearchResults(analysts: analysts, analyses: analyses);
  }

  @override
  Future<List<SignalOffer>> signals() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return const [
      SignalOffer(
        id: 's1',
        provider: AuthorRef(id: 'a1', displayName: 'نگار احمدی'),
        coverage: 'BTC، ETH',
        cadence: 'هفتگی',
        horizon: 'میان‌مدت',
        priceToman: 890000,
        isEligible: true,
      ),
      SignalOffer(
        id: 's2',
        provider: AuthorRef(id: 'a3', displayName: 'سارا نوری'),
        coverage: 'USDT، SOL',
        cadence: 'روزانه',
        horizon: 'کوتاه‌مدت',
        priceToman: 490000,
        isEligible: false,
      ),
    ];
  }

  @override
  Future<List<Subscription>> subscriptions() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return [
      Subscription(
        id: 'sub1',
        providerName: 'نگار احمدی',
        status: SubscriptionStatus.active,
        priceToman: 890000,
        period: 'ماهانه',
        renewsAt: _now.add(const Duration(days: 18)),
      ),
      const Subscription(
        id: 'sub2',
        providerName: 'کیان رضوی',
        status: SubscriptionStatus.pending,
        priceToman: 590000,
        period: 'ماهانه',
        autoRenew: false,
      ),
    ];
  }

  @override
  Future<Analysis?> analysis(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 60));
    for (final a in _analyses) {
      if (a.id == id) return a;
    }
    return null;
  }

  @override
  Future<List<AnalysisComment>> comments(String analysisId) async {
    await Future<void>.delayed(const Duration(milliseconds: 60));
    return [
      AnalysisComment(
        id: 'c1',
        authorName: 'عضو جامعه',
        publishedAt: _now.subtract(const Duration(hours: 5)),
        body: 'شرط بی‌اعتبار شدن واضح بود. ممنون.',
        replyCount: 1,
      ),
      AnalysisComment(
        id: 'c2',
        authorName: 'شما',
        publishedAt: _now.subtract(const Duration(minutes: 20)),
        body: 'آیا سناریوی خنثی هم به‌روزرسانی می‌شود؟',
        moderation: ModerationState.pendingModeration,
      ),
    ];
  }

  @override
  Future<List<Analysis>> assetFeed(String symbol) async {
    await Future<void>.delayed(const Duration(milliseconds: 60));
    final s = symbol.toUpperCase();
    return [
      for (final a in _analyses)
        if (a.assetSymbol == s) a,
    ];
  }

  @override
  Future<List<AssetOption>> assets() async {
    return const [
      AssetOption(symbol: 'BTC', name: 'Bitcoin'),
      AssetOption(symbol: 'ETH', name: 'Ethereum'),
      AssetOption(symbol: 'USDT', name: 'Tether'),
      AssetOption(symbol: 'SOL', name: 'Solana'),
    ];
  }

  @override
  Future<PublishOutcome> publish(AnalysisDraft draft) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    lastDraft = draft;
    lastPublish = PublishOutcome(
      status: PublishStatus.pendingModeration,
      title: draft.title,
      visibility: draft.visibility,
      analysisId: 'AN-${DateTime.now().millisecondsSinceEpoch % 10000}',
      publishedAt: DateTime.now(),
    );
    return lastPublish!;
  }

  @override
  Future<void> toggleFollow(String analystId) async {
    if (!_following.remove(analystId)) _following.add(analystId);
  }
}

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  // Swap becomes a one-liner when the API ships.
  if (!AppConfig.useMockForMissingApis) {
    return MockCommunityRepository();
  }
  return MockCommunityRepository();
});

final communityFeedProvider =
    FutureProvider.family<List<Analysis>, AnalysisFilter>(
      (ref, filter) =>
          ref.watch(communityRepositoryProvider).feed(filter: filter),
    );

final followingFeedProvider = FutureProvider<List<Analysis>>(
  (ref) => ref.watch(communityRepositoryProvider).following(),
);

final recommendedAnalystsProvider = FutureProvider<List<Analyst>>(
  (ref) => ref.watch(communityRepositoryProvider).recommendedAnalysts(),
);

final analystProvider = FutureProvider.family<Analyst?, String>(
  (ref, id) => ref.watch(communityRepositoryProvider).analyst(id),
);

final analystRatingsProvider =
    FutureProvider.family<AnalystRatingSummary, String>(
      (ref, id) => ref.watch(communityRepositoryProvider).ratings(id),
    );

final leaderboardProvider = FutureProvider<LeaderboardPage>(
  (ref) => ref.watch(communityRepositoryProvider).leaderboard(),
);

final signalsProvider = FutureProvider<List<SignalOffer>>(
  (ref) => ref.watch(communityRepositoryProvider).signals(),
);

final communitySubscriptionsProvider = FutureProvider<List<Subscription>>(
  (ref) => ref.watch(communityRepositoryProvider).subscriptions(),
);

final analysisProvider = FutureProvider.family<Analysis?, String>(
  (ref, id) => ref.watch(communityRepositoryProvider).analysis(id),
);

final analysisCommentsProvider =
    FutureProvider.family<List<AnalysisComment>, String>(
      (ref, id) => ref.watch(communityRepositoryProvider).comments(id),
    );

final assetFeedProvider = FutureProvider.family<List<Analysis>, String>(
  (ref, symbol) => ref.watch(communityRepositoryProvider).assetFeed(symbol),
);

final communityAssetsProvider = FutureProvider<List<AssetOption>>(
  (ref) => ref.watch(communityRepositoryProvider).assets(),
);

class AnalysisDraftNotifier extends StateNotifier<AnalysisDraft> {
  AnalysisDraftNotifier() : super(const AnalysisDraft());

  void replace(AnalysisDraft draft) => state = draft;

  void update(AnalysisDraft Function(AnalysisDraft) fn) => state = fn(state);

  void reset() => state = const AnalysisDraft();
}

final analysisDraftProvider =
    StateNotifierProvider<AnalysisDraftNotifier, AnalysisDraft>(
      (ref) => AnalysisDraftNotifier(),
    );

final publishOutcomeProvider = StateProvider<PublishOutcome?>((ref) => null);
