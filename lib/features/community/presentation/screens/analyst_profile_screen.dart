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

import '../../../../core/utils/formatters.dart';
import '../../data/community_repository.dart';

class AnalystProfileScreen extends ConsumerWidget {
  const AnalystProfileScreen({super.key, this.id = ''});
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final analyst = ref.watch(analystProvider(id));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'پروفایل تحلیلگر',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: analyst.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            ErrorStateView(onRetry: () => ref.invalidate(analystProvider(id))),
        data: (a) {
          if (a == null) return const EmptyState(title: 'تحلیلگر یافت نشد');
          return ListView(
            padding: const EdgeInsets.all(Space.page),
            children: [
              Text(
                a.displayName,
                style: context.text.h2.copyWith(color: c.textPrimary),
              ),
              Text(
                a.specialty,
                style: context.text.bodySmall.copyWith(color: c.textMuted),
              ),
              const SizedBox(height: Space.s2),
              Text(
                '${a.specialty} · فعال از ${Fmt.fa('${a.activeSinceJalaliYear}')}',
                style: context.text.caption.copyWith(color: c.textMuted),
              ),
              const SizedBox(height: Space.s4),
              // The deck's three headline counts. Nothing here is a return
              // figure — رتبه‌بندی is participation, not performance.
              Row(
                children: [
                  Expanded(
                    child: _ProfileStat(
                      value: Fmt.fa('${a.publishedCount}'),
                      label: 'تحلیل',
                    ),
                  ),
                  Expanded(
                    child: _ProfileStat(
                      value: Fmt.fa(a.rating.toStringAsFixed(1)),
                      label: 'امتیاز',
                    ),
                  ),
                  Expanded(
                    child: _ProfileStat(
                      value: Fmt.grouped(a.followerCount),
                      label: 'دنبال‌کننده',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Space.s4),
              PishroBadge(
                label: a.isIdentityVerified
                    ? 'تأیید هویت'
                    : 'تأیید مدارک: ناقص',
                tone: a.isIdentityVerified
                    ? PishroBadgeTone.success
                    : PishroBadgeTone.warning,
                icon: a.isIdentityVerified
                    ? Icons.verified_outlined
                    : Icons.info_outline_rounded,
              ),
              const SizedBox(height: Space.s3),
              Wrap(
                spacing: Space.s2,
                runSpacing: Space.s2,
                children: [
                  for (final b in a.badges)
                    PishroBadge(
                      label: b.text,
                      tone: b.granted
                          ? PishroBadgeTone.success
                          : PishroBadgeTone.warning,
                      icon: b.granted
                          ? Icons.verified_outlined
                          : Icons.info_outline_rounded,
                    ),
                ],
              ),
              const SizedBox(height: Space.s4),
              Text(
                a.bio,
                style: context.text.bodySmall.copyWith(
                  color: c.textSecondary,
                  height: 1.8,
                ),
              ),
              const SizedBox(height: Space.s3),
              Text(
                a.disclosure,
                style: context.text.caption.copyWith(color: c.textMuted),
              ),
              const SizedBox(height: Space.s4),
              PishroButton(
                label: a.isFollowing ? 'لغو دنبال' : 'دنبال کردن',
                variant: PishroButtonVariant.secondary,
                onPressed: () async {
                  await ref
                      .read(communityRepositoryProvider)
                      .toggleFollow(a.id);
                  ref.invalidate(analystProvider(id));
                  ref.invalidate(recommendedAnalystsProvider);
                },
              ),
              const SizedBox(height: Space.s3),
              PishroButton(
                label: 'امتیازها',
                variant: PishroButtonVariant.ghost,
                onPressed: () => context.push(Routes.analystRatings(id)),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// One of the «تحلیل · امتیاز · دنبال‌کننده» counters on the profile header.
class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      children: [
        Text(value, style: context.text.h3.copyWith(color: c.textPrimary)),
        const SizedBox(height: Space.s1),
        Text(label, style: context.text.caption.copyWith(color: c.textMuted)),
      ],
    );
  }
}
