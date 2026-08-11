import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishro_app/core/theme/app_colors.dart';
import 'package:pishro_app/core/theme/app_theme.dart';
import 'package:pishro_app/shared/widgets/bottom_nav.dart';
import 'package:pishro_app/shared/widgets/common.dart';
import 'package:pishro_app/shared/widgets/pishro_badge.dart';
import 'package:pishro_app/shared/widgets/pishro_button.dart';
import 'package:pishro_app/shared/widgets/pishro_chip.dart';
import 'package:pishro_app/shared/widgets/pishro_text_field.dart';
import 'package:pishro_app/shared/widgets/states.dart';

/// Renders [child] inside the real theme + RTL directionality, which is the
/// only context these widgets are ever used in.
Widget host(Widget child, {bool dark = true}) => MaterialApp(
      theme: dark ? AppTheme.dark() : AppTheme.light(),
      locale: const Locale('fa', 'IR'),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(body: Center(child: child)),
      ),
    );

void main() {
  testWidgets('button renders and fires; disabled and loading do not',
      (tester) async {
    var taps = 0;

    await tester.pumpWidget(host(
      PishroButton(label: 'خرید دوره', onPressed: () => taps++),
    ));
    await tester.tap(find.text('خرید دوره'));
    expect(taps, 1);

    await tester.pumpWidget(host(const PishroButton(label: 'غیرفعال')));
    await tester.tap(find.text('غیرفعال'));
    expect(taps, 1, reason: 'null onPressed must not fire');

    // Loading swaps the label and blocks re-submission — the checkout deck
    // requires «ارسال مجدد مسدود است».
    await tester.pumpWidget(host(
      PishroButton(label: 'پرداخت', loading: true, onPressed: () => taps++),
    ));
    expect(find.text('در حال پردازش…'), findsOneWidget);
    await tester.tap(find.text('در حال پردازش…'));
    expect(taps, 1);
  });

  testWidgets('badges carry an icon, not colour alone', (tester) async {
    await tester.pumpWidget(host(
      const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PishroBadge.vip(),
          PishroBadge.verified(),
          RiskBadge(RiskLevel.high),
        ],
      ),
    ));
    expect(find.text('VIP'), findsOneWidget);
    expect(find.text('تأییدشده'), findsOneWidget);
    expect(find.text('ریسک بالا'), findsOneWidget);
    // Every one of these must ship a glyph alongside the colour.
    expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
  });

  testWidgets('market delta shows direction glyph for both signs',
      (tester) async {
    await tester.pumpWidget(host(
      const Column(
        mainAxisSize: MainAxisSize.min,
        children: [MarketDelta(2.48), MarketDelta(-0.91)],
      ),
    ));
    expect(find.textContaining('▲'), findsOneWidget);
    expect(find.textContaining('▼'), findsOneWidget);
  });

  testWidgets('chip bar selects', (tester) async {
    var selected = 0;
    await tester.pumpWidget(host(
      StatefulBuilder(
        builder: (_, setState) => PishroChipBar(
          labels: const ['همه', 'تحلیل تکنیکال', 'ارز دیجیتال'],
          selectedIndex: selected,
          onSelected: (i) => setState(() => selected = i),
        ),
      ),
    ));
    await tester.tap(find.text('ارز دیجیتال'));
    await tester.pump();
    expect(selected, 2);
  });

  testWidgets('phone field normalises Persian digits to ASCII',
      (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(host(PishroTextField.phone(controller: controller)));
    await tester.enterText(find.byType(TextField), '۰۹۱۲۳۴۵۶۷۸۹');
    expect(controller.text, '09123456789');
  });

  testWidgets('error text renders below the field', (tester) async {
    await tester.pumpWidget(host(
      const PishroTextField(
        label: 'کد معرف',
        errorText: 'کد معرف واردشده معتبر نیست.',
      ),
    ));
    expect(find.text('کد معرف واردشده معتبر نیست.'), findsOneWidget);
  });

  testWidgets('empty and error states expose their action', (tester) async {
    var retried = 0;
    await tester.pumpWidget(host(ErrorStateView(onRetry: () => retried++)));
    await tester.tap(find.text('تلاش دوباره'));
    expect(retried, 1);

    await tester.pumpWidget(host(const EmptyState(
      title: 'هنوز دوره‌ای شروع نکرده‌اید',
      actionLabel: 'مشاهده دوره‌ها',
    )));
    expect(find.text('هنوز دوره‌ای شروع نکرده‌اید'), findsOneWidget);
  });

  testWidgets('bottom nav has exactly the five deck destinations, no home tab',
      (tester) async {
    var index = 0;
    await tester.pumpWidget(host(
      PishroBottomNav(
        currentIndex: index,
        onSelected: (i) => index = i,
        badges: const {1: 3},
      ),
    ));

    for (final d in PishroBottomNav.destinations) {
      expect(find.text(d.label), findsOneWidget);
    }
    expect(PishroBottomNav.destinations.length, 5);
    expect(find.text('خانه'), findsNothing);
    expect(find.text('۳'), findsOneWidget, reason: 'badge uses Persian digits');

    await tester.tap(find.text('بازار'));
    expect(index, 3);
  });

  test('both palettes define every semantic slot', () {
    for (final c in [AppColors.dark, AppColors.light]) {
      expect(c.actionPrimary, isNot(c.backgroundApp));
      expect(c.textPrimary, isNot(c.backgroundApp));
      expect(c.marketUp, isNot(c.marketDown));
    }
    expect(AppColors.dark.isDark, isTrue);
    expect(AppColors.light.isDark, isFalse);
  });
}
