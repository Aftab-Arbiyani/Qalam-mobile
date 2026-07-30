/// The writing context the assistant/coach operate on (AF2) — a plain snapshot the
/// EDITOR builds and hands to the AI layer, so the AI feature never reaches into the
/// writing feature's internals. Carries the operand (current selection or the whole
/// chapter) plus document metadata, and knows how to turn itself into the AF1 context
/// requests (`selection`, `writing_metadata`) — "only include context necessary for
/// the request" (docs/34 §4). Pure Dart.
library;

import '../entities/ai_completion.dart';

class AiWritingContext {
  const AiWritingContext({
    this.selectionText = '',
    this.chapterText = '',
    this.title = '',
    this.genre,
    this.language = '',
    this.wordCount = 0,
    this.tags = const <String>[],
  });

  /// The current editor selection text ('' when nothing is selected).
  final String selectionText;

  /// The full chapter/document plain text.
  final String chapterText;

  final String title;
  final String? genre;

  /// Language name or code (framing for Hindi/Urdu generation).
  final String language;
  final int wordCount;
  final List<String> tags;

  bool get hasSelection => selectionText.trim().isNotEmpty;

  /// The text a transform/continuation acts on: the selection if present, else the
  /// whole chapter.
  String get operand => hasSelection ? selectionText.trim() : chapterText.trim();

  bool get hasOperand => operand.isNotEmpty;

  /// The metadata context request (always useful framing).
  AiContextRequest get metadataContext => AiContextRequest(
        type: 'writing_metadata',
        params: <String, dynamic>{
          'title': title,
          if (genre != null && genre!.isNotEmpty) 'genre': genre,
          'language': language,
          'wordCount': wordCount,
          'tags': tags,
        },
      );

  /// Context requests to attach. [includeSelection] adds the selection as a labelled
  /// context block (used by the free-form "Ask AI", where the user's instruction is
  /// the message and the selection is background) — quick actions send the operand as
  /// the message instead, so they omit it.
  List<AiContextRequest> contextRequests({bool includeSelection = false}) =>
      <AiContextRequest>[
        if (includeSelection && hasSelection)
          AiContextRequest(type: 'selection', params: <String, dynamic>{'text': selectionText}),
        metadataContext,
      ];
}
