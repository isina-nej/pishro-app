import '../../../core/utils/formatters.dart';

int? _int(Object? v) =>
    v is num ? v.toInt() : (v is String ? int.tryParse(v.trim()) : null);

double? _double(Object? v) =>
    v is num ? v.toDouble() : (v is String ? double.tryParse(v.trim()) : null);

bool _bool(Object? v, {bool fallback = false}) => switch (v) {
  bool b => b,
  num n => n != 0,
  'true' || '1' => true,
  'false' || '0' => false,
  _ => fallback,
};

/// Prisma `Json` columns come back as a decoded list through Prisma routes but
/// as a raw JSON *string* through the raw-SQL `GET /courses` handler, so both
/// shapes have to be tolerated.
List<String> _stringList(Object? v) {
  if (v is List) {
    return [
      for (final e in v)
        if (e != null && '$e'.trim().isNotEmpty) '$e'.trim(),
    ];
  }
  if (v is String && v.trim().startsWith('[')) {
    // Cheap parse — the column only ever holds a flat array of strings.
    final inner = v.trim().substring(1, v.trim().length - 1);
    return [
      for (final part in inner.split(','))
        if (part.replaceAll(RegExp(r'^\s*"|"\s*$'), '').trim().isNotEmpty)
          part.replaceAll(RegExp(r'^\s*"|"\s*$'), '').trim(),
    ];
  }
  return const [];
}

/// «۴٫۸» — Persian decimal separator, as the deck renders every rating.
String faDecimal(num value, {int digits = 1}) =>
    Fmt.fa(value.toStringAsFixed(digits)).replaceAll('.', '٫');

/// Folds Persian spelling variants so «بیت‌کوین»/«بیت کوین» and «تحلیل تکنیکال»
/// typed with an Arabic ك both match.
String normalizeCourseQuery(String input) => Fmt.toAscii(input)
    .toLowerCase()
    .replaceAll('ي', 'ی')
    .replaceAll('ى', 'ی')
    .replaceAll('ك', 'ک')
    .replaceAll('ة', 'ه')
    .replaceAll(RegExp(r'[\s‌‎‏_\-]'), '');

enum CourseLevel {
  beginner('مقدماتی'),
  intermediate('متوسط'),
  advanced('پیشرفته'),
  unspecified('نامشخص');

  const CourseLevel(this.label);

  final String label;

  static CourseLevel parse(Object? raw) => switch ('$raw'.toUpperCase()) {
    'BEGINNER' => CourseLevel.beginner,
    'INTERMEDIATE' => CourseLevel.intermediate,
    'ADVANCED' => CourseLevel.advanced,
    _ => CourseLevel.unspecified,
  };
}

enum CourseStatus {
  active,
  comingSoon,
  archived;

  static CourseStatus parse(Object? raw) => switch ('$raw'.toUpperCase()) {
    'COMING_SOON' => CourseStatus.comingSoon,
    'ARCHIVED' => CourseStatus.archived,
    _ => CourseStatus.active,
  };
}

/// The two purchasable packages the deck sells. VIP is what unlocks the
/// instructor chat — see [EnrolledCourse.hasInstructorChat].
enum PackageType {
  regular('بسته عادی'),
  vip('بسته VIP');

  const PackageType(this.label);

  final String label;

  static PackageType parse(Object? raw) =>
      '$raw'.toLowerCase() == 'vip' ? PackageType.vip : PackageType.regular;

  String get wire => name;
}

