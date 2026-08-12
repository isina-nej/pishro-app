import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/pishro_badge.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/courses_repository.dart';

/// Screen/Course/Certificate — قاب سبز + طلا فقط برای نشان گواهی.
class CertificateScreen extends ConsumerWidget {
  const CertificateScreen({super.key, this.id = ''});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final enrollment = ref.watch(enrollmentProvider(id));
    final e = enrollment.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'گواهی پایان دوره',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: e == null
          ? const EmptyState(title: 'گواهی در دسترس نیست')
          : ListView(
              padding: const EdgeInsets.all(Space.page),
              children: [
                Container(
                  padding: const EdgeInsets.all(Space.s6),
                  decoration: BoxDecoration(
                    color: c.surfacePrimary,
                    borderRadius: BorderRadius.circular(Radii.card),
                    border: Border.all(color: c.actionPrimary, width: 2),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.workspace_premium_rounded,
                        size: 40,
                        color: c.premium,
                      ),
                      const SizedBox(height: Space.s2),
                      const PishroBadge(
                        label: 'گواهی پیشرو سرمایه',
                        tone: PishroBadgeTone.premium,
                        icon: Icons.star_rounded,
                      ),
                      const SizedBox(height: Space.s4),
                      Text(
                        'این گواهی پایان دوره را تأیید می‌کند',
                        textAlign: TextAlign.center,
                        style: context.text.caption.copyWith(
                          color: c.textMuted,
                        ),
                      ),
                      const SizedBox(height: Space.s3),
                      Text(
                        e.course.title,
                        textAlign: TextAlign.center,
                        style: context.text.h3.copyWith(color: c.textPrimary),
                      ),
                      const SizedBox(height: Space.s2),
                      Text(
                        e.course.instructorName,
                        style: context.text.bodySmall.copyWith(
                          color: c.textSecondary,
                        ),
                      ),
                      if (e.completedAt != null) ...[
                        const SizedBox(height: Space.s3),
                        Text(
                          Fmt.jalaliLong(e.completedAt!),
                          style: context.text.caption.copyWith(
                            color: c.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
