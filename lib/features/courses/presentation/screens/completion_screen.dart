import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/courses_repository.dart';

/// Screen/Course/Completion — پایان دوره، دعوت به گواهی.
class CompletionScreen extends ConsumerWidget {
  const CompletionScreen({super.key, this.id = ''});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final enrollment = ref.watch(enrollmentProvider(id));
    final title = enrollment.valueOrNull?.course.title ?? 'دوره';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'پایان دوره',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(Space.page),
        child: Column(
          children: [
            const Spacer(),
            Icon(Icons.emoji_events_outlined, size: 56, color: c.success),
            const SizedBox(height: Space.s4),
            Text(
              'دوره را تمام کردید',
              style: context.text.h2.copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: Space.s2),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.text.bodyMedium.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: Space.s4),
            const NoticeBanner(
              message: 'گواهی فقط پس از تکمیل همه جلسات صادر می‌شود.',
              tone: NoticeTone.info,
            ),
            const Spacer(),
            PishroButton(
              label: 'مشاهده گواهی',
              onPressed: () => context.push(Routes.certificate(id)),
            ),
            const SizedBox(height: Space.s3),
            PishroButton(
              label: 'دوره‌های من',
              variant: PishroButtonVariant.secondary,
              onPressed: () => context.go(Routes.myCourses),
            ),
          ],
        ),
      ),
    );
  }
}
