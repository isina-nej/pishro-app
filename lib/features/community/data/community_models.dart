import 'package:flutter/foundation.dart';

import '../../../shared/widgets/pishro_badge.dart' show RiskLevel;

/// Models for 08_Community. There is no backend for this module, so nothing
/// here parses JSON yet — the shapes are driven by the deck alone and the
/// eventual HTTP repository owns the mapping.

// ---------------------------------------------------------------- enums ----

enum AnalysisKind {
  technical('تکنیکال'),
  fundamental('بنیادی'),
  onchain('آنچین');

  const AnalysisKind(this.label);
  final String label;
}

enum Timeframe {
  short('کوتاه‌مدت'),
  medium('میان‌مدت'),
  long('بلندمدت');

  const Timeframe(this.label);
  final String label;
}

/// Home filter chips — «همه · دنبال‌شده‌ها · تحلیل تکنیکال · آنچین».
enum AnalysisFilter {
  all('همه'),
  following('دنبال‌شده‌ها'),
  technical('تحلیل تکنیکال'),
  onchain('آنچین');

  const AnalysisFilter(this.label);
  final String label;
}

enum FollowingSort {
  newest('جدیدترین'),
  lastUpdated('آخرین به‌روزرسانی');

  const FollowingSort(this.label);
  final String label;
}

enum LeaderboardPeriod {
  month('این ماه'),
  week('این هفته'),
  allTime('همه دوره‌ها');

  const LeaderboardPeriod(this.label);
  final String label;
}

/// The deck ranks on user rating and community participation only — there is
/// deliberately no return/ROI metric («بدون ROI جعلی»).
enum LeaderboardMetric {
  userRating('امتیاز کاربران'),
  participation('مشارکت جامعه');

  const LeaderboardMetric(this.label);
  final String label;
}

enum SearchScope {
  all('همه'),
  analysts('تحلیلگران'),
  analyses('تحلیل‌ها');

  const SearchScope(this.label);
  final String label;
}

enum CommentSort {
  newest('جدیدترین'),
  mostHelpful('مفیدترین'),
  oldest('قدیمی‌ترین');

  const CommentSort(this.label);
  final String label;
}

/// Same moderation vocabulary as the News module.
enum ModerationState {
  published(null),
  pendingModeration('در انتظار بررسی'),
  rejected('رد شد');

  const ModerationState(this.label);
  final String? label;
}

enum AnalysisAccess { public, premiumLocked, premiumUnlocked }

enum SubscriptionStatus {
  active('فعال'),
  pending('در انتظار'),
  ended('پایان‌یافته'),
  cancelled('لغوشده');

  const SubscriptionStatus(this.label);
  final String label;
}

/// «نامشخص هرگز = ناموفق» — an unresolved payment is its own state and must
/// never be rendered as a failure.
enum SubscriptionOutcomeStatus { active, pending, unknown }

enum PublishStatus { published, pendingModeration, failed }

enum AnalysisVisibility {
  public('عمومی'),
  subscribersOnly('فقط مشترکان');

  const AnalysisVisibility(this.label);
  final String label;
}

// --------------------------------------------------------------- models ----

/// One verification claim. The deck shows these as *separate* chips
/// («نشان‌های جدا») rather than merging them into a single blue tick.
@immutable
class AnalystBadge {
  const AnalystBadge({required this.label, required this.granted, this.detail});

  final String label;
  final bool granted;

  /// e.g. «ناقص» for a partially completed document check.
  final String? detail;

  String get text => detail == null ? label : '$label: $detail';
}

@immutable
class Analyst {
  const Analyst({
    required this.id,
    required this.displayName,
    required this.specialty,
    required this.publishedCount,
    required this.rating,
    required this.reviewCount,
    required this.followerCount,
    required this.activeSinceJalaliYear,
    required this.bio,
    required this.badges,
    required this.disclosure,
    this.isFollowing = false,
    this.isIdentityVerified = false,
    this.isSuspended = false,
  });

  final String id;
  final String displayName;

  /// «تحلیل بنیادی» — free text, not the [AnalysisKind] enum.
  final String specialty;
  final int publishedCount;
  final double rating;
  final int reviewCount;
  final int followerCount;
  final int activeSinceJalaliYear;
  final String bio;
  final List<AnalystBadge> badges;

  /// «افشای منافع» paragraph shown on the profile.
  final String disclosure;
  final bool isFollowing;
  final bool isIdentityVerified;

  /// «این پروفایل موقتاً معلق شده است» — published work stays readable.
  final bool isSuspended;

