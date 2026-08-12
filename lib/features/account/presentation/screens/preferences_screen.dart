import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/pishro_chip.dart';
import '../../../../shared/widgets/states.dart';

import '../../../../shared/providers/theme_provider.dart';

class AccountPreferencesScreen extends ConsumerWidget {
  const AccountPreferencesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final mode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ترجیحات',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          Text(
            'ظاهر برنامه',
            style: context.text.bodySmall.copyWith(
              color: c.textSecondary,
              fontWeight: FontWeight.w600,
            ),
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
                label: 'سیستم',
                selected: mode == ThemeMode.system,
                onTap: () =>
                    ref.read(themeModeProvider.notifier).set(ThemeMode.system),
              ),
            ],
          ),
          const SizedBox(height: Space.s4),
          const NoticeBanner(
            message: 'رنگ اکشن برند قابل تغییر نیست؛ فقط حالت روشن/تاریک.',
            tone: NoticeTone.info,
          ),
        ],
      ),
    );
  }
}
