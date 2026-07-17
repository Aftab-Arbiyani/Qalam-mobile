/// Writing Assistant actions (AF2) — the client vocabulary that maps each user
/// action to a **server** prompt-template key + its variables. This holds NO prompt
/// text (bodies live only on the server, versioned; constraint: never hardcode
/// prompts in UI) — only the identifier + declared variables the orchestrator needs.
/// Pure Dart (no Flutter): labels are plain strings; icons are chosen in the UI.
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

/// Target tone for a "Tone" action. `promptPhrase` is the `{{tone}}` variable.
enum WritingTone {
  formal('Formal', 'formal'),
  casual('Casual', 'casual and conversational'),
  poetic('Poetic', 'poetic and lyrical'),
  professional('Professional', 'professional'),
  suspenseful('Suspenseful', 'suspenseful and tense'),
  inspirational('Inspirational', 'inspirational and uplifting');

  const WritingTone(this.label, this.promptPhrase);
  final String label;
  final String promptPhrase;
}

enum AssistantActionKind {
  continueWriting,
  rewrite,
  expand,
  condense,
  simplify,
  improve,
  tone,
  freeform,
}

/// One resolved assistant action: kind (+ aspect/tone when parametrised) → the
/// prompt key and variables to send. Immutable and cheap to construct.
class WritingAction {
  const WritingAction._(this.kind, {this.aspect, this.tone});

  factory WritingAction.of(AssistantActionKind kind) {
    assert(
      kind != AssistantActionKind.improve && kind != AssistantActionKind.tone,
      'Use WritingAction.improve / WritingAction.tone for parametrised actions',
    );
    return WritingAction._(kind);
  }

  factory WritingAction.improve(ImproveAspect aspect) =>
      WritingAction._(AssistantActionKind.improve, aspect: aspect);

  factory WritingAction.tone(WritingTone tone) =>
      WritingAction._(AssistantActionKind.tone, tone: tone);

  final AssistantActionKind kind;
  final ImproveAspect? aspect;
  final WritingTone? tone;

  /// The server prompt-template key for this action.
  String get promptKey => switch (kind) {
        AssistantActionKind.continueWriting => 'writing_assistant.continue',
        AssistantActionKind.rewrite => 'writing_assistant.rewrite',
        AssistantActionKind.expand => 'writing_assistant.expand',
        AssistantActionKind.condense => 'writing_assistant.condense',
        AssistantActionKind.simplify => 'writing_assistant.simplify',
        AssistantActionKind.improve => 'writing_assistant.improve',
        AssistantActionKind.tone => 'writing_assistant.tone',
        AssistantActionKind.freeform => 'writing_assistant.freeform',
      };

  /// The template variables (must match the template's declared `variables`).
  Json get promptVariables => switch (kind) {
        AssistantActionKind.improve => <String, dynamic>{'aspect': aspect!.promptPhrase},
        AssistantActionKind.tone => <String, dynamic>{'tone': tone!.promptPhrase},
        _ => const <String, dynamic>{},
      };

  /// Human label for the action bar / suggestion provenance.
  String get label => switch (kind) {
        AssistantActionKind.continueWriting => 'Continue writing',
        AssistantActionKind.rewrite => 'Rewrite',
        AssistantActionKind.expand => 'Expand',
        AssistantActionKind.condense => 'Condense',
        AssistantActionKind.simplify => 'Simplify',
        AssistantActionKind.improve => 'Improve ${aspect!.label.toLowerCase()}',
        AssistantActionKind.tone => '${tone!.label} tone',
        AssistantActionKind.freeform => 'Ask AI',
      };

  /// Continuation actions grow the text; the rest transform an operand.
  bool get isContinuation =>
      kind == AssistantActionKind.continueWriting || kind == AssistantActionKind.freeform;

  /// The default one-click placement. Never destructive when there is no selection:
  /// transforms fall back to inserting below rather than replacing the chapter.
  AiSuggestionPlacement defaultPlacement({required bool hasSelection}) {
    if (isContinuation) return AiSuggestionPlacement.insertBelow;
    return hasSelection
        ? AiSuggestionPlacement.replaceSelection
        : AiSuggestionPlacement.insertBelow;
  }
}
