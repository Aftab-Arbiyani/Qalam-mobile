/// A single top-level block of the editor document (M4 editor).
///
/// The editor document is an ordered list of blocks; each block is one
/// [EditorBlockType] carrying inline [MarkedText]. The type set is exactly the
/// backend's whitelisted top-level content nodes (paragraph, heading level 2–4,
/// blockquote, bullet/ordered list), so the document cannot express a node the
/// server would reject. List blocks hold their items as newline-separated lines of
/// the same [MarkedText] (one line = one `listItem`), keeping every block a single
/// editable text run for a uniform, robust editing model.
///
/// Pure Dart. [id] is a document-local identity (assigned by the controller) used
/// as a widget key and to reconcile per-block text controllers — it is NOT sent to
/// the server and is not the TipTap shape.
library;

import 'package:flutter/foundation.dart';

import 'marked_text.dart';

/// The whitelisted block kinds a writer can create. Mirrors the server sanitizer's
/// top-level nodes; there is deliberately no image, code block, or rule.
enum EditorBlockType {
  paragraph,
  heading2,
  heading3,
  heading4,
  blockquote,
  bulletList,
  orderedList;

  bool get isHeading =>
      this == heading2 || this == heading3 || this == heading4;

  bool get isList => this == bulletList || this == orderedList;

  /// The TipTap heading level (2–4) for a heading block; null otherwise.
  int? get headingLevel => switch (this) {
    heading2 => 2,
    heading3 => 3,
    heading4 => 4,
    _ => null,
  };

  static EditorBlockType headingForLevel(int level) => switch (level) {
    2 => heading2,
    3 => heading3,
    _ => heading4,
  };
}

@immutable
class EditorBlock {
  const EditorBlock({
    required this.id,
    required this.type,
    required this.text,
    this.listStart = 1,
  });

  /// A plain empty paragraph — the default first block of a new document.
  factory EditorBlock.emptyParagraph(String id) => EditorBlock(
    id: id,
    type: EditorBlockType.paragraph,
    text: MarkedText.empty,
  );

  final String id;
  final EditorBlockType type;
  final MarkedText text;

  /// First ordinal for an ordered list (ignored for other types).
  final int listStart;

  bool get isEmpty => text.isEmpty;

  EditorBlock copyWith({
    EditorBlockType? type,
    MarkedText? text,
    int? listStart,
  }) => EditorBlock(
    id: id,
    type: type ?? this.type,
    text: text ?? this.text,
    listStart: listStart ?? this.listStart,
  );

  @override
  bool operator ==(Object other) =>
      other is EditorBlock &&
      other.id == id &&
      other.type == type &&
      other.text == text &&
      other.listStart == listStart;

  @override
  int get hashCode => Object.hash(id, type, text, listStart);

  @override
  String toString() => 'EditorBlock($id, ${type.name}, ${text.text})';
}
