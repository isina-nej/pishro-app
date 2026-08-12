import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'courses_models.dart';

/// Courses data access.
///
/// Two backend gaps shape this class and are documented at each call site:
/// `GET /courses` is unpaginated, unfiltered and includes unpublished rows, and
/// there is no public endpoint for a single course, for categories, or for a
/// course's chapters/lessons (only admin-gated ones).
class CoursesRepository {
  const CoursesRepository(this._api);

  final ApiClient _api;

  /// Whole catalogue. The handler is `SELECT * FROM Course ORDER BY createdAt
  /// DESC` with no `WHERE published` and no `LIMIT`, so unpublished and
  /// archived rows arrive too — dropping them here is the only thing standing
  /// between a draft course and a customer's checkout screen.
  Future<List<Course>> fetchCatalog() async {
    final raw = await _api.get<List<dynamic>>('/courses');
    final seen = <String>{};
    final out = <Course>[];
    for (final row in raw) {
      if (row is! Map) continue;
      final course = Course.fromJson(row.cast<String, dynamic>());
      if (course.id.isEmpty || !course.isPublic) continue;
      if (!seen.add(course.id)) continue;
      out.add(course);
    }
    out.sort(
      (a, b) =>
          (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
    );
    return out;
  }

  /// `GET /user/enrolled-courses` — paginated envelope `{items, pagination}`.
  Future<List<EnrolledCourse>> fetchEnrolled({int page = 1, int limit = 20}) async {
    final data = await _api.get<Map<String, dynamic>>(
      '/user/enrolled-courses',
      query: {'page': page, 'limit': limit},
    );
    return [
      for (final row in (data['items'] as List? ?? const []))
        if (row is Map) EnrolledCourse.fromJson(row.cast<String, dynamic>()),
    ];
  }

  /// `POST /courses/free-enroll` — server re-checks that the final price is 0.
  Future<void> freeEnroll(String courseId) =>
      _api.post<Map<String, dynamic>>(
        '/courses/free-enroll',
        body: {'courseId': courseId},
      );

  /// `POST /courses/like` — `type` is LIKE or DISLIKE, toggling on repeat.
  Future<void> like(String courseId, {bool dislike = false}) =>
      _api.post<Map<String, dynamic>>(
        '/courses/like',
        body: {'courseId': courseId, 'type': dislike ? 'DISLIKE' : 'LIKE'},
      );

  /// The enrollment handler is a PATCH, not the POST the module brief lists.
  Future<void> updateProgress({
    required String enrollmentId,
    int? progress,
    bool completed = false,
  }) => _api.patch<Map<String, dynamic>>(
    '/user/enrollment',
    body: {
      'enrollmentId': enrollmentId,
      if (progress != null) 'progress': progress,
      if (completed) 'completed': true,
    },
  );

  /// `POST /video/token` — a 30-second playback token, so it is fetched right
  /// before play rather than cached.
  Future<String> streamToken(String videoId) async {
    final data = await _api.post<Map<String, dynamic>>(
      '/video/token',
      body: {'videoId': videoId},
    );
    return '${data['token']}';
  }

  /// Playback URL for a lesson — `GET /user/lessons/{id}/stream` range-streams
  /// the file itself, so the player is handed the URL, not a body.
  String lessonStreamPath(String lessonId) => '/user/lessons/$lessonId/stream';

  /// Chapters and lessons only exist behind `/api/admin/*`. Until a public
  /// route lands this is sample data, and every screen that shows it labels it
  /// with `PishroBadge.sampleData()`.
  Future<Curriculum> fetchCurriculum(Course course) async =>
      sampleCurriculum(course);
}

/// Deterministic stand-in curriculum. Derived from the course's own
/// `videosCount` so the lesson totals at least agree with the catalogue.
Curriculum sampleCurriculum(Course course) {
  final total = (course.videosCount ?? 12).clamp(2, 40);
  final firstChapter = (total / 2).ceil();
  const titles = [
    'مقدمه‌ای بر ساختار بازارهای مالی و بازیگران اصلی آن',
    'عرضه و تقاضا و تأثیر آن بر قیمت',
    'آشنایی با کارگزاری‌ها و انواع حساب معاملاتی',
    'تمرین شناسایی روند بازار',
    'جلسه جمع‌بندی فصل اول',
    'آشنایی با الگوهای بازگشتی و ادامه‌دهنده',
    'پیش‌نمایش رایگان فصل الگوهای قیمتی',
  ];
  // The seven documented lesson states, in the order Screen/Course/Chapters
  // lays them out.
  const states = [
    LessonState.completed,
    LessonState.current,
    LessonState.available,
    LessonState.downloaded,
    LessonState.downloadFailed,
    LessonState.locked,
    LessonState.preview,
  ];

  Lesson build(int index) => Lesson(
    id: '${course.id}-l${index + 1}',
    title: titles[index % titles.length],
    duration: Duration(minutes: 8 + (index % 5) * 3),
    state: states[index % states.length],
    videoId: '${course.id}-v${index + 1}',
  );

  return Curriculum(
    chapters: [
      Chapter(
        id: '${course.id}-c1',
        title: 'فصل ۱ — آشنایی با بازار',
        lessons: [for (var i = 0; i < firstChapter; i++) build(i)],
      ),
      Chapter(
        id: '${course.id}-c2',
        title: 'فصل ۲ — الگوهای قیمتی',
        lessons: [for (var i = firstChapter; i < total; i++) build(i)],
      ),
    ],
  );
}

final coursesRepositoryProvider = Provider<CoursesRepository>(
  (ref) => CoursesRepository(ref.watch(apiClientProvider)),
);

final courseCatalogProvider = FutureProvider<List<Course>>(
  (ref) => ref.watch(coursesRepositoryProvider).fetchCatalog(),
);

/// Categories are folded out of the catalogue because no public categories
/// endpoint exists. Buckets whose rows carry no title are dropped rather than
/// shown as an opaque cuid.
final courseCategoriesProvider = FutureProvider<List<CourseCategory>>((ref) async {
  final courses = await ref.watch(courseCatalogProvider.future);
  final counts = <String, int>{};
  final titles = <String, String>{};
  final featured = <String>{};
  for (final c in courses) {
    final id = c.categoryId;
    if (id == null || id.isEmpty) continue;
    counts[id] = (counts[id] ?? 0) + 1;
    if (c.categoryTitle != null) titles[id] = c.categoryTitle!;
    if (c.featured) featured.add(id);
  }
  final out = [
    for (final e in counts.entries)
      if (titles[e.key] case final title?)
        CourseCategory(
          id: e.key,
          title: title,
          courseCount: e.value,
          featured: featured.contains(e.key),
        ),
  ]..sort((a, b) => b.courseCount.compareTo(a.courseCount));
  return out;
});

/// No `GET /courses/{id}` exists, so details resolve out of the catalogue.
final courseProvider = FutureProvider.family<Course, String>((ref, id) async {
  final courses = await ref.watch(courseCatalogProvider.future);
  for (final c in courses) {
    if (c.id == id) return c;
  }
  throw const NotFoundException('این دوره یافت نشد.');
});

final enrolledCoursesProvider = FutureProvider<List<EnrolledCourse>>(
  (ref) => ref.watch(coursesRepositoryProvider).fetchEnrolled(),
);

final enrollmentProvider =
    FutureProvider.family<EnrolledCourse?, String>((ref, courseId) async {
  final enrolled = await ref.watch(enrolledCoursesProvider.future);
  for (final e in enrolled) {
    if (e.course.id == courseId) return e;
  }
  return null;
});

final curriculumProvider =
    FutureProvider.family<Curriculum, String>((ref, courseId) async {
  final course = await ref.watch(courseProvider(courseId).future);
  return ref.watch(coursesRepositoryProvider).fetchCurriculum(course);
});

/// Search query + filters are flow state, shared between Search, Filters and
/// SearchResults.
final courseQueryProvider = StateProvider<String>((ref) => '');

final courseFiltersProvider =
    StateProvider<CourseFilters>((ref) => const CourseFilters());

/// «جست‌وجوهای اخیر» — session-scoped; persisting them is an Account concern.
final recentSearchesProvider =
    NotifierProvider<RecentSearches, List<String>>(RecentSearches.new);

class RecentSearches extends Notifier<List<String>> {
  @override
  List<String> build() => const ['تحلیل تکنیکال', 'مدیریت ریسک', 'ارز دیجیتال'];

  void add(String term) {
    final t = term.trim();
    if (t.isEmpty) return;
    state = [t, ...state.where((e) => e != t)].take(8).toList();
  }

  void clear() => state = const [];
}

/// Search results honour both the query and the filter sheet.
final searchResultsProvider = FutureProvider<List<Course>>((ref) async {
  final courses = await ref.watch(courseCatalogProvider.future);
  return ref
      .watch(courseFiltersProvider)
      .apply(courses, query: ref.watch(courseQueryProvider));
});