/// One row of `GET /courses` (raw `SELECT * FROM Course`).
class Course {
  const Course({
    required this.id,
    required this.title,
    required this.price,
    required this.discountPercent,
    required this.vipPrice,
    required this.coverUrl,
    required this.introVideoUrl,
    required this.rating,
    required this.ratingCount,
    required this.description,
    required this.durationLabel,
    required this.students,
    required this.videosCount,
    required this.instructor,
    required this.level,
    required this.status,
    required this.published,
    required this.featured,
    required this.categoryId,
    required this.categoryTitle,
    required this.learningGoals,
    required this.prerequisites,
    required this.hasChapters,
    required this.likes,
    required this.updatedAt,
    required this.createdAt,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    final category = (json['category'] as Map?)?.cast<String, dynamic>();
    return Course(
      id: '${json['id'] ?? ''}',
      title: '${json['subject'] ?? json['title'] ?? ''}',
      price: _int(json['price']) ?? 0,
      discountPercent: _int(json['discountPercent']),
      // No VIP column exists server-side yet; parsed so the flow lights up the
      // day it ships instead of needing a client release.
      vipPrice: _int(json['vipPrice'] ?? json['vip_price']),
      coverUrl: json['img'] as String?,
      introVideoUrl: json['introVideoUrl'] as String?,
      rating: _double(json['rating']),
      ratingCount: _int(json['ratingCount']),
      description: json['description'] as String?,
      durationLabel: json['time'] as String?,
      students: _int(json['students']),
      videosCount: _int(json['videosCount']),
      instructor: json['instructor'] as String?,
      level: CourseLevel.parse(json['level']),
      status: CourseStatus.parse(json['status']),
      published: _bool(json['published'], fallback: true),
      featured: _bool(json['featured']),
      categoryId: json['categoryId'] as String?,
      categoryTitle:
          category?['title'] as String? ?? json['categoryTitle'] as String?,
      learningGoals: _stringList(json['learningGoals']),
      prerequisites: _stringList(json['prerequisites']),
      hasChapters: _bool(json['hasChapters']),
      likes: _int(json['likes']) ?? 0,
      updatedAt: DateTime.tryParse('${json['updatedAt'] ?? ''}'),
      createdAt: DateTime.tryParse('${json['createdAt'] ?? ''}'),
    );
  }

  final String id;
  final String title;

  /// Toman, before [discountPercent].
  final int price;
  final int? discountPercent;

  /// Toman price of the VIP package, or null when the course has no VIP tier.
  final int? vipPrice;

  final String? coverUrl;
  final String? introVideoUrl;
  final double? rating;
  final int? ratingCount;
  final String? description;
  final String? durationLabel;
  final int? students;
  final int? videosCount;
  final String? instructor;
  final CourseLevel level;
  final CourseStatus status;
  final bool published;
  final bool featured;
  final String? categoryId;
  final String? categoryTitle;
  final List<String> learningGoals;
  final List<String> prerequisites;
  final bool hasChapters;
  final int likes;
  final DateTime? updatedAt;
  final DateTime? createdAt;

  /// Mirrors `getFinalCoursePrice` in `app/api/courses/free-enroll/route.ts` —
  /// the client must never show a total the server would reject.
  int get finalPrice => discountPercent == null || discountPercent == 0
      ? price
      : (price * (1 - discountPercent! / 100)).round().clamp(0, price);

  bool get isFree => finalPrice == 0;

  bool get hasVip => vipPrice != null && vipPrice! > 0;

  /// `GET /courses` hands back unpublished and archived rows; nothing else
  /// filters them, so the catalogue does it here.
  bool get isPublic => published && status != CourseStatus.archived;

  int priceFor(PackageType package) =>
      package == PackageType.vip ? (vipPrice ?? finalPrice) : finalPrice;

  String get instructorName => instructor?.trim().isNotEmpty == true
      ? instructor!.trim()
      : 'تیم آموزشی پیشرو سرمایه';

  bool matches(String query) {
    final q = normalizeCourseQuery(query);
    if (q.isEmpty) return false;
    return normalizeCourseQuery(title).contains(q) ||
        normalizeCourseQuery(instructorName).contains(q) ||
        normalizeCourseQuery(categoryTitle ?? '').contains(q) ||
        normalizeCourseQuery(description ?? '').contains(q);
  }
}

/// Derived from the catalogue: the backend exposes no public categories route,
/// so a bucket only gets a name when a course row carries one.
class CourseCategory {
  const CourseCategory({
    required this.id,
    required this.title,
    required this.courseCount,
    required this.featured,
    this.latestTitle,
  });

  final String id;
  final String title;
  final int courseCount;
  final bool featured;

  /// Newest course in the bucket. The deck pairs each category with a second
  /// line; there is no category description anywhere in the payload, so this
  /// stands in for it with real data instead of invented copy.
  final String? latestTitle;
}

enum PriceBand {
  any('همه'),
  free('رایگان'),
  belowOneMillion('کمتر از ۱ میلیون تومان'),
  oneToThreeMillion('۱ تا ۳ میلیون تومان'),
  aboveThreeMillion('بیشتر از ۳ میلیون تومان');

