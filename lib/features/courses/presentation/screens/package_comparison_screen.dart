import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_badge.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/checkout_repository.dart';
import '../../data/courses_models.dart';
import '../../data/courses_repository.dart';
import '../widgets/course_widgets.dart';

/// Screen/Course/PackageComparison — عادی در برابر VIP.
class PackageComparisonScreen extends ConsumerWidget {
  const PackageComparisonScreen({super.key, this.id = ''});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final course = ref.watch(courseProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'مقایسه بسته‌ها',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: course.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(Space.page),
          child: Column(
            children: [
              Skeleton.box(height: 160),
              SizedBox(height: Space.s3),
              Skeleton.box(height: 160),
            ],
          ),
        ),
        error: (e, _) => ErrorStateView(
          message: e is ApiException ? e.message : 'بسته‌ها بارگذاری نشد.',
          onRetry: () => ref.invalidate(courseProvider(id)),
        ),
        data: (course) => ListView(
          padding: const EdgeInsets.all(Space.page),
          children: [
            _PackageCard(
              title: PackageType.regular.label,
              price: course.finalPrice,
              badge: const PishroBadge.regular(),
              perks: const [
                'دسترسی به تمام جلسات',
                'دانلود منابع دوره',
                'گواهی پایان دوره',
              ],
              action: 'خرید بسته عادی',
              onBuy: () {
                ref
                    .read(checkoutProvider.notifier)
                    .start(course, PackageType.regular);
                context.push(Routes.checkout);
              },
            ),
            const SizedBox(height: Space.s4),
            _PackageCard(
              title: PackageType.vip.label,
              price: course.vipPrice ?? course.finalPrice,
              badge: const PishroBadge.vip(),
              premium: true,
              perks: const [
                'همه امکانات بسته عادی',
                'گفت‌وگو با مدرس',
                'اولویت پشتیبانی',
              ],
              action: 'خرید بسته VIP',
              onBuy: course.hasVip
                  ? () {
                      ref
                          .read(checkoutProvider.notifier)
                          .start(course, PackageType.vip);
                      context.push(Routes.checkoutVip);
                    }
                  : null,
            ),
            if (!course.hasVip) ...[
              const SizedBox(height: Space.s4),
              const NoticeBanner(
                message: 'بسته VIP برای این دوره تعریف نشده است.',
                tone: NoticeTone.info,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({
    required this.title,
    required this.price,
    required this.badge,
    required this.perks,
    required this.action,
    this.onBuy,
    this.premium = false,
  });

  final String title;
  final int price;
  final Widget badge;
  final List<String> perks;
  final String action;
  final VoidCallback? onBuy;
  final bool premium;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return PishroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: context.text.h3.copyWith(color: c.textPrimary),
              ),
              const SizedBox(width: Space.s2),
              badge,
            ],
          ),
          const SizedBox(height: Space.s3),
          PriceTag(toman: price, large: true),
          const SizedBox(height: Space.s4),
          for (final p in perks)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.s2),
              child: Row(
                children: [
                  Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: premium ? c.premium : c.success,
                  ),
                  const SizedBox(width: Space.s2),
                  Expanded(
                    child: Text(
                      p,
                      style: context.text.bodySmall.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: Space.s3),
          PishroButton(
            label: action,
            variant: premium
                ? PishroButtonVariant.premium
                : PishroButtonVariant.primary,
            onPressed: onBuy,
          ),
        ],
      ),
    );
  }
}