  Analyst copyWith({bool? isFollowing}) => Analyst(
    id: id,
    displayName: displayName,
    specialty: specialty,
    publishedCount: publishedCount,
    rating: rating,
    reviewCount: reviewCount,
    followerCount: followerCount,
    activeSinceJalaliYear: activeSinceJalaliYear,
    bio: bio,
    badges: badges,
    disclosure: disclosure,
    isFollowing: isFollowing ?? this.isFollowing,
    isIdentityVerified: isIdentityVerified,
    isSuspended: isSuspended,
  );
}

/// Author stub carried by every analysis/comment, so a list never has to fetch
/// full profiles.
@immutable
class AuthorRef {
  const AuthorRef({required this.id, required this.displayName});
  final String id;
  final String displayName;
}

/// One of the three equally weighted outlooks. There is no bull/bear colour and
/// no probability — «سناریوها هم‌وزن، بدون رنگ اختصاصی افزایشی».
@immutable
class Scenario {
  const Scenario({required this.label, this.note});
  final String label;
  final String? note;
}

@immutable
class Analysis {
  const Analysis({
    required this.id,
    required this.author,
    required this.publishedAt,
    required this.title,
    required this.assetSymbol,
    required this.kind,
    this.timeframe,
    this.risk,
    this.summary,
    this.body,
    this.scenarios = const [],
    this.invalidation,
    this.access = AnalysisAccess.public,
    this.helpfulCount,
    this.commentCount,
    this.isSaved = false,
    this.isNew = false,
    this.isRemoved = false,
    this.dataOutdated = false,
  });

  final String id;
  final AuthorRef author;
  final DateTime publishedAt;
  final String title;

  /// Latin ticker — «BTC». Never localised to Persian digits/letters.
  final String assetSymbol;
  final AnalysisKind kind;
  final Timeframe? timeframe;
  final RiskLevel? risk;
  final String? summary;
  final String? body;
  final List<Scenario> scenarios;

  /// «شرط بی‌اعتبارشدن تحلیل».
  final String? invalidation;
  final AnalysisAccess access;

  /// Null where the deck shows no engagement figures at all (preview, locked).
  final int? helpfulCount;
  final int? commentCount;
  final bool isSaved;

  /// Following feed marks unread items «جدید».
  final bool isNew;
  final bool isRemoved;

  /// «داده دارایی مرتبط به‌روزرسانی نشده — نسخه ذخیره‌شده».
  final bool dataOutdated;

  bool get isLocked => access == AnalysisAccess.premiumLocked;
}

@immutable
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.analystId,
    required this.displayName,
    required this.analysisCount,
    required this.reviewCount,
    required this.rating,
  });

  final int rank;
  final String analystId;
  final String displayName;
  final int analysisCount;
  final int reviewCount;
  final double rating;
  // Intentionally no return/ROI field: the deck forbids inventing one.
}

@immutable
class LeaderboardPage {
  const LeaderboardPage({
    required this.entries,
    required this.performanceDataAvailable,
    required this.notice,
  });

  final List<LeaderboardEntry> entries;

  /// Always false until a verified performance feed exists.
  final bool performanceDataAvailable;
  final String notice;
}

@immutable
class CommunitySearchResults {
  const CommunitySearchResults({
    required this.analysts,
    required this.analyses,
  });
  final List<Analyst> analysts;
  final List<Analysis> analyses;

  bool get isEmpty => analysts.isEmpty && analyses.isEmpty;
}

/// «کیفیت تحلیل» / «شفافیت» / «توضیح ریسک». No profitability category —
/// «بدون معیار میزان سوددهی».
@immutable
class CategoryScore {
  const CategoryScore({required this.label, required this.value});
  final String label;

  /// 0..1
  final double value;
}

@immutable
class AnalystReview {
  const AnalystReview({
    required this.id,
    required this.authorName,
    required this.stars,
    required this.body,
    this.isVerifiedSubscriber = false,
  });

  final String id;
  final String authorName;
  final int stars;
  final String body;
  final bool isVerifiedSubscriber;
}

@immutable
class AnalystRatingSummary {
  const AnalystRatingSummary({
    required this.average,
    required this.reviewCount,
    required this.categories,
    required this.reviews,
    this.canRate = true,
  });

  final double average;
  final int reviewCount;
  final List<CategoryScore> categories;
  final List<AnalystReview> reviews;

  /// «شما به‌عنوان دنبال‌کننده واجد شرایط ثبت امتیاز هستید».
  final bool canRate;
}

@immutable
class AnalysisComment {
  const AnalysisComment({
    required this.id,
    required this.authorName,
    required this.publishedAt,
    required this.body,
    this.replyCount = 0,
    this.moderation = ModerationState.published,
  });

