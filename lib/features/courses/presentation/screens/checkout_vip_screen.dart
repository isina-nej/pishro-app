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
import '../../../auth/presentation/widgets/consent_checkbox.dart';
import '../../data/checkout_repository.dart';
import '../../data/courses_models.dart';
import '../widgets/checkout_summary.dart';

/// Screen/Checkout/Course-VIP — همان خلاصه با دکمه طلایی VIP.
class CourseVIPScreen extends ConsumerWidget {
  const CourseVIPScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final draft = ref.watch(checkoutProvider);
    if (draft == null || draft.package != PackageType.vip) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(
          title: 'بسته VIP انتخاب نشده',
          message: 'از صفحه مقایسه بسته‌ها VIP را برگزینید.',
          actionLabel: 'بازگشت',
          onAction: () => context.pop(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'پرداخت بسته VIP',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
        actions: const [
          Padding(
            padding: EdgeInsetsDirectional.only(end: Space.s4),
            child: PishroBadge.vip(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          CheckoutSummaryCard(draft: draft),
          const SizedBox(height: Space.s4),
          const NoticeBanner(
            message: 'گفت‌وگوی مدرس فقط پس از فعال‌شدن بسته VIP در دسترس است.',
            tone: NoticeTone.info,
          ),
          const SizedBox(height: Space.s5),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'روش پرداخت',
              style: context.text.bodyMedium.copyWith(color: c.textPrimary),
            ),
            subtitle: Text(
              draft.method.label,
              style: context.text.caption.copyWith(color: c.textMuted),
            ),
            trailing: const Icon(Icons.chevron_left_rounded),
            onTap: () => context.push(Routes.checkoutPaymentMethod),
          ),
          const SizedBox(height: Space.s4),
          ConsentCheckbox(
            value: draft.consentAccepted,
            showRequired: draft.showConsentError,
            onChanged: (v) => ref.read(checkoutProvider.notifier).setConsent(v),
            label: 'قوانین خرید و استرداد را خوانده و می‌پذیرم.',
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.page),
          child: PishroButton(
            label: draft.payLabel,
            variant: PishroButtonVariant.premium,
            loading: draft.submitting,
            onPressed: () {
              if (!draft.consentAccepted) {
                ref.read(checkoutProvider.notifier).flagConsentMissing();
                return;
              }
              context.push(Routes.checkoutProcessing);
            },
          ),
        ),
      ),
    );
  }
}
