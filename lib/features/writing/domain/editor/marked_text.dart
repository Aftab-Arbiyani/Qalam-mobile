/// Inline rich text with mark ranges (docs/40 §19.4; M4 editor).
///
/// The editor's inline model — the leaf content of a single [EditorBlock]. A run
/// of plain [text] plus a set of half-open `[start, end)` [MarkRange]s carrying the
/// three backend-whitelisted marks (bold / italic / underline). There is NO link
/// mark and no other inline styling, so the model is structurally incapable of
/// producing content the server would reject (422 `PIECE_CONTENT_INVALID`).
///
/// Pure Dart — no Flutter, no I/O. All mutation is functional (returns a new
/// value), and every edit maps the mark ranges through the text change so marks
/// stay pinned to their characters. Unit-tested; the presentation layer's
/// `RichTextEditingController` is a thin adapter over this.
library;

import 'package:flutter/foundation.dart';

import '../../../reading/domain/entities/content_node.dart' show TextMark;

export '../../../reading/domain/entities/content_node.dart' show TextMark;

/// A half-open `[start, end)` span of a single [mark] over a [MarkedText].
@immutable
class MarkRange {
  const MarkRange(this.start, this.end, this.mark);

  final int start;
  final int end;
  final TextMark mark;

  bool get isEmpty => end <= start;

  MarkRange copyWith({int? start, int? end}) =>
      MarkRange(start ?? this.start, end ?? this.end, mark);

  @override
  bool operator ==(Object other) =>
      other is MarkRange &&
      other.start == start &&
      other.end == end &&
      other.mark == mark;

  @override
  int get hashCode => Object.hash(start, end, mark);

  @override
  String toString() => 'MarkRange($start, $end, ${mark.name})';
}

/// A contiguous run of text sharing the same active mark set (for rendering).
typedef StyledRun = ({String text, Set<TextMark> marks});

/// Immutable inline content: [text] with a normalized list of [marks].
@immutable
class MarkedText {
  const MarkedText._(this.text, this.marks);

  /// The canonical constructor — normalizes (clamps, drops empty, sorts, and
  /// merges adjacent/overlapping ranges of the same mark) so equality is stable.
  factory MarkedText(
    String text, [
    List<MarkRange> marks = const <MarkRange>[],
  ]) {
    return MarkedText._(text, _normalize(marks, text.length));
  }

  /// Plain text with no marks.
  factory MarkedText.plain(String text) =>
      MarkedText._(text, const <MarkRange>[]);

  final String text;
  final List<MarkRange> marks;

  static final MarkedText empty = MarkedText.plain('');

  int get length => text.length;
  bool get isEmpty => text.isEmpty;
  bool get isNotEmpty => text.isNotEmpty;

  /// The set of marks that cover EVERY character of `[start, end)` — i.e. the
  /// marks a toolbar would show as "active" for the current selection. For a
  /// collapsed selection (`start == end`) it reports the marks at the caret
  /// (the marks of the character just before it, so typing continues the run).
  Set<TextMark> activeMarks(int start, int end) {
    final int s = start.clamp(0, length);
    final int e = end.clamp(0, length);
    if (s == e) {
      if (s == 0) return const <TextMark>{};
      return _marksAt(s - 1);
    }
    return <TextMark>{
      for (final TextMark mark in TextMark.values)
        if (_coversAll(mark, s, e)) mark,
    };
  }

  /// Toggle [mark] over `[start, end)`: if the whole range already has it, remove
  /// it there; otherwise add it across the whole range. A collapsed selection is a
  /// no-op (there is nothing to mark yet).
  MarkedText toggleMark(TextMark mark, int start, int end) {
    final int s = start.clamp(0, length);
    final int e = end.clamp(0, length);
    if (s >= e) return this;
    final bool has = _coversAll(mark, s, e);
    final List<MarkRange> next = has
        ? _removeMark(mark, s, e)
        : <MarkRange>[...marks, MarkRange(s, e, mark)];
    return MarkedText(text, next);
  }

  /// Apply a single contiguous text replacement — the shape every keystroke,
  /// paste, or delete reduces to: remove `[start, start + removed)` and insert
  /// [inserted] at [start]. Mark ranges are shifted/clipped so they stay pinned to
  /// their surviving characters; text inserted inside a marked run inherits it.
  MarkedText replace(int start, int removed, String inserted) {
    final int s = start.clamp(0, length);
    final int delEnd = (s + removed).clamp(0, length);
    final int delLen = delEnd - s;
    final int insLen = inserted.length;
    final String nextText = text.replaceRange(s, delEnd, inserted);

    final List<MarkRange> next = <MarkRange>[];
    for (final MarkRange r in marks) {
      // Map each endpoint through the edit.
      final int ns = _mapIndex(r.start, s, delEnd, delLen, insLen);
      final int ne = _mapIndex(r.end, s, delEnd, delLen, insLen);
      if (ne > ns) next.add(MarkRange(ns, ne, r.mark));
    }
    return MarkedText(nextText, next);
  }

  /// Split into `[0, index)` and `[index, end)` — used when a block splits.
  (MarkedText, MarkedText) splitAt(int index) {
    final int i = index.clamp(0, length);
    return (slice(0, i), slice(i, length));
  }