  final String id;
  final String authorName;
  final DateTime publishedAt;
  final String body;
  final int replyCount;
  final ModerationState moderation;
}

@immutable
class SignalOffer {
  const SignalOffer({
    required this.id,
    required this.provider,
    required this.coverage,
    required this.cadence,
    required this.priceToman,
    this.horizon,
    this.isSubscribed = false,
    this.isEligible = true,
    this.performanceDataAvailable = false,
  });

  final String id;
  final AuthorRef provider;

  /// «BTC، ETH»
  final String coverage;

  /// «هفتگی»
  final String cadence;

  /// «میان‌مدت»
  final String? horizon;
  final int priceToman;
  final bool isSubscribed;

  /// «شرایط دریافت اشتراک را بررسی کنید» when false.
  final bool isEligible;

  /// Always false so far; the tile renders the «داده عملکرد تأییدشده در دسترس
  /// نیست» notice instead of a fabricated track record.
  final bool performanceDataAvailable;
}

@immutable
class Subscription {
  const Subscription({
    required this.id,
    required this.providerName,
    required this.status,
    required this.priceToman,
    required this.period,
    this.renewsAt,
    this.autoRenew = true,
  });

  final String id;
  final String providerName;
  final SubscriptionStatus status;
  final int priceToman;

  /// «ماهانه»
  final String period;
  final DateTime? renewsAt;
  final bool autoRenew;
}

@immutable
class SubscriptionOutcome {
  const SubscriptionOutcome({required this.status, required this.message});
  final SubscriptionOutcomeStatus status;
  final String message;
}

@immutable
class AssetOption {
  const AssetOption({required this.symbol, required this.name});
  final String symbol;
  final String name;

  /// «Bitcoin (BTC)» — Latin, per the deck.
  String get label => '$name ($symbol)';
}

/// The CreateAnalysis → Editor → Preview → PublishResult flow state.
///
/// [holdsAsset] and [isSponsored] are deliberately nullable and start null:
/// «بدون پیش‌انتخاب افشا» — neither disclosure answer may be pre-selected.
@immutable
class AnalysisDraft {
  const AnalysisDraft({
    this.kind = AnalysisKind.technical,
    this.asset,
    this.title = '',
    this.timeframe = Timeframe.short,
    this.risk = RiskLevel.medium,
    this.holdsAsset,
    this.isSponsored,
    this.summary = '',
    this.body = '',
    this.scenarios = const [],
    this.invalidation = '',
    this.sources = '',
    this.visibility = AnalysisVisibility.public,
  });

  final AnalysisKind kind;
  final AssetOption? asset;
  final String title;
  final Timeframe timeframe;
  final RiskLevel risk;
  final bool? holdsAsset;
  final bool? isSponsored;
  final String summary;
  final String body;
  final List<Scenario> scenarios;
  final String invalidation;
  final String sources;
  final AnalysisVisibility visibility;

  /// Both disclosure questions must be answered before the editor opens.
  bool get disclosureComplete => holdsAsset != null && isSponsored != null;

  bool get canContinue =>
      title.trim().isNotEmpty && asset != null && disclosureComplete;

  int get characterCount => summary.length + body.length;

  AnalysisDraft copyWith({
    AnalysisKind? kind,
    AssetOption? asset,
    String? title,
    Timeframe? timeframe,
    RiskLevel? risk,
    bool? holdsAsset,
    bool? isSponsored,
    String? summary,
    String? body,
    List<Scenario>? scenarios,
    String? invalidation,
    String? sources,
    AnalysisVisibility? visibility,
  }) => AnalysisDraft(
    kind: kind ?? this.kind,
    asset: asset ?? this.asset,
    title: title ?? this.title,
    timeframe: timeframe ?? this.timeframe,
    risk: risk ?? this.risk,
    holdsAsset: holdsAsset ?? this.holdsAsset,
    isSponsored: isSponsored ?? this.isSponsored,
    summary: summary ?? this.summary,
    body: body ?? this.body,
    scenarios: scenarios ?? this.scenarios,
    invalidation: invalidation ?? this.invalidation,
    sources: sources ?? this.sources,
    visibility: visibility ?? this.visibility,
  );
}

@immutable
class PublishOutcome {
  const PublishOutcome({
    required this.status,
    required this.title,
    required this.visibility,
    this.analysisId,
    this.publishedAt,
  });

  final PublishStatus status;
  final String title;
  final AnalysisVisibility visibility;

  /// «AN-7734» — absent while pending moderation or on failure.
  final String? analysisId;
  final DateTime? publishedAt;
}
