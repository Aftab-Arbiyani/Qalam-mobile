/// Tracks the editor's active block + text selection (M4). The block fields push
/// their focus/selection here; the formatting toolbar reads it to show which marks
/// are active and to know where to apply a toggle. Pure UI state — a single
/// autodispose notifier scoped to the open editor.
library;

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'editor_selection_controller.g.dart';

@immutable
class EditorSelection {
  const EditorSelection({
    required this.blockId,
    required this.start,
    required this.end,
  });

  final String blockId;
  final int start;
  final int end;

  bool get isCollapsed => start == end;

  @override
  bool operator ==(Object other) =>
      other is EditorSelection &&
      other.blockId == blockId &&
      other.start == start &&
      other.end == end;

  @override
  int get hashCode => Object.hash(blockId, start, end);
}

@riverpod
class EditorSelectionController extends _$EditorSelectionController {
  @override
  EditorSelection? build() => null;

  void set(String blockId, int start, int end) =>
      state = EditorSelection(blockId: blockId, start: start, end: end);

  void clearIf(String blockId) {
    if (state?.blockId == blockId) state = null;
  }
}
