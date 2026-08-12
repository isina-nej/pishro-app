/// Article bodies arrive as server-rendered HTML that the backend does **not**
/// sanitise (`NewsArticle.content` / `contentHtml` are written straight from the
/// admin editor and rendered with `dangerouslySetInnerHTML` on the web client —
/// a known defect there).
///
/// The app therefore never renders that HTML. It is reduced to plain text
/// paragraphs here and drawn with ordinary [Text] widgets, so nothing in the
/// payload can execute, load a remote resource, or reach a WebView:
///
/// * executable / embedding containers are removed **with their contents**,
///   including the unterminated case (`<script>alert(1)` with no closing tag),
/// * every remaining tag is dropped — no attribute (`onerror`, `href`, `src`)
///   ever survives parsing,
/// * entities are decoded last, so `&lt;script&gt;` ends up as inert text.
library;

/// Tags whose *contents* must die with them.
final _dangerous = RegExp(
  r'<\s*(script|style|iframe|object|embed|noscript|template|svg|math|frame|frameset|applet)\b[^>]*>'
  r'(.*?)'
  r'(<\s*/\s*\1\s*>|$)',
  caseSensitive: false,
  dotAll: true,
);

/// A lone opening/closing tag of the same set, in case the payload nests them
/// to defeat a single pass (`<scr<script>ipt>`).
final _dangerousTag = RegExp(
  r'<\s*/?\s*(script|style|iframe|object|embed|noscript|template|svg|math|frame|frameset|applet)\b[^>]*>?',
  caseSensitive: false,
);

final _comment = RegExp(r'<!--.*?(-->|$)', dotAll: true);
final _blockEnd = RegExp(
  r'<\s*/?\s*(p|div|br|h[1-6]|tr|ul|ol|blockquote|section|article|pre|table|hr)\b[^>]*>',
  caseSensitive: false,
);
final _listItem = RegExp(r'<\s*li\b[^>]*>', caseSensitive: false);
final _anyTag = RegExp(r'<[^>]*>');
final _entity = RegExp(r'&(#x?[0-9a-fA-F]+|[a-zA-Z]+);');

const _namedEntities = <String, String>{
  'amp': '&',
  'lt': '<',
  'gt': '>',
  'quot': '"',
  'apos': "'",
  'nbsp': ' ',
  'zwnj': '‌',
  'laquo': '«',
  'raquo': '»',
  'hellip': '…',
  'mdash': '—',
  'ndash': '–',
  'middot': '·',
  'times': '×',
  'lsquo': '‘',
  'rsquo': '’',
  'ldquo': '“',
  'rdquo': '”',
};

/// Reduces raw article HTML to the paragraphs the reader should see.
///
/// Returns an empty list for empty or markup-only input — callers render the
/// «این خبر دیگر در دسترس نیست» state for that.
List<String> parseArticleBody(String? html) {
  if (html == null || html.trim().isEmpty) return const [];

  var text = html;
  // Repeat until stable: removing an outer <script> can reveal an inner one.
  for (var i = 0; i < 4; i++) {
    final next = text.replaceAll(_dangerous, '\n').replaceAll(_comment, '');
    if (next == text) break;
    text = next;
  }
  text = text
      .replaceAll(_dangerousTag, '\n')
      .replaceAll(_listItem, '\n• ')
      .replaceAll(_blockEnd, '\n')
      .replaceAll(_anyTag, '');

  text = _decodeEntities(text);

  return text
      .split('\n')
      .map((line) => line.replaceAll(RegExp('[ \\t\\u00a0]+'), ' ').trim())
      .where((line) => line.isNotEmpty)
      .toList(growable: false);
}

/// Single-paragraph flattening, for card excerpts and share subjects.
String articlePlainText(String? html) => parseArticleBody(html).join(' ');

String _decodeEntities(String input) => input.replaceAllMapped(_entity, (m) {
      final body = m.group(1)!;
      if (body.startsWith('#')) {
        final isHex = body.length > 1 && (body[1] == 'x' || body[1] == 'X');
        final code = int.tryParse(
          isHex ? body.substring(2) : body.substring(1),
          radix: isHex ? 16 : 10,
        );
        // Reject control characters and anything outside the BMP+ range.
        if (code == null || code < 0x20 || code > 0x10ffff) return '';
        return String.fromCharCode(code);
      }
      return _namedEntities[body.toLowerCase()] ?? m.group(0)!;
    });
