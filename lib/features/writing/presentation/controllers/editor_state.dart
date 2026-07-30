/// The editor's working state (M4). Pairs the persisted [Draft] with the decoded,
/// live [EditorDocument] the block editor edits, plus transient UI facts (autosave
/// in flight, last-saved time, a pending focus request from a block split/merge).
///
/// The [Draft.content] map may lag the [document] between autosaves; [liveDraft]
/// folds the current document (encoded to TipTap) and derived counts back into the
/// draft for validation, preview, and persistence.
library;

import 'package:flutter/foundation.dart';

import '../../domain/editor/editor_document.dart';
import '../../domain/editor/tiptap_codec.dart';
import '../../domain/entities/draft.dart';
import '../../domain/value_objects/draft_validation.dart';

/// A request to place the caret in a specific block (after a split/merge/add).
@immutable
class FocusRequest {
  const FocusRequest(this.blockId, this.caret);
  final String blockId;
  final int caret;
}

@immutable
class EditorState {
  const EditorState({
    required this.draft,
    required this.document,
    this.autosaving = false,
    this.lastSavedAt,
    this.focus,
  });

  final Draft draft;
  final EditorDocument document;

  /// True while a local autosave write is in flight (drives the save indicator).
  final bool autosaving;
  final DateTime? lastSavedAt;

  /// A one-shot focus request the editor consumes then clears.
  final FocusRequest? focus;

  /// Words per minute used for the client-side reading-time estimate (the server
  /// recomputes authoritatively on save).
  static const int _wpm = 200;

  /// The draft with the live document folded in — used for validation, preview,
  /// and persistence.
  Draft get liveDraft {
    final int words = document.wordCount;
    return draft.copyWith(
      content: encodeDocument(document),
      wordCount: words,
      readingTimeSeconds: words <= 0 ? 0 : (words / _wpm * 60).round(),
    );
  }

  DraftValidation get validation =>
      DraftValidation.of(draft.copyWith(wordCount: document.wordCount));

  EditorState copyWith({
    Draft? draft,
    EditorDocument? document,
    bool? autosaving,
    DateTime? lastSavedAt,
    FocusRequest? focus,
    bool clearFocus = false,
  }) => EditorState(
    draft: draft ?? this.draft,
    document: document ?? this.document,
    autosaving: autosaving ?? this.autosaving,
    lastSavedAt: lastSavedAt ?? this.lastSavedAt,
    focus: clearFocus ? null : (focus ?? this.focus),
  );
}
