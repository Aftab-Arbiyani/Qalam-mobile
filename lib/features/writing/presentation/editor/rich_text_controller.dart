/// A [TextEditingController] that renders inline marks (M4 editor).
///
/// The bridge between Flutter's plain-text editing widget and our [MarkedText]
/// model: it tracks bold / italic / underline ranges alongside the text, maps them
/// through every edit (so a mark stays pinned to its characters), and paints them
/// by overriding [buildTextSpan]. There is no other inline styling — the editor is
/// structurally incapable of producing a mark the backend would reject.
///
/// Italic is suppressed for RTL (Nastaliq) rendering to match the reader
/// (docs/41 §4.4); the mark is still stored, just not painted.
library;

import 'package:flutter/material.dart';

import '../../domain/editor/marked_text.dart';

class RichTextEditingController extends TextEditingController {
  RichTextEditingController({
    required MarkedText marked,
    this.suppressItalic = false,
  }) : _marks = marked.marks,
       super(text: marked.text);

  List<MarkRange> _marks;
  final bool suppressItalic;
  bool _syncing = false;

  /// The current text + marks as a [MarkedText].
  MarkedText get marked => MarkedText(text, _marks);

  /// Replace text + marks wholesale (a structural sync from the controller state),
  /// without running the edit-diff. Preserves [selection] when given (clamped to
  /// the new text), else collapses the caret at the end.
  void setMarked(MarkedText value, {TextSelection? selection}) {
    _syncing = true;
    _marks = value.marks;
    final int len = value.text.length;
    final TextSelection resolved = selection == null
        ? TextSelection.collapsed(offset: len)
        : TextSelection(
            baseOffset: selection.baseOffset.clamp(0, len),
            extentOffset: selection.extentOffset.clamp(0, len),
          );
    this.value = TextEditingValue(text: value.text, selection: resolved);
    _syncing = false;
  }

  @override
  set value(TextEditingValue newValue) {
    final String oldText = value.text;
    if (!_syncing && newValue.text != oldText) {
      final _Edit edit = _diff(oldText, newValue.text);
      _marks = MarkedText(
        oldText,
        _marks,
      ).replace(edit.start, edit.removed, edit.inserted).marks;
    }
    super.value = newValue;
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final TextStyle base = style ?? const TextStyle();
    final List<StyledRun> runs = marked.runs();
    if (runs.isEmpty) return TextSpan(text: text, style: base);
    final bool composing =
        withComposing &&
        !value.composing.isCollapsed &&
        value.isComposingRangeValid;
    if (!composing) {
      return TextSpan(
        style: base,
        children: <InlineSpan>[
          for (final StyledRun run in runs)
            TextSpan(text: run.text, style: _applyMarks(base, run.marks)),
        ],
      );
    }
    // Keep the marks painted WHILE composing (no flash back to plain on every
    // word) and overlay the platform IME's composing underline on the segment
    // inside the composing range.
    final int cStart = value.composing.start;
    final int cEnd = value.composing.end;
    final List<InlineSpan> children = <InlineSpan>[];
    int offset = 0;
    for (final StyledRun run in runs) {
      final TextStyle runStyle = _applyMarks(base, run.marks);
      final int runEnd = offset + run.text.length;
      final int mid0 = cStart.clamp(offset, runEnd);
      final int mid1 = cEnd.clamp(offset, runEnd);
      void add(int s, int e, TextStyle st) {
        if (e > s) {
          children.add(TextSpan(text: text.substring(s, e), style: st));
        }
      }

      add(offset, mid0, runStyle);
      add(mid0, mid1, _underlined(runStyle));
      add(mid1, runEnd, runStyle);
      offset = runEnd;
    }
    return TextSpan(style: base, children: children);
  }

  static TextStyle _underlined(TextStyle style) => style.copyWith(
    decoration: TextDecoration.combine(<TextDecoration>[
      if (style.decoration case final TextDecoration d) d,
      TextDecoration.underline,
    ]),
  );

  TextStyle _applyMarks(TextStyle base, Set<TextMark> marks) {
    TextStyle style = base;
    if (marks.contains(TextMark.bold)) {
      style = style.copyWith(fontWeight: FontWeight.w700);
    }
    if (marks.contains(TextMark.italic) && !suppressItalic) {
      style = style.copyWith(fontStyle: FontStyle.italic);
    }
    if (marks.contains(TextMark.underline)) {
      style = style.copyWith(decoration: TextDecoration.underline);
    }
    return style;
  }

  /// Reduce two texts to the single contiguous replacement between them (the shape
  /// every keystroke/paste/delete takes): common prefix, common suffix, middle.
  _Edit _diff(String a, String b) {
    final int maxPrefix = a.length < b.length ? a.length : b.length;
    int prefix = 0;
    while (prefix < maxPrefix && a.codeUnitAt(prefix) == b.codeUnitAt(prefix)) {
      prefix++;
    }
    int suffix = 0;
    final int maxSuffix = maxPrefix - prefix;
    while (suffix < maxSuffix &&
        a.codeUnitAt(a.length - 1 - suffix) ==
            b.codeUnitAt(b.length - 1 - suffix)) {
      suffix++;
    }
    return _Edit(
      start: prefix,
      removed: a.length - prefix - suffix,
      inserted: b.substring(prefix, b.length - suffix),
    );
  }
}

class _Edit {
  const _Edit({
    required this.start,
    required this.removed,
    required this.inserted,
  });
  final int start;
  final int removed;
  final String inserted;
}
