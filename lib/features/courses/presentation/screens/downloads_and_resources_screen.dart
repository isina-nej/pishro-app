import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/courses_models.dart';
import '../../data/courses_repository.dart';

/// Screen/Course/DownloadsAndResources.
class DownloadsAndResourcesScreen extends ConsumerWidget {
  const DownloadsAndResourcesScreen({super.key, this.id = ''});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final curriculum = ref.watch(curriculumProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'دانلودها و منابع',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: curriculum.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(Space.page),
          child: Skeleton.box(height: 80),
        ),
        error: (e, _) => ErrorStateView(
          message: e is ApiException ? e.message : 'منابع بارگذاری نشد.',
          onRetry: () => ref.invalidate(curriculumProvider(id)),
        ),
        data: (curr) {
          final lessons = curr.lessons;
          if (lessons.isEmpty) {
            return const EmptyState(
              title: 'هیچ جلسه‌ای دانلود نشده',
              message: 'برای دسترسی آفلاین، جلسات را از این صفحه دانلود کنید.',
              icon: Icons.download_outlined,
            );
          }
          return ListView(
            padding: const EdgeInsets.all(Space.page),
            children: [
              Text(
                'دانلودهای جلسات',
                style: context.text.h3.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: Space.s1),
              Text(
                '${Fmt.fa('${curr.downloadedCount}')} از ${Fmt.fa('${curr.lessonCount}')} دانلودشده',
                style: context.text.caption.copyWith(color: c.textMuted),
              ),
              const SizedBox(height: Space.s4),
              for (final l in lessons)
                Padding(
                  padding: const EdgeInsets.only(bottom: Space.s3),
                  child: PishroCard(
                    child: Row(
                      children: [
                        Icon(
                          switch (l.state) {
                            LessonState.downloaded =>
                              Icons.download_done_rounded,
                            LessonState.downloadFailed =>
                              Icons.error_outline_rounded,
                            LessonState.current => Icons.downloading_rounded,
                            _ => Icons.download_rounded,
                          },
                          color: switch (l.state) {
                            LessonState.downloaded => c.success,
                            LessonState.downloadFailed => c.danger,
                            LessonState.current => c.actionPrimary,
                            _ => c.textMuted,
                          },
                        ),
                        const SizedBox(width: Space.s3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.title,
                                style: context.text.bodySmall.copyWith(
                                  color: c.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _statusLabel(l),
                                style: context.text.caption.copyWith(
                                  color: l.state == LessonState.downloadFailed
                                      ? c.danger
                                      : c.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: Space.s4),
              Text(
                'منابع دوره',
                style: context.text.h3.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: Space.s3),
              PishroCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ResourceRow(
                      Icons.picture_as_pdf_outlined,
                      'جزوه فصل اول.pdf',
                    ),
                    const SizedBox(height: Space.s3),
                    _ResourceRow(
                      Icons.table_chart_outlined,
                      'فایل اکسل محاسبه ریسک',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Space.s4),
              Text(
                'حجم اشغال‌شده: مقدار نمونه از فضای دستگاه',
                style: context.text.caption.copyWith(color: c.textMuted),
              ),
            ],
          );
        },
      ),
    );
  }

  String _statusLabel(Lesson l) {
    return switch (l.state) {
      LessonState.downloaded => 'دانلودشده',
      LessonState.downloadFailed => 'دانلود ناموفق — تلاش دوباره',
      LessonState.current => 'در حال دانلود',
      LessonState.locked => 'قفل',
      _ => 'دانلود',
    };
  }
}

class _ResourceRow extends StatelessWidget {
  const _ResourceRow(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        Icon(icon, color: c.actionPrimary),
        const SizedBox(width: Space.s3),
        Expanded(
          child: Text(
            label,
            style: context.text.bodySmall.copyWith(color: c.textPrimary),
          ),
        ),
      ],
    );
  }
}
