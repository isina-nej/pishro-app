/// Every route path in one place, so module agents never invent a string that
/// another module already owns.
abstract final class Routes {
  // ---- Auth (outside the tab shell) ----
  static const splash = '/';
  static const welcome = '/welcome';
  static const onboarding = '/onboarding';
  static const onboarding2 = '/onboarding/2';
  static const onboarding3 = '/onboarding/3';
  static const login = '/login';
  static const signup = '/signup';
  static const otp = '/otp';
  static const forgotPassword = '/forgot-password';

  // ---- Tab roots ----
  static const courses = '/courses';
  static const news = '/news';
  static const investment = '/investment';
  static const market = '/market';
  static const account = '/account';

  /// Tab shown after a successful login — «تب پیش‌فرض بعد از ورود: دوره‌ها».
  static const homeAfterLogin = courses;

  // ---- Courses ----
  static const courseCategories = '$courses/categories';
  static const courseSearch = '$courses/search';
  static const courseSearchResults = '$courses/search/results';
  static const myCourses = '$courses/mine';
  static String courseDetails(String id) => '$courses/$id';
  static String packageComparison(String id) => '$courses/$id/packages';
  static String learningDashboard(String id) => '$courses/$id/learn';
  static String chapters(String id) => '$courses/$id/chapters';
  static String lesson(String courseId, String lessonId) =>
      '$courses/$courseId/lessons/$lessonId';
  static String downloads(String id) => '$courses/$id/downloads';
  static String instructorChat(String id) => '$courses/$id/chat';
  static String completion(String id) => '$courses/$id/completion';
  static String certificate(String id) => '$courses/$id/certificate';

  // ---- Checkout ----
  static const checkout = '/checkout';
  static const checkoutPaymentMethod = '$checkout/payment-method';
  static const checkoutDiscount = '$checkout/discount';
  static const checkoutProcessing = '$checkout/processing';
  static const checkoutSuccess = '$checkout/success';
  static const checkoutFailure = '$checkout/failure';

  // ---- News ----
  static const newsTrending = '$news/trending';
  static const newsCategories = '$news/categories';
  static const newsSearch = '$news/search';
  static const newsSaved = '$news/saved';
  static String newsDetails(String slug) => '$news/$slug';
  static String newsComments(String slug) => '$news/$slug/comments';

  // ---- Investment ----
  static const planCatalog = '$investment/plans';
  static const planComparison = '$investment/compare';
  static const calculator = '$investment/calculator';
  static const riskDisclosure = '$investment/risk';
  static const terms = '$investment/terms';
  static const kyc = '$investment/kyc';
  static const amountEntry = '$investment/amount';
  static const fundingSource = '$investment/funding';
  static const finalReview = '$investment/review';
  static const contractConfirmation = '$investment/contract';
  static const investmentProcessing = '$investment/processing';
  static const investmentSuccess = '$investment/success';
  static const activeInvestments = '$investment/active';
  static String planDetails(String id) => '$investment/plans/$id';
  static String investmentDetails(String id) => '$investment/active/$id';
  static String paymentSchedule(String id) => '$investment/active/$id/schedule';

  // ---- Market ----
  static const allAssets = '$market/all';
  static const favorites = '$market/favorites';
  static const marketTrending = '$market/trending';
  static const topGainers = '$market/gainers';
  static const topLosers = '$market/losers';
  static const marketSearch = '$market/search';
  static const priceAlerts = '$market/alerts';
  static String coinDetails(String id) => '$market/$id';
  static String priceChart(String id) => '$market/$id/chart';
  static String statistics(String id) => '$market/$id/stats';
  static String historicalData(String id) => '$market/$id/history';

  // ---- Community (nested under Market tab; the deck keeps Market active) ----
  static const community = '$market/community';
  static const followingFeed = '$community/following';
  static const recommendedAnalysts = '$community/analysts';
  static const leaderboard = '$community/leaderboard';
  static const communitySearch = '$community/search';
  static const premiumSignals = '$community/signals';
  static const subscriptions = '$community/subscriptions';
  static const createAnalysis = '$community/create';
  static const analysisEditor = '$community/create/editor';
  static const analysisPreview = '$community/create/preview';
  static const publishResult = '$community/create/result';
  static String analystProfile(String id) => '$community/analysts/$id';
  static String analystRatings(String id) => '$community/analysts/$id/ratings';
  static String analysisDetails(String id) => '$community/analysis/$id';
  static String analysisComments(String id) =>
      '$community/analysis/$id/comments';

  // ---- Account ----
  static const profile = '$account/profile';
  static const editProfile = '$account/profile/edit';
  static const kycOverview = '$account/kyc';
  static const kycVerification = '$account/kyc/verify';
  static const wallet = '$account/wallet';
  static const walletTransactions = '$account/wallet/transactions';
  static const pishroCoin = '$account/coin';
  static const purchaseHistory = '$account/purchases';
  static const investmentHistory = '$account/investments';
  static const accountSubscriptions = '$account/subscriptions';
  static const savedItems = '$account/saved';
  static const notifications = '$account/notifications';
  static const security = '$account/security';
  static const devices = '$account/devices';
  static const privacy = '$account/privacy';
  static const support = '$account/support';
  static const referrals = '$account/referrals';
  static const preferences = '$account/preferences';
  static const legalDocuments = '$account/legal';
}
