import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/pishro_badge.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/courses_repository.dart';

/// Screen/Course/VIPInstructorChat — فقط بسته VIP؛ طلا برای نشان VIP.
class VIPInstructorChatScreen extends ConsumerWidget {
  const VIPInstructorChatScreen({super.key, this.id = ''});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final enrollment = ref.watch(enrollmentProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'گفت‌وگو با مدرس',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
        actions: const [
          Padding(
            padding: EdgeInsetsDirectional.only(end: Space.s4),
            child: PishroBadge.vip(),
          ),
        ],
      ),
      body: enrollment.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ErrorStateView(
          onRetry: () => ref.invalidate(enrollmentProvider(id)),
        ),
        data: (enrolled) {
          if (enrolled == null || !enrolled.hasInstructorChat) {
            return Padding(
              padding: const EdgeInsets.all(Space.page),
              child: Column(
                children: [
                  const Spacer(),
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 40,
                    color: c.textMuted,
                  ),
                  const SizedBox(height: Space.s4),
                  Text(
                    'گفت‌وگوی مدرس فقط روی دوره VIP',
                    textAlign: TextAlign.center,
                    style: context.text.h3.copyWith(color: c.textPrimary),
                  ),
                  const SizedBox(height: Space.s2),
                  Text(
                    'با ارتقا به بسته VIP می‌توانید مستقیم از مدرس بپرسید.',
                    textAlign: TextAlign.center,
                    style: context.text.bodySmall.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  PishroButton(
                    label: 'مشاهده بسته‌ها',
                    variant: PishroButtonVariant.premium,
                    onPressed: () => context.push(Routes.packageComparison(id)),
                  ),
                ],
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(Space.page),
            children: [
              const NoticeBanner(
                message: 'پیام‌ها معمولاً تا یک روز کاری پاسخ داده می‌شوند.',
                tone: NoticeTone.info,
              ),
              const SizedBox(height: Space.s5),
              _Bubble(
                mine: false,
                text: 'سلام، از کدام بخش شروع کنم؟',
                name: enrolled.course.instructorName,
              ),
              const SizedBox(height: Space.s3),
              const _Bubble(
                mine: true,
                text: 'فصل ۱ را تمام کردم؛ برای الگوهای قیمتی آماده‌ام.',
                name: 'شما',
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.mine, required this.text, required this.name});

  final bool mine;
  final String text;
  final String name;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Align(
      alignment: mine ? Alignment.centerLeft : Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Container(
          padding: const EdgeInsets.all(Space.s3),
          decoration: BoxDecoration(
            color: mine ? c.surfaceSelected : c.surfaceSecondary,
            borderRadius: BorderRadius.circular(Radii.md),
            border: Border.all(color: c.borderDefault),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: context.text.micro.copyWith(color: c.textMuted),
              ),
              const SizedBox(height: Space.s1),
              Text(
                text,
                style: context.text.bodySmall.copyWith(color: c.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
