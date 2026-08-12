import 'package:shamsi_date/shamsi_date.dart';

/// Number/date presentation rules from Foundations Frame 03:
/// «اعداد فارسی در متن، لاتین در نماد» — Persian digits in prose, Latin in
/// tickers and code-like values.
abstract final class Fmt {
  static const _persianDigits = [
    '۰',
    '۱',
    '۲',
    '۳',
    '۴',
    '۵',
    '۶',
    '۷',
    '۸',
    '۹',
  ];

  /// ASCII digits -> Persian digits. Leaves every other character alone.
  static String fa(String input) {
    final b = StringBuffer();
    for (final ch in input.split('')) {
      final code = ch.codeUnitAt(0);
      b.write(code >= 0x30 && code <= 0x39 ? _persianDigits[code - 0x30] : ch);
    }
    return b.toString();
  }

  /// Persian digits -> ASCII. Needed before sending user input to the API,
  /// which expects Latin digits for phone numbers and amounts.
  static String toAscii(String input) {
    final b = StringBuffer();
    for (final ch in input.split('')) {
      final i = _persianDigits.indexOf(ch);
      if (i >= 0) {
        b.write(i);
        continue;
      }
      // Arabic-Indic range, which some Persian keyboards emit.
      final code = ch.codeUnitAt(0);
      if (code >= 0x0660 && code <= 0x0669) {
        b.write(code - 0x0660);
      } else {
        b.write(ch);
      }
    }
    return b.toString();
  }

  /// Thousands separator using the Persian comma (٬), then Persian digits.
  static String grouped(num value, {bool persianDigits = true}) {
    final negative = value < 0;
    final digits = value.abs().round().toString();
    final b = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) b.write('٬');
      b.write(digits[i]);
    }
    final s = '${negative ? '−' : ''}$b';
    return persianDigits ? fa(s) : s;
  }

  /// «۱٬۲۰۰٬۰۰۰ تومان»
  static String toman(num value) => '${grouped(value)} تومان';

  /// Signed percentage with the direction glyph the deck requires. Colour must
  /// never be the only signal, so the arrow is part of the string itself.
  static String percentDelta(double value) {
    final arrow = value > 0 ? '▲' : (value < 0 ? '▼' : '•');
    final sign = value > 0 ? '+' : (value < 0 ? '−' : '');
    final magnitude = value.abs().toStringAsFixed(2);
    return '$arrow ${fa('$sign$magnitude')}٪';
  }

  /// Jalali calendar date: «۱۴۰۵/۰۵/۲۰».
  static String jalaliDate(DateTime dt) {
    final j = Jalali.fromDateTime(dt.toLocal());
    final mm = j.month.toString().padLeft(2, '0');
    final dd = j.day.toString().padLeft(2, '0');
    return fa('${j.year}/$mm/$dd');
  }

  static const _monthNames = [
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

  /// «۲۰ مرداد ۱۴۰۵»
  static String jalaliLong(DateTime dt) {
    final j = Jalali.fromDateTime(dt.toLocal());
    return fa('${j.day} ${_monthNames[j.month - 1]} ${j.year}');
  }

  /// «۲ ساعت پیش» — falls back to an absolute Jalali date past a week, because
  /// "۹ روز پیش" reads worse than the date itself.
  static String relative(DateTime dt, {DateTime? now}) {
    final diff = (now ?? DateTime.now()).difference(dt);
    if (diff.isNegative) return jalaliLong(dt);
    if (diff.inMinutes < 1) return 'همین حالا';
    if (diff.inMinutes < 60) return '${fa('${diff.inMinutes}')} دقیقه پیش';
    if (diff.inHours < 24) return '${fa('${diff.inHours}')} ساعت پیش';
    if (diff.inDays == 1) return 'دیروز';
    if (diff.inDays < 7) return '${fa('${diff.inDays}')} روز پیش';
    return jalaliLong(dt);
  }

  /// «۰۹۱۲•••۴۵۶۷» — the masking used on Account/Home in the deck.
  static String maskPhone(String phone) {
    final digits = toAscii(phone).replaceAll(RegExp(r'\D'), '');
    if (digits.length < 8) return fa(digits);
    return fa(
      '${digits.substring(0, 4)}•••${digits.substring(digits.length - 4)}',
    );
  }

  /// «۱۲ ساعت» / «۴۵ دقیقه» for course and lesson durations.
  static String duration(Duration d) {
    if (d.inHours >= 1) {
      final h = d.inHours;
      final m = d.inMinutes % 60;
      return m == 0
          ? '${fa('$h')} ساعت'
          : '${fa('$h')} ساعت و ${fa('$m')} دقیقه';
    }
    return '${fa('${d.inMinutes}')} دقیقه';
  }
}
