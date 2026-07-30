/// A character-range anchor into a story's text (AF6).
///
/// The wire shape is `{from, to}` — two required non-negative ints — optionally with
/// the `quote` at that range for display (`CommentAnchorDto` /
/// `SuggestionAnchorDto` in `collaboration-request.dto.ts`, echoed back as
/// `CommentAnchorViewDto` / `SuggestionAnchorViewDto`).
///
/// Mobile previously modelled this as `{blockId, start, end, quote}`. On the way out
/// that was three keys no DTO declares plus two required ones missing, so every
/// inline comment and every suggestion was rejected by `forbidNonWhitelisted`
/// (defects **C-3** and **C-6**); on the way in, `from`/`to` were never read, so an
/// accepted suggestion's position was thrown away (**C-4**). See `docs/56` §2.1.
///
/// There is no block id in the contract: the server anchors into the plain-text
/// projection of the piece (`extractPlainText`), so offsets are document-wide.
library;

import '../../../../core/utils/typedefs.dart';

class TextAnchor {
  const TextAnchor({required this.from, required this.to, this.quote});

  /// Inclusive start offset in the document's plain text (≥ 0).
  final int from;

  /// Exclusive end offset (≥ 0).
  final int to;

  /// The text at the range, when the server echoes it (comments only).
  final String? quote;

  int get length => to - from;
  bool get isCollapsed => from == to;

  /// Comment anchors accept a `quote`; suggestion anchors do not, so the caller
  /// picks the body it needs rather than sending a key the DTO would reject.
  Json toCommentJson() => <String, Object?>{
    'from': from,
    'to': to,
    'quote': ?quote,
  };

  /// `SuggestionAnchorDto` declares only `from` and `to`.
  Json toSuggestionJson() => <String, Object?>{'from': from, 'to': to};

  static TextAnchor? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final Json json = Json.from(raw);
    final int? from = (json['from'] as num?)?.toInt();
    final int? to = (json['to'] as num?)?.toInt();
    // Both are required on the wire; without them there is no range to anchor.
    if (from == null || to == null) return null;
    return TextAnchor(from: from, to: to, quote: json['quote'] as String?);
  }
}