  const PriceBand(this.label);

  final String label;

  bool contains(int toman) => switch (this) {
    PriceBand.any => true,
    PriceBand.free => toman == 0,
    PriceBand.belowOneMillion => toman > 0 && toman < 1000000,
    PriceBand.oneToThreeMillion => toman >= 1000000 && toman <= 3000000,
    PriceBand.aboveThreeMillion => toman > 3000000,
  };
}

enum CourseSort {
  newest('جدیدترین'),
  popular('محبوب‌ترین'),
  bestSelling('پرفروش‌ترین');

  const CourseSort(this.label);

  final String label;
}

/// Screen/Courses/Filters — «نوع بسته · سطح · بازه قیمت · وضعیت».
class CourseFilters {
  const CourseFilters({
    this.packageType,
    this.level,
    this.priceBand = PriceBand.any,
    this.sort = CourseSort.newest,
    this.categoryId,
    this.minRating,
  });

  final PackageType? packageType;
  final CourseLevel? level;
  final PriceBand priceBand;
  final CourseSort sort;
  final String? categoryId;
  final double? minRating;

  CourseFilters copyWith({
    PackageType? packageType,
    CourseLevel? level,
    PriceBand? priceBand,
    CourseSort? sort,
    String? categoryId,
    double? minRating,
    bool clearPackageType = false,
    bool clearLevel = false,
    bool clearCategory = false,
    bool clearRating = false,
  }) => CourseFilters(
    packageType: clearPackageType ? null : (packageType ?? this.packageType),
    level: clearLevel ? null : (level ?? this.level),
    priceBand: priceBand ?? this.priceBand,
    sort: sort ?? this.sort,
    categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
    minRating: clearRating ? null : (minRating ?? this.minRating),
  );

  /// Sort is a presentation choice, not a filter — the deck's
  /// «۲ فیلتر انتخاب‌شده» counter excludes it.
  int get selectedCount => [
    packageType != null,
    level != null,
    priceBand != PriceBand.any,
    categoryId != null,
    minRating != null,
  ].where((e) => e).length;

  bool get isEmpty => selectedCount == 0;

  bool allows(Course course) {
    if (packageType == PackageType.vip && !course.hasVip) return false;
    if (level != null && course.level != level) return false;
    if (!priceBand.contains(course.finalPrice)) return false;
    if (categoryId != null && course.categoryId != categoryId) return false;
    if (minRating != null && (course.rating ?? 0) < minRating!) return false;
    return true;
  }

  List<Course> apply(Iterable<Course> courses, {String query = ''}) {
    final matched = [
      for (final c in courses)
        if (allows(c) && (query.trim().isEmpty || c.matches(query))) c,
    ];
    matched.sort(switch (sort) {
      // No sales figures are exposed, so «پرفروش‌ترین» ranks by enrolled
      // students — the closest real signal rather than an invented one.
      CourseSort.newest => (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
        a.createdAt ?? DateTime(0),
      ),
      CourseSort.popular => (a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0),
      CourseSort.bestSelling => (a, b) => (b.students ?? 0).compareTo(
        a.students ?? 0,
      ),
    });
    return matched;
  }
}

/// Chapter/LessonState — the seven states Screen/Course/Chapters documents.
/// Each carries its own label because the deck forbids an icon-only cue just
/// as firmly as a colour-only one.
enum LessonState {
  completed('تکمیل‌شده'),
  current('در حال پخش'),
  available(''),
  downloaded('دانلودشده'),
  locked('قفل'),
  preview('پیش‌نمایش'),
  downloadFailed('دانلود ناموفق بود — تلاش دوباره');

  const LessonState(this.label);

  final String label;

  bool get isPlayable => this != LessonState.locked;
}

class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.duration,
    required this.state,
    this.description,
    this.videoId,
  });

  final String id;
  final String title;
  final Duration duration;
  final LessonState state;
  final String? description;
  final String? videoId;

  Lesson copyWith({LessonState? state}) => Lesson(
    id: id,
    title: title,
    duration: duration,
    state: state ?? this.state,
    description: description,
    videoId: videoId,
  );
}

class Chapter {
  const Chapter({required this.id, required this.title, required this.lessons});

  final String id;
  final String title;
  final List<Lesson> lessons;

