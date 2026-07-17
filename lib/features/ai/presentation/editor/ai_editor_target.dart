/// The seam between an accepted AI suggestion and a document editor (AF2). The AI
/// feature owns this interface; a host editor implements it (the writing feature wires
/// it to `CurrentDraftController`). Every apply returns an [AiApplyHandle] whose
/// [undo] restores the pre-apply document THROUGH the editor's own commands — so
/// "Undo AI application" is just another edit, and autosave/offline-sync/version keep
/// working with no AI-specific logic. The AI never mutates the document itself.
library;

import 'package:flutter/foundation.dart';

import '../../domain/entities/ai_suggestion.dart';
import '../../domain/value_objects/ai_writing_context.dart';

/// The result of applying a suggestion — how it landed + how to undo it.
class AiApplyHandle {
  const AiApplyHandle({required this.placement, required this.undo});
  final AiSuggestionPlacement placement;

  /// Restores the document to its state just before this apply (via editor commands).
  final VoidCallback undo;
}

abstract interface class AiEditorTarget {
  /// The writing context (operand + metadata) captured for this session.
  AiWritingContext get context;

  /// Whether there is a non-empty selection to replace.
  bool get canReplaceSelection;

  /// Replace the current selection with [text]. Returns null if nothing was replaced.
  AiApplyHandle? replaceSelection(String text);

  /// Insert [text] as new paragraph(s) below the current block.
  AiApplyHandle? insertBelow(String text);

  /// Append [text] as new paragraph(s) at the end of the document.
  AiApplyHandle? append(String text);

  /// Save [text] as a brand-new draft (leaving the current document untouched).
  /// Returns the new draft's route id, or null if it couldn't be created.
  Future<String?> saveAsNewDraft(String text);
}
