/// The editor document — an ordered list of [EditorBlock]s (M4 editor).
///
/// The mutable-but-value-typed working copy the editor edits and autosaves. It is
/// pure Dart with value equality, so a provider `select` rebuilds only on real
/// change, and every mutation returns a new document (no in-place state). Block
/// identities are assigned from a monotonic counter carried on the document so ids
/// stay unique and edits stay deterministic (no uuid/clock in the domain — the
/// testing discipline in docs/40 §38.4).
library;

import 'package:flutter/foundation.dart';

import 'editor_block.dart';
import 'marked_text.dart';

@immutable
class EditorDocument {
  const EditorDocument({required this.blocks, required this.nextId});

  final List<EditorBlock> blocks;

  /// The next block-id ordinal to hand out. Kept on the document so ids are stable
  /// and unique for the document's whole lifetime.
  final int nextId;

  /// A fresh document: one empty paragraph, ready to type into.
  factory EditorDocument.blank() => EditorDocument(
    blocks: <EditorBlock>[EditorBlock.emptyParagraph('b0')],
    nextId: 1,
  );

  /// Build from decoded blocks, seeding the id counter past the highest used id so
  /// new blocks never collide with decoded ones.
  factory EditorDocument.of(List<EditorBlock> blocks) {
    if (blocks.isEmpty) return EditorDocument.blank();
    int maxOrdinal = -1;
    for (final EditorBlock b in blocks) {
      final int? n = _ordinalOf(b.id);
      if (n != null && n > maxOrdinal) maxOrdinal = n;
    }
    return EditorDocument(
      blocks: List<EditorBlock>.unmodifiable(blocks),
      nextId: maxOrdinal + 1,
    );
  }

  bool get isEmpty =>
      blocks.every((EditorBlock b) => b.text.text.trim().isEmpty);

  int indexOfId(String id) => blocks.indexWhere((EditorBlock b) => b.id == id);

  EditorBlock? blockById(String id) {
    final int i = indexOfId(id);
    return i < 0 ? null : blocks[i];
  }

  /// The whole document as plain text (blocks joined by blank lines) — for word
  /// count and the "is there any content?" publish check.
  String get plainText =>
      blocks.map((EditorBlock b) => b.text.text).join('\n\n').trim();

  /// Word count (whitespace-run split) — mirrors the server's derived word_count
  /// closely enough for the client's reading-time estimate and publish gating.
  int get wordCount {
    final String t = plainText;
    if (t.isEmpty) return 0;
    return t.split(RegExp(r'\s+')).where((String w) => w.isNotEmpty).length;
  }

  bool get hasContent => wordCount > 0;

  // ── Functional mutations (each returns a new document) ───────────────────────

  EditorDocument replaceBlock(String id, EditorBlock next) {
    final int i = indexOfId(id);
    if (i < 0) return this;
    final List<EditorBlock> copy = List<EditorBlock>.of(blocks)..[i] = next;
    return _with(copy);
  }

  EditorDocument setBlockText(String id, MarkedText text) {
    final EditorBlock? b = blockById(id);
    if (b == null) return this;
    return replaceBlock(id, b.copyWith(text: text));
  }

  EditorDocument setBlockType(String id, EditorBlockType type) {
    final EditorBlock? b = blockById(id);
    if (b == null) return this;
    return replaceBlock(id, b.copyWith(type: type));
  }

  /// Split [id] at [offset] into two blocks; the new block is a paragraph unless
  /// the source is a list (a list keeps its type so Enter continues the list). The
  /// new block gets a fresh id and is returned for focus handoff.
  ({EditorDocument document, String newBlockId}) splitBlock(
    String id,
    int offset,
  ) {
    final int i = indexOfId(id);
    if (i < 0) return (document: this, newBlockId: id);
    final EditorBlock block = blocks[i];
    final (MarkedText before, MarkedText after) = block.text.splitAt(offset);
    final String newId = 'b$nextId';
    final EditorBlockType newType = block.type.isList
        ? block.type
        : EditorBlockType.paragraph;
    final List<EditorBlock> copy = List<EditorBlock>.of(blocks)
      ..[i] = block.copyWith(text: before)
      ..insert(i + 1, EditorBlock(id: newId, type: newType, text: after));
    return (
      document: EditorDocument(
        blocks: List<EditorBlock>.unmodifiable(copy),
        nextId: nextId + 1,
      ),
      newBlockId: newId,
    );
  }