  Duration get duration =>
      lessons.fold(Duration.zero, (sum, l) => sum + l.duration);

  String get summary =>
      '${Fmt.fa('${lessons.length}')} درس · ${Fmt.duration(duration)}';
}

/// The curriculum of one course.
class Curriculum {
  const Curriculum({required this.chapters});

  final List<Chapter> chapters;

  List<Lesson> get lessons => [for (final c in chapters) ...c.lessons];

  int get lessonCount => lessons.length;

  int get completedCount =>
      lessons.where((l) => l.state == LessonState.completed).length;

  int get downloadedCount =>
      lessons.where((l) => l.state == LessonState.downloaded).length;

  Duration get totalDuration =>
      chapters.fold(Duration.zero, (sum, c) => sum + c.duration);

  Lesson? get currentLesson {
    for (final l in lessons) {
      if (l.state == LessonState.current) return l;
    }
    for (final l in lessons) {
      if (l.state == LessonState.available) return l;
    }
    return lessons.isEmpty ? null : lessons.first;
  }

  Chapter? chapterOf(String lessonId) {
    for (final c in chapters) {
      if (c.lessons.any((l) => l.id == lessonId)) return c;
    }
    return null;
  }

  Lesson? lessonById(String id) {
    for (final l in lessons) {
      if (l.id == id) return l;
    }
    return null;
  }
}

/// One row of `GET /user/enrolled-courses`.
class EnrolledCourse {
  const EnrolledCourse({
    required this.enrollmentId,
    required this.course,
    required this.progressPercent,
    required this.packageType,
    required this.enrolledAt,
    required this.completedAt,
    required this.lastAccessAt,
    required this.lessonsTotal,
    required this.lessonsCompleted,
    required this.timeSpent,
  });

  factory EnrolledCourse.fromJson(Map<String, dynamic> json) {
    final course =
        (json['course'] as Map?)?.cast<String, dynamic>() ?? const {};
    final progress = (_int(json['progress']) ?? 0).clamp(0, 100);
    final total = _int(course['videosCount']) ?? 0;
    return EnrolledCourse(
      enrollmentId: '${json['id'] ?? ''}',
      course: Course.fromJson(course),
      progressPercent: progress,
      // The Enrollment table has no package column yet. Defaulting to regular
      // keeps the VIP chat closed until the backend actually says otherwise.
      packageType: PackageType.parse(json['packageType'] ?? json['package']),
      enrolledAt: DateTime.tryParse('${json['enrolledAt'] ?? ''}'),
      completedAt: DateTime.tryParse('${json['completedAt'] ?? ''}'),
      lastAccessAt: DateTime.tryParse('${json['lastAccessAt'] ?? ''}'),
      lessonsTotal: total,
      lessonsCompleted: (total * progress / 100).round(),
      timeSpent: Duration(minutes: _int(json['timeSpentMinutes']) ?? 0),
    );
  }

  final String enrollmentId;
  final Course course;
  final int progressPercent;
  final PackageType packageType;
  final DateTime? enrolledAt;
  final DateTime? completedAt;
  final DateTime? lastAccessAt;
  final int lessonsTotal;
  final int lessonsCompleted;
  final Duration timeSpent;

  double get progress => progressPercent / 100;

  bool get isCompleted => progressPercent >= 100 || completedAt != null;

  bool get isInProgress => !isCompleted && progressPercent > 0;

  /// Deck rule: «گفت‌وگوی مدرس فقط روی دوره VIP». The single source of truth
  /// for the chat entry point, its route guard and its access notice.
  bool get hasInstructorChat => packageType == PackageType.vip;

  /// «جلسه ۵ از ۱۲»
  String get lessonProgressLabel => lessonsTotal == 0
      ? '${Fmt.fa('$progressPercent')}٪ تکمیل‌شده'
      : 'جلسه ${Fmt.fa('$lessonsCompleted')} از ${Fmt.fa('$lessonsTotal')}';
}

enum MyCoursesTab {
  inProgress('در حال یادگیری'),
  completed('تکمیل‌شده'),
  all('همه');

  const MyCoursesTab(this.label);

  final String label;

  bool accepts(EnrolledCourse e) => switch (this) {
    MyCoursesTab.inProgress => !e.isCompleted,
    MyCoursesTab.completed => e.isCompleted,
    MyCoursesTab.all => true,
  };
}
