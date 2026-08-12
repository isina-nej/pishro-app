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

/// Screen/Course/DownloadsAndResources — جلسات دانلودشده + منابع.
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
          final downloaded = [
            for (final l in curr.lessons)
              if (l.state == LessonState.downloaded ||
                  l.state == LessonState.downloadFailed)
                l,
          ];
          return ListView(
            padding: const EdgeInsets.all(Space.page),
            children: [
              Text(
                'جلسات ذخیره‌شده',
                style: context.text.h3.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: Space.s3),
              if (downloaded.isEmpty)
                const EmptyState(
                  title: 'هنوز جلسه‌ای دانلود نشده',
                  icon: Icons.download_outlined,
                )
              else
                for (final l in downloaded)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Space.s3),
                    child: PishroCard(
                      child: Row(
                        children: [
                          Icon(
                            l.state == LessonState.downloadFailed
                                ? Icons.error_outline_rounded
                                : Icons.download_done_rounded,
                            color: l.state == LessonState.downloadFailed
                                ? c.danger
                                : c.success,
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
                                  l.state.label.isEmpty
                                      ? Fmt.duration(l.duration)
                                      : '${Fmt.duration(l.duration)} · ${l.state.label}',
                                  style: context.text.caption.copyWith(
                                    color: c.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              const SizedBox(height: Space.s5),
              Text(
                'منابع دوره',
                style: context.text.h3.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: Space.s3),
              PishroCard(
                child: Text(
                  'فایل‌های پیوست از سرور دوره هنوز منتشر نشده‌اند. به‌محض فعال‌شدن، همین‌جا فهرست می‌شوند.',
                  style: context.text.bodySmall.copyWith(
                    color: c.textSecondary,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
