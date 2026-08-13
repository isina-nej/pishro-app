import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/widgets/pishro_chip.dart';
import '../../../../shared/widgets/states.dart';

/// Screen/Account/Preferences — Dark/Light.
class AccountPreferencesScreen extends ConsumerWidget {
  const AccountPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final mode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تنظیمات',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          Text(
            'زبان',
            style: context.text.bodySmall.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: Space.s2),
          Text(
            'فارسی',
            style: context.text.bodyMedium.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: Space.s5),
          Text(
            'حالت نمایش',
            style: context.text.bodySmall.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: Space.s3),
          Wrap(
            spacing: Space.s2,
            children: [
              PishroChip(
                label: 'تاریک',
                selected: mode == ThemeMode.dark,
                onTap: () =>
                    ref.read(themeModeProvider.notifier).set(ThemeMode.dark),
              ),
              PishroChip(
                label: 'روشن',
                selected: mode == ThemeMode.light,
                onTap: () =>
                    ref.read(themeModeProvider.notifier).set(ThemeMode.light),
              ),
              PishroChip(
                label: 'هماهنگ با دستگاه',
                selected: mode == ThemeMode.system,
                onTap: () =>
                    ref.read(themeModeProvider.notifier).set(ThemeMode.system),
              ),
            ],
          ),
          const SizedBox(height: Space.s4),
          const NoticeBanner(
            message:
                'فقط حالت روشن/تاریک قابل تغییر است. پالت RoyalGreen برند ثابت می‌ماند.',
            tone: NoticeTone.info,
          ),
        ],
      ),
    );
  }
}