  /// The sub-range `[start, end)` as its own [MarkedText], marks preserved.
  MarkedText slice(int start, int end) {
    final int s = start.clamp(0, length);
    final int e = end.clamp(s, length);
    final String sub = text.substring(s, e);
    final List<MarkRange> subMarks = <MarkRange>[];
    for (final MarkRange r in marks) {
      final int ns = (r.start.clamp(s, e)) - s;
      final int ne = (r.end.clamp(s, e)) - s;
      if (ne > ns) subMarks.add(MarkRange(ns, ne, r.mark));
    }
    return MarkedText(sub, subMarks);
  }

  /// Concatenate — used when a block merges into the one before it.
  MarkedText concat(MarkedText other) {
    final int offset = length;
    return MarkedText(text + other.text, <MarkRange>[
      ...marks,
      for (final MarkRange r in other.marks)
        MarkRange(r.start + offset, r.end + offset, r.mark),
    ]);
  }

  /// Coalesce into consecutive runs of equal mark sets — what the renderer and
  /// the [RichTextEditingController] paint. Never empty for non-empty text.
  List<StyledRun> runs() {
    if (isEmpty) return const <StyledRun>[];
    final List<StyledRun> out = <StyledRun>[];
    final StringBuffer buffer = StringBuffer();
    Set<TextMark> current = _marksAt(0);
    for (int i = 0; i < length; i++) {
      final Set<TextMark> at = _marksAt(i);
      if (!setEquals(at, current)) {
        out.add((text: buffer.toString(), marks: current));
        buffer.clear();
        current = at;
      }
      buffer.write(text[i]);
    }
    out.add((text: buffer.toString(), marks: current));
    return out;
  }

  MarkedText copyWith({String? text, List<MarkRange>? marks}) =>
      MarkedText(text ?? this.text, marks ?? this.marks);

  // ── Internals ────────────────────────────────────────────────────────────────

  Set<TextMark> _marksAt(int index) => <TextMark>{
    for (final MarkRange r in marks)
      if (index >= r.start && index < r.end) r.mark,
  };

  bool _coversAll(TextMark mark, int start, int end) {
    // Every character in [start, end) must fall inside some range of `mark`.
    for (int i = start; i < end; i++) {
      bool covered = false;
      for (final MarkRange r in marks) {
        if (r.mark == mark && i >= r.start && i < r.end) {
          covered = true;
          break;
        }
      }
      if (!covered) return false;
    }
    return true;
  }

  List<MarkRange> _removeMark(TextMark mark, int start, int end) {
    final List<MarkRange> next = <MarkRange>[];
    for (final MarkRange r in marks) {
      if (r.mark != mark || r.end <= start || r.start >= end) {
        next.add(r);
        continue;
      }
      if (r.start < start) next.add(MarkRange(r.start, start, mark));
      if (r.end > end) next.add(MarkRange(end, r.end, mark));
    }
    return next;
  }

  /// Map an index through a `[from, to)` deletion + insertion of [insLen]. An
  /// endpoint strictly before the edit is unchanged; at or after it shifts by the
  /// net length change — so for a pure insertion, text inserted at a mark's start
  /// boundary is NOT swept into the mark (and at its end boundary extends it).
  static int _mapIndex(int index, int from, int to, int delLen, int insLen) {
    if (index < from) return index;
    if (index >= to) return index - delLen + insLen;
    // Index fell inside the deleted region — collapse it to the edit point (so a
    // mark that partially covered the deletion clips cleanly to the new text).
    return from + insLen;
  }

  static List<MarkRange> _normalize(List<MarkRange> input, int textLength) {
    final Map<TextMark, List<MarkRange>> byMark = <TextMark, List<MarkRange>>{};
    for (final MarkRange r in input) {
      final int s = r.start.clamp(0, textLength);
      final int e = r.end.clamp(0, textLength);
      if (e <= s) continue;
      (byMark[r.mark] ??= <MarkRange>[]).add(MarkRange(s, e, r.mark));
    }
    final List<MarkRange> out = <MarkRange>[];
    for (final MapEntry<TextMark, List<MarkRange>> entry in byMark.entries) {
      final List<MarkRange> ranges = entry.value
        ..sort((MarkRange a, MarkRange b) => a.start.compareTo(b.start));
      int curStart = ranges.first.start;
      int curEnd = ranges.first.end;
      for (int i = 1; i < ranges.length; i++) {
        final MarkRange r = ranges[i];
        if (r.start <= curEnd) {
          if (r.end > curEnd) curEnd = r.end;
        } else {
          out.add(MarkRange(curStart, curEnd, entry.key));
          curStart = r.start;
          curEnd = r.end;
        }
      }
      out.add(MarkRange(curStart, curEnd, entry.key));
    }
    out.sort((MarkRange a, MarkRange b) {
      final int byStart = a.start.compareTo(b.start);
      if (byStart != 0) return byStart;
      return a.mark.index.compareTo(b.mark.index);
    });
    return List<MarkRange>.unmodifiable(out);
  }

  @override
  bool operator ==(Object other) =>
      other is MarkedText &&
      other.text == text &&
      listEquals(other.marks, marks);

  @override
  int get hashCode => Object.hash(text, Object.hashAll(marks));

  @override
  String toString() => 'MarkedText("$text", $marks)';
}
