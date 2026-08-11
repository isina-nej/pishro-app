import 'package:flutter_test/flutter_test.dart';
import 'package:pishro_app/core/utils/formatters.dart';

void main() {
  test('persian digit round-trip', () {
    expect(Fmt.fa('09123456789'), '۰۹۱۲۳۴۵۶۷۸۹');
    expect(Fmt.toAscii('۰۹۱۲۳۴۵۶۷۸۹'), '09123456789');
    // Arabic-Indic digits from some Persian keyboards must also normalise.
    expect(Fmt.toAscii('٠٩١٢'), '0912');
    expect(Fmt.toAscii(Fmt.fa('1234567890')), '1234567890');
  });

  test('grouping and toman', () {
    expect(Fmt.grouped(1200000, persianDigits: false), '1٬200٬000');
    expect(Fmt.grouped(999, persianDigits: false), '999');
    expect(Fmt.grouped(-1500, persianDigits: false), '−1٬500');
    expect(Fmt.toman(750000), '۷۵۰٬۰۰۰ تومان');
  });

  test('percent delta always carries a direction glyph, not just colour', () {
    expect(Fmt.percentDelta(2.48), startsWith('▲'));
    expect(Fmt.percentDelta(-0.91), startsWith('▼'));
    expect(Fmt.percentDelta(0), startsWith('•'));
    expect(Fmt.percentDelta(-0.91), contains('−'));
  });

  test('relative time buckets', () {
    final now = DateTime(2026, 8, 11, 12);
    expect(Fmt.relative(now.subtract(const Duration(seconds: 20)), now: now),
        'همین حالا');
    expect(Fmt.relative(now.subtract(const Duration(hours: 2)), now: now),
        '۲ ساعت پیش');
    expect(Fmt.relative(now.subtract(const Duration(days: 1)), now: now),
        'دیروز');
    // Past a week it falls back to an absolute Jalali date.
    expect(Fmt.relative(now.subtract(const Duration(days: 30)), now: now),
        contains('۱۴۰'));
  });

  test('phone masking matches the Account/Home deck', () {
    expect(Fmt.maskPhone('09123456789'), '۰۹۱۲•••۶۷۸۹');
  });

  test('duration', () {
    expect(Fmt.duration(const Duration(hours: 12)), '۱۲ ساعت');
    expect(Fmt.duration(const Duration(minutes: 45)), '۴۵ دقیقه');
    expect(Fmt.duration(const Duration(hours: 1, minutes: 30)),
        '۱ ساعت و ۳۰ دقیقه');
  });
}
