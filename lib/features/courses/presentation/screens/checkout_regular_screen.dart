import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/states.dart';
import '../../../auth/presentation/widgets/consent_checkbox.dart';
import '../../data/checkout_repository.dart';
import '../widgets/checkout_summary.dart';

/// Screen/Checkout/Course-Regular — «۰۷ · پرداخت بسته عادی».
class CourseRegularScreen extends ConsumerWidget {
  const CourseRegularScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final draft = ref.watch(checkoutProvider);
    if (draft == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(
          title: 'سفارشی در جریان نیست',
          message: 'ابتدا یک دوره را برای خرید انتخاب کنید.',
          actionLabel: 'بازگشت به دوره‌ها',
          onAction: () => context.go(Routes.courses),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تکمیل خرید',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          CheckoutSummaryCard(draft: draft),
          const SizedBox(height: Space.s5),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              draft.method.label,
              style: context.text.bodyMedium.copyWith(color: c.textPrimary),
            ),
            subtitle: Text(
              draft.method.hint,
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
            label:
                'قوانین خرید و شرایط استفاده از دوره را مطالعه کرده‌ام و می‌پذیرم.',
          ),
          if (draft.showConsentError)
            Padding(
              padding: const EdgeInsets.only(top: Space.s2),
              child: Text(
                'برای ادامه، پذیرش قوانین خرید الزامی است.',
                style: context.text.caption.copyWith(color: c.danger),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.page),
          child: PishroButton(
            label: draft.payLabel,
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
