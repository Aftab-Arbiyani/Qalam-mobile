/// Polish actions (AF2, narrowed by **D5**) — the client vocabulary that maps each
/// user action to a **server** prompt-template key + its variables. This holds NO
/// prompt text (bodies live only on the server, versioned; constraint: never hardcode
/// prompts in UI) — only the identifier + declared variables the orchestrator needs.
/// Pure Dart (no Flutter): labels are plain strings; icons are chosen in the UI.
///
/// **D5 deleted `continue`, `rewrite`, `expand`, `tone` and `freeform`** — the five
/// generation actions — leaving the three that transform text the writer has already
/// written. Their server prompt templates went with them (B2 pruned the catalogue), so
/// sending one of those keys now fails at the orchestrator: this enum and
/// `prompt-catalog.ts` are two halves of one contract, and the server's
/// `prompt-catalog.spec.ts` pins exactly the three keys below.
///
/// `writing_assistant` stays as the wire feature id and prompt-key prefix on purpose
/// (D5 decision 10 — the rename is user-facing copy only). It is Polish's *internal*
/// identifier; no writer ever sees it.
library;

import '../../../../core/utils/typedefs.dart';
import '../entities/ai_suggestion.dart';

/// The aspect an "Improve" action targets. `promptPhrase` is the human phrase sent
/// as the `{{aspect}}` template variable — the server prompt does the rest.
enum ImproveAspect {
  flow('Flow', 'flow and rhythm'),
  clarity('Clarity', 'clarity'),
  grammar('Grammar', 'grammar and correctness'),
  style('Style', 'prose style'),
  dialogue('Dialogue', 'dialogue'),
  description('Description', 'descriptive imagery'),
  scene('Scene', 'scene construction'),
  transition('Transition', 'transitions between ideas');

  const ImproveAspect(this.label, this.promptPhrase);
  final String label;
  final String promptPhrase;
}

enum AssistantActionKind { condense, simplify, improve }

/// One resolved Polish action: kind (+ aspect when parametrised) → the prompt key and
/// variables to send. Immutable and cheap to construct.
class WritingAction {
  const WritingAction._(this.kind, {this.aspect});

  factory WritingAction.of(AssistantActionKind kind) {
    assert(
      kind != AssistantActionKind.improve,
      'Use WritingAction.improve for the parametrised action',
    );
    return WritingAction._(kind);
  }

  factory WritingAction.improve(ImproveAspect aspect) =>
      WritingAction._(AssistantActionKind.improve, aspect: aspect);

  final AssistantActionKind kind;
  final ImproveAspect? aspect;

  /// The server prompt-template key for this action.
  String get promptKey => switch (kind) {
    AssistantActionKind.condense => 'writing_assistant.condense',
    AssistantActionKind.simplify => 'writing_assistant.simplify',
    AssistantActionKind.improve => 'writing_assistant.improve',
  };

  /// The template variables (must match the template's declared `variables`).
  Json get promptVariables => switch (kind) {
    AssistantActionKind.improve => <String, dynamic>{
      'aspect': aspect!.promptPhrase,
    },
    _ => const <String, dynamic>{},
  };

  /// Human label for the action bar / suggestion provenance.
  String get label => switch (kind) {
    AssistantActionKind.condense => 'Condense',
    AssistantActionKind.simplify => 'Simplify',
    AssistantActionKind.improve => 'Improve ${aspect!.label.toLowerCase()}',
  };

  /// The default one-click placement. Never destructive when there is no selection:
  /// with generation gone every action transforms an operand, so the only question is
  /// whether there is a selection to put the result back over.
  AiSuggestionPlacement defaultPlacement({required bool hasSelection}) =>
      hasSelection
      ? AiSuggestionPlacement.replaceSelection
      : AiSuggestionPlacement.insertBelow;
}
