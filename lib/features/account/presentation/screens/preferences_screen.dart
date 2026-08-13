import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/providers/app_preferences_provider.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/pishro_chip.dart';
import '../../../../shared/widgets/states.dart';

/// Screen/Account/Preferences — Dark/Light.
class AccountPreferencesScreen extends ConsumerWidget {
  const AccountPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final mode = ref.watch(themeModeProvider);
    final prefs = ref.watch(appPreferencesProvider);
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
          const SizedBox(height: Space.s5),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: prefs.autoplayVideo,
            onChanged: ref.read(appPreferencesProvider.notifier).setAutoplay,
            title: Text(
              'پخش خودکار ویدیو',
              style: context.text.bodyMedium.copyWith(color: c.textPrimary),
            ),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: prefs.dataSaver,
            onChanged: ref.read(appPreferencesProvider.notifier).setDataSaver,
            title: Text(
              'حالت کاهش مصرف داده',
              style: context.text.bodyMedium.copyWith(color: c.textPrimary),
            ),
          ),
          const SizedBox(height: Space.s4),
          Text(
            'بازه پیش‌فرض نمودار',
            style: context.text.bodySmall.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: Space.s3),
          Wrap(
            spacing: Space.s2,
            children: [
              for (final r in ChartRangePref.values)
                PishroChip(
                  label: r.label,
                  selected: prefs.chartRange == r,
                  onTap: () => ref
                      .read(appPreferencesProvider.notifier)
                      .setChartRange(r),
                ),
            ],
          ),
          const SizedBox(height: Space.s4),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: prefs.reduceMotion,
            onChanged: ref
                .read(appPreferencesProvider.notifier)
                .setReduceMotion,
            title: Text(
              'کاهش انیمیشن',
              style: context.text.bodyMedium.copyWith(color: c.textPrimary),
            ),
            subtitle: Text(
              'تنظیم کاهش حرکت دستگاه همیشه رعایت می‌شود؛ این کلید علاوه بر آن است.',
              style: context.text.caption.copyWith(color: c.textMuted),
            ),
          ),
          const SizedBox(height: Space.s5),
          PishroButton(
            label: 'بازنشانی تنظیمات به حالت پیش‌فرض',
            variant: PishroButtonVariant.secondary,
            onPressed: ref.read(appPreferencesProvider.notifier).reset,
          ),
        ],
      ),
    );
  }
}
