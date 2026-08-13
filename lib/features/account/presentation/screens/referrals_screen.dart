import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/states.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../data/account_repository.dart';

/// Screen/Account/Referrals — mock · بدون نرخ تبدیل.
class AccountReferralsScreen extends ConsumerWidget {
  const AccountReferralsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final info = ref.watch(referralsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'معرفی به دوستان',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: info.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            ErrorStateView(onRetry: () => ref.invalidate(referralsProvider)),
        data: (r) => ListView(
          padding: const EdgeInsets.all(Space.page),
          children: [
            Text(
              'کد معرف شما',
              style: context.text.caption.copyWith(color: c.textMuted),
            ),
            const SizedBox(height: Space.s2),
            PishroCard(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      r.code,
                      style: context.text.h3.copyWith(color: c.textPrimary),
                    ),
                  ),
                  IconButton(
                    tooltip: 'کپی',
                    onPressed: () =>
                        Clipboard.setData(ClipboardData(text: r.code)),
                    icon: Icon(Icons.copy_rounded, color: c.actionPrimary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Space.s3),
            PishroButton(
              label: 'اشتراک‌گذاری لینک',
              variant: PishroButtonVariant.secondary,
              // No share plugin is a dependency; copying the invite text is
              // the same outcome without adding one.
              onPressed: () => Clipboard.setData(
                ClipboardData(
                  text: 'با کد معرف ${r.code} در پیشرو سرمایه ثبت‌نام کنید.',
                ),
              ),
            ),
            const SizedBox(height: Space.s4),
            PishroCard(
              child: Row(
                children: [
                  _Stat('دعوت‌های ثبت‌شده', Fmt.fa('${r.invites}')),
                  // The referral service reports one figure. Splitting it into
                  // eligible/pending/rewarded would be inventing the other two.
                  const _Stat('در انتظار بررسی', 'داده در دسترس نیست'),
                  const _Stat('پاداش ثبت‌شده', 'داده در دسترس نیست'),
                ],
              ),
            ),
            const SizedBox(height: Space.s4),
            NoticeBanner(message: r.note, tone: NoticeTone.info),
            const SizedBox(height: Space.s3),
            const NoticeBanner(
              message:
                  'جزئیات پاداش طبق قوانین جاری برنامه محاسبه می‌شود. نرخ تبدیل یا درآمد تضمینی نمایش داده نمی‌شود.',
              tone: NoticeTone.warning,
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Expanded(
      child: Column(
        children: [
          Text(value, style: context.text.h3.copyWith(color: c.textPrimary)),
          Text(label, style: context.text.caption.copyWith(color: c.textMuted)),
        ],
      ),
    );
  }
}
