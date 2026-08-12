import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/states.dart';

import '../../data/account_repository.dart';

class AccountReferralsScreen extends ConsumerWidget {
  const AccountReferralsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final info = ref.watch(referralsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'معرفی دوستان',
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
              'کد دعوت',
              style: context.text.caption.copyWith(color: c.textMuted),
            ),
            Text(r.code, style: context.text.h2.copyWith(color: c.textPrimary)),
            const SizedBox(height: Space.s3),
            Text(
              '${r.invites} دعوت موفق',
              style: context.text.bodySmall.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: Space.s4),
            NoticeBanner(message: r.note, tone: NoticeTone.info),
          ],
        ),
      ),
    );
  }
}
