/// Wires an accepted AI suggestion to the draft editor (AF2). Implements the AI
/// feature's [AiEditorTarget] against [CurrentDraftController]: it snapshots the
/// document before each apply and applies through the controller's GENERIC commands
/// (`replaceRange` / `insertParagraphsAfter` / `appendParagraphs`) — so an accepted
/// suggestion is indistinguishable from manual editing (autosave, offline sync,
/// version), and [AiApplyHandle.undo] restores the snapshot the same way.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ai/domain/entities/ai_suggestion.dart';
import '../../../ai/domain/value_objects/ai_writing_context.dart';
import '../../../ai/presentation/editor/ai_editor_target.dart';
import '../../domain/editor/editor_document.dart';
import '../controllers/current_draft_controller.dart';
import '../controllers/draft_list_controller.dart';
import 'editor_selection_controller.dart';

class DraftAiEditorTarget implements AiEditorTarget {
  DraftAiEditorTarget._({
    required CurrentDraftController notifier,
    required EditorDocument Function() readDocument,
    required Future<String> Function(String text) saveDraft,
    required AiWritingContext context,
    required String anchorBlockId,
    required bool hasSelection,
    required String? selectionBlockId,
    required int selectionStart,
    required int selectionEnd,
  })  : _notifier = notifier,
        _readDocument = readDocument,
        _saveDraft = saveDraft,
        _context = context,
        _anchorBlockId = anchorBlockId,
        _hasSelection = hasSelection,
        _selectionBlockId = selectionBlockId,
        _selectionStart = selectionStart,
        _selectionEnd = selectionEnd;

  final CurrentDraftController _notifier;
  final EditorDocument Function() _readDocument;
  final Future<String> Function(String text) _saveDraft;
  final AiWritingContext _context;
  final String _anchorBlockId;
  final bool _hasSelection;
  final String? _selectionBlockId;
  final int _selectionStart;
  final int _selectionEnd;

  /// Build a target from the editor's current state + selection. Safe while the editor
  /// screen is mounted (the AI panel is a modal sheet over it).
  static DraftAiEditorTarget build(WidgetRef ref, String routeId) {
    final CurrentDraftController notifier =
        ref.read(currentDraftControllerProvider(routeId).notifier);
    final EditorDocument doc =
        ref.read(currentDraftControllerProvider(routeId)).asData?.value.document ??
            EditorDocument.blank();
    final draft = ref.read(currentDraftControllerProvider(routeId)).asData?.value.draft;
    final EditorSelection? sel = ref.read(editorSelectionControllerProvider);

    String selectionText = '';
    final bool live = sel != null && !sel.isCollapsed;
    if (live) {
      final block = doc.blockById(sel.blockId);
      if (block != null) selectionText = block.text.slice(sel.start, sel.end).text;
    }
    final bool hasSelection = live && selectionText.trim().isNotEmpty;

    final AiWritingContext context = AiWritingContext(
      selectionText: selectionText,
      chapterText: doc.plainText,
      title: draft?.title ?? '',
      genre: draft?.genreName,
      language: draft?.languageName ?? '',
      wordCount: doc.wordCount,
      tags: draft?.tags ?? const <String>[],
    );

    return DraftAiEditorTarget._(
      notifier: notifier,
      readDocument: () =>
          ref.read(currentDraftControllerProvider(routeId)).asData?.value.document ?? doc,
      saveDraft: (String text) =>
          ref.read(draftListControllerProvider.notifier).newDraftFromText(text),
      context: context,
      anchorBlockId: sel?.blockId ?? (doc.blocks.isEmpty ? '' : doc.blocks.last.id),
      hasSelection: hasSelection,
      selectionBlockId: hasSelection ? sel.blockId : null,
      selectionStart: sel?.start ?? 0,
      selectionEnd: sel?.end ?? 0,
    );
  }

  @override
  AiWritingContext get context => _context;

  @override
  bool get canReplaceSelection => _hasSelection && _selectionBlockId != null;

  @override
  AiApplyHandle? replaceSelection(String text) {
    if (!canReplaceSelection) return null;
    final EditorDocument before = _readDocument();
    _notifier.replaceRange(_selectionBlockId!, _selectionStart, _selectionEnd, text.trim());
    return AiApplyHandle(
      placement: AiSuggestionPlacement.replaceSelection,
      undo: () => _notifier.replaceDocument(before),
    );
  }

  @override
  AiApplyHandle? insertBelow(String text) {
    final List<String> paragraphs = _splitParagraphs(text);
    if (paragraphs.isEmpty) return null;
    final EditorDocument before = _readDocument();
    _notifier.insertParagraphsAfter(_anchorBlockId, paragraphs);
    return AiApplyHandle(
      placement: AiSuggestionPlacement.insertBelow,
      undo: () => _notifier.replaceDocument(before),
    );
  }

  @override
  AiApplyHandle? append(String text) {
    final List<String> paragraphs = _splitParagraphs(text);
    if (paragraphs.isEmpty) return null;
    final EditorDocument before = _readDocument();
    _notifier.appendParagraphs(paragraphs);
    return AiApplyHandle(
      placement: AiSuggestionPlacement.append,
      undo: () => _notifier.replaceDocument(before),
    );
  }

  @override
  Future<String?> saveAsNewDraft(String text) async {
    final String trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    return _saveDraft(trimmed);
  }

  /// Split on blank lines into paragraph blocks (a single-paragraph suggestion yields
  /// one block).
  static List<String> _splitParagraphs(String text) => text
      .trim()
      .split(RegExp(r'\n\s*\n'))
      .map((String p) => p.trim())
      .where((String p) => p.isNotEmpty)
      .toList(growable: false);
}
