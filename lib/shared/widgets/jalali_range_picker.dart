import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/formatters.dart';
import 'pishro_button.dart';

/// An inclusive Jalali day range, both ends at day granularity.
@immutable
class JalaliRange {
  const JalaliRange({required this.from, required this.to});

  final Jalali from;
  final Jalali to;

  /// Start of the first day.
  DateTime get start => from.toDateTime();

  /// End of the last day — the filter is inclusive of the whole closing day.
  DateTime get end {
    final d = to.toDateTime();
    return DateTime(d.year, d.month, d.day, 23, 59, 59, 999);
  }

  String get label =>
      '${Fmt.jalaliDate(from.toDateTime())} تا ${Fmt.jalaliDate(to.toDateTime())}';
}

/// «بازه دلخواه» — a Jalali month grid, because every date the user reads in
/// this app is Jalali and Material's own range picker is Gregorian-only.
///
/// Returns null when dismissed or cleared.
Future<JalaliRange?> showJalaliRangePicker(
  BuildContext context, {
  JalaliRange? initial,
  Jalali? lastDate,
}) => showModalBottomSheet<JalaliRange?>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (_) => _JalaliRangeSheet(initial: initial, lastDate: lastDate),
);

class _JalaliRangeSheet extends StatefulWidget {
  const _JalaliRangeSheet({this.initial, this.lastDate});

  final JalaliRange? initial;
  final Jalali? lastDate;

  @override
  State<_JalaliRangeSheet> createState() => _JalaliRangeSheetState();
}

class _JalaliRangeSheetState extends State<_JalaliRangeSheet> {
  static const _weekDays = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];
  static const _months = [
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'مرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند',
  ];

  late Jalali _cursor;
  Jalali? _from;
  Jalali? _to;

  Jalali get _last => widget.lastDate ?? Jalali.now();

  @override
  void initState() {
    super.initState();
    _from = widget.initial?.from;
    _to = widget.initial?.to;
    _cursor = _from ?? Jalali.now();
  }

  /// Tap one: opens a new range. Tap two: closes it, swapping if the user
  /// picked backwards.
  void _tap(Jalali day) {
    setState(() {
      if (_from == null || _to != null) {
        _from = day;
        _to = null;
      } else if (day < _from!) {
        _to = _from;
        _from = day;
      } else {
        _to = day;
      }
    });
  }

  bool _inRange(Jalali d) {
    final f = _from;
    final t = _to;
    if (f == null) return false;
    if (t == null) return d == f;
    return d >= f && d <= t;
  }

  void _shiftMonth(int delta) {
    setState(() {
      final m = _cursor.month + delta;
      final year = _cursor.year + (m > 12 ? 1 : (m < 1 ? -1 : 0));
      final month = m > 12 ? 1 : (m < 1 ? 12 : m);
      // Clamp the day so month lengths never overflow (۳۱ اسفند نداریم).
      final probe = Jalali(year, month, 1);
      _cursor = Jalali(
        year,
        month,
        _cursor.day > probe.monthLength ? probe.monthLength : _cursor.day,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final firstOfMonth = Jalali(_cursor.year, _cursor.month, 1);
    final leadingBlanks = firstOfMonth.weekDay - 1;

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        // A twelve-month grid plus the header does not fit a short screen;
        // cap the sheet and let the calendar itself scroll.
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: c.surfacePrimary,
            border: Border(top: BorderSide(color: c.borderDefault)),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(Radii.xl),
            ),
          ),
          padding: const EdgeInsets.all(Space.page),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'بازه دلخواه',
                style: context.text.h3.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: Space.s2),
              Text(
                _from == null
                    ? 'روز شروع را انتخاب کنید.'
                    : (_to == null
                          ? 'روز پایان را انتخاب کنید.'
                          : JalaliRange(from: _from!, to: _to!).label),
                style: context.text.caption.copyWith(color: c.textMuted),
              ),
              const SizedBox(height: Space.s4),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          _ArrowButton(
                            icon: Icons.chevron_right_rounded,
                            tooltip: 'ماه قبل',
                            onTap: () => _shiftMonth(-1),
                          ),
                          Expanded(
                            child: Text(
                              '${_months[_cursor.month - 1]} ${Fmt.fa('${_cursor.year}')}',
                              textAlign: TextAlign.center,
                              style: context.text.bodyMedium.copyWith(
                                color: c.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          _ArrowButton(
                            icon: Icons.chevron_left_rounded,
                            tooltip: 'ماه بعد',
                            // Never page past the last selectable month.
                            onTap:
                                _cursor.year > _last.year ||
                                    (_cursor.year == _last.year &&
                                        _cursor.month >= _last.month)
                                ? null
                                : () => _shiftMonth(1),
                          ),
                        ],
                      ),
                      const SizedBox(height: Space.s3),
                      Row(
                        children: [
                          for (final w in _weekDays)
                            Expanded(
                              child: Text(
                                w,
                                textAlign: TextAlign.center,
                                style: context.text.caption.copyWith(
                                  color: c.textMuted,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: Space.s2),
                      GridView.count(
                        crossAxisCount: 7,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          for (var i = 0; i < leadingBlanks; i++)
                            const SizedBox.shrink(),
                          for (var d = 1; d <= firstOfMonth.monthLength; d++)
                            _DayCell(
                              day: d,
                              selected: _inRange(
                                Jalali(_cursor.year, _cursor.month, d),
                              ),
                              isEdge:
                                  Jalali(_cursor.year, _cursor.month, d) ==
                                      _from ||
                                  Jalali(_cursor.year, _cursor.month, d) == _to,
                              enabled:
                                  Jalali(_cursor.year, _cursor.month, d) <=
                                  _last,
                              onTap: () =>
                                  _tap(Jalali(_cursor.year, _cursor.month, d)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Space.s4),
              Row(
                children: [
                  Expanded(
                    child: PishroButton(
                      label: 'حذف بازه',
                      variant: PishroButtonVariant.ghost,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: Space.s3),
                  Expanded(
                    child: PishroButton(
                      label: 'تأیید بازه',
                      // A half-open selection is not a range yet.
                      onPressed: _from != null && _to != null
                          ? () => Navigator.of(
                              context,
                            ).pop(JalaliRange(from: _from!, to: _to!))
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      icon: Icon(icon, color: onTap == null ? c.textMuted : c.textPrimary),
      constraints: const BoxConstraints(
        minWidth: Layout.minTapTarget,
        minHeight: Layout.minTapTarget,
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.selected,
    required this.isEdge,
    required this.enabled,
    required this.onTap,
  });

  final int day;
  final bool selected;
  final bool isEdge;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Selection is never colour alone: the two endpoints are also bolder and
    // fully filled, the days between them sit on a tonal surface.
    final background = isEdge
        ? c.actionPrimary
        : (selected ? c.surfaceSecondary : Colors.transparent);
    final foreground = isEdge
        ? c.onAction
        : (enabled ? c.textPrimary : c.textMuted);

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(Radii.md),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(Radii.md),
          child: Center(
            child: Text(
              Fmt.fa('$day'),
              style: context.text.bodySmall.copyWith(
                color: foreground,
                fontWeight: isEdge ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
