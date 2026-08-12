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

/// Screen/Course/PackageComparison — روی هر کارت بزنید.
class PackageComparisonScreen extends ConsumerStatefulWidget {
  const PackageComparisonScreen({super.key, this.id = ''});

  final String id;

  @override
  ConsumerState<PackageComparisonScreen> createState() =>
      _PackageComparisonScreenState();
}

class _PackageComparisonScreenState
    extends ConsumerState<PackageComparisonScreen> {
  PackageType? _picked;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final course = ref.watch(courseProvider(widget.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'انتخاب بسته دوره',
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
          onRetry: () => ref.invalidate(courseProvider(widget.id)),
        ),
        data: (course) {
          _picked ??= PackageType.regular;
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              Space.page,
              Space.s4,
              Space.page,
              120,
            ),
            children: [
              Text(
                course.title,
                style: context.text.bodySmall.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: Space.s4),
              _PackageCard(
                title: 'بسته عادی',
                price: course.finalPrice,
                badge: const PishroBadge.regular(),
                selected: _picked == PackageType.regular,
                perks: const [
                  (true, 'دسترسی کامل به ویدیوهای دوره'),
                  (true, 'فایل‌ها و منابع آموزشی'),
                  (true, 'گواهی پایان دوره، در صورت ارائه'),
                  (false, 'بدون گفت‌وگوی مستقیم با مدرس'),
                ],
                onTap: () => setState(() => _picked = PackageType.regular),
              ),
              const SizedBox(height: Space.s3),
              if (course.hasVip)
                _PackageCard(
                  title: 'بسته VIP',
                  price: course.vipPrice ?? course.finalPrice,
                  badge: const PishroBadge.vip(),
                  selected: _picked == PackageType.vip,
                  perks: const [
                    (true, 'تمام امکانات بسته عادی'),
                    (true, 'گفت‌وگوی مستقیم با مدرس'),
                    (true, 'اولویت پاسخ‌گویی به پرسش‌ها'),
                    (true, 'محتوای تکمیلی VIP، در صورت ارائه'),
                  ],
                  onTap: () => setState(() => _picked = PackageType.vip),
                )
              else
                const NoticeBanner(
                  message: 'بسته VIP برای این دوره تعریف نشده است.',
                  tone: NoticeTone.info,
                ),
              const SizedBox(height: Space.s4),
              Text(
                'دسترسی به دوره پس از خرید نامحدود است، مگر آنکه شرایط دوره خلاف آن را مشخص کند.',
                style: context.text.caption.copyWith(color: c.textMuted),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: course.maybeWhen(
        data: (course) {
          final vip = _picked == PackageType.vip;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(Space.page),
              child: PishroButton(
                label: vip ? 'ادامه با بسته VIP' : 'ادامه با بسته عادی',
                variant: vip
                    ? PishroButtonVariant.premium
                    : PishroButtonVariant.primary,
                onPressed: () {
                  final type = vip ? PackageType.vip : PackageType.regular;
                  ref.read(checkoutProvider.notifier).start(course, type);
                  context.push(vip ? Routes.checkoutVip : Routes.checkout);
                },
              ),
            ),
          );
        },
        orElse: () => null,
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
    required this.selected,
    required this.onTap,
  });

  final String title;
  final int price;
  final Widget badge;
  final List<(bool included, String label)> perks;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return PishroCard(
      selected: selected,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: context.text.h3.copyWith(color: c.textPrimary),
                ),
              ),
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
                    p.$1 ? Icons.check_rounded : Icons.close_rounded,
                    size: 18,
                    color: p.$1 ? c.success : c.textMuted,
                  ),
                  const SizedBox(width: Space.s2),
                  Expanded(
                    child: Text(
                      p.$2,
                      style: context.text.bodySmall.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