  /// Merge [id] into its predecessor (backspace at offset 0). Returns the merged
  /// predecessor id and the caret offset where the join happened, for focus.
  ({EditorDocument document, String focusId, int caret})? mergeIntoPrevious(
    String id,
  ) {
    final int i = indexOfId(id);
    if (i <= 0) return null;
    final EditorBlock prev = blocks[i - 1];
    final EditorBlock cur = blocks[i];
    final int caret = prev.text.length;
    final MarkedText merged = prev.text.concat(cur.text);
    final List<EditorBlock> copy = List<EditorBlock>.of(blocks)
      ..[i - 1] = prev.copyWith(text: merged)
      ..removeAt(i);
    return (document: _with(copy), focusId: prev.id, caret: caret);
  }

  /// Insert a new empty paragraph after [afterId] (or at the end if not found).
  ({EditorDocument document, String newBlockId}) insertParagraphAfter(
    String afterId,
  ) {
    final String newId = 'b$nextId';
    final int i = indexOfId(afterId);
    final List<EditorBlock> copy = List<EditorBlock>.of(blocks);
    final EditorBlock fresh = EditorBlock.emptyParagraph(newId);
    if (i < 0) {
      copy.add(fresh);
    } else {
      copy.insert(i + 1, fresh);
    }
    return (
      document: EditorDocument(
        blocks: List<EditorBlock>.unmodifiable(copy),
        nextId: nextId + 1,
      ),
      newBlockId: newId,
    );
  }

  /// Insert [paragraphs] as new paragraph blocks after [afterId] (or at the end if
  /// [afterId] is absent). Blank entries are skipped. A GENERIC structural insert —
  /// the same operation a multi-line paste, an import, or an accepted AI suggestion
  /// reduces to (no AI-specific mutation). New blocks get fresh ids.
  EditorDocument insertParagraphsAfter(String afterId, List<String> paragraphs) {
    final List<String> texts =
        paragraphs.where((String p) => p.trim().isNotEmpty).toList(growable: false);
    if (texts.isEmpty) return this;
    final List<EditorBlock> copy = List<EditorBlock>.of(blocks);
    final int at = indexOfId(afterId);
    final int insertAt = at < 0 ? copy.length : at + 1;
    int ordinal = nextId;
    final List<EditorBlock> fresh = <EditorBlock>[
      for (final String t in texts)
        EditorBlock(
          id: 'b${ordinal++}',
          type: EditorBlockType.paragraph,
          text: MarkedText.plain(t.trim()),
        ),
    ];
    copy.insertAll(insertAt, fresh);
    return EditorDocument(blocks: List<EditorBlock>.unmodifiable(copy), nextId: ordinal);
  }

  /// Append [paragraphs] as new paragraph blocks at the end of the document.
  EditorDocument appendParagraphs(List<String> paragraphs) =>
      insertParagraphsAfter(blocks.isEmpty ? '' : blocks.last.id, paragraphs);

  /// Remove a block, keeping at least one (a lone removed block becomes blank).
  EditorDocument removeBlock(String id) {
    final int i = indexOfId(id);
    if (i < 0) return this;
    if (blocks.length == 1) return EditorDocument.blank();
    final List<EditorBlock> copy = List<EditorBlock>.of(blocks)..removeAt(i);
    return _with(copy);
  }

  EditorDocument _with(List<EditorBlock> next) => EditorDocument(
    blocks: List<EditorBlock>.unmodifiable(next),
    nextId: nextId,
  );

  static int? _ordinalOf(String id) =>
      id.startsWith('b') ? int.tryParse(id.substring(1)) : null;

  @override
  bool operator ==(Object other) =>
      other is EditorDocument &&
      other.nextId == nextId &&
      listEquals(other.blocks, blocks);

  @override
  int get hashCode => Object.hash(nextId, Object.hashAll(blocks));
}
