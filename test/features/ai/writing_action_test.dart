/// Polish's action vocabulary (**D5**).
///
/// The tests that named `rewrite`, `tone` and `continueWriting` are gone with the
/// actions themselves — D5 removed the five generation actions, and their server
/// prompt templates went with them (B2 pruned `prompt-catalog.ts`). What is asserted
/// here is the other half of that same contract: this enum and the server catalogue
/// must agree on exactly three keys, and the server's `prompt-catalog.spec.ts` pins
/// its side with `toEqual`.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:umberleaf_mobile/features/ai/domain/entities/ai_suggestion.dart';
import 'package:umberleaf_mobile/features/ai/domain/value_objects/writing_action.dart';

void main() {
  group(
    'WritingAction → server prompt key + variables (no prompt text in client)',
    () {
      test(
        'the one-click actions map to their template key with no variables',
        () {
          final WritingAction condense = WritingAction.of(
            AssistantActionKind.condense,
          );
          expect(condense.promptKey, 'writing_assistant.condense');
          expect(condense.promptVariables, isEmpty);
          expect(condense.label, 'Condense');

          final WritingAction simplify = WritingAction.of(
            AssistantActionKind.simplify,
          );
          expect(simplify.promptKey, 'writing_assistant.simplify');
          expect(simplify.promptVariables, isEmpty);
          expect(simplify.label, 'Simplify');
        },
      );

      test('improve carries the aspect phrase as {{aspect}}', () {
        final WritingAction improve = WritingAction.improve(ImproveAspect.flow);
        expect(improve.promptKey, 'writing_assistant.improve');
        expect(improve.promptVariables, <String, dynamic>{
          'aspect': 'flow and rhythm',
        });
        expect(improve.label, 'Improve flow');
      });

      /// The pin. Three kinds, three keys — a fourth added here without a server
      /// template is a request the orchestrator refuses, and the failure would surface
      /// as a broken button rather than as a contract break.
      test('exactly three actions survive, all under writing_assistant.*', () {
        expect(AssistantActionKind.values, hasLength(3));
        final Set<String> keys = <String>{
          for (final AssistantActionKind kind in AssistantActionKind.values)
            (kind == AssistantActionKind.improve
                    ? WritingAction.improve(ImproveAspect.clarity)
                    : WritingAction.of(kind))
                .promptKey,
        };
        expect(keys, <String>{
          'writing_assistant.condense',
          'writing_assistant.simplify',
          'writing_assistant.improve',
        });
      });

      /// Every surviving action transforms an operand, so placement turns only on
      /// whether there is a selection to put the result back over. The old
      /// `isContinuation` branch — which forced `insertBelow` even with a selection —
      /// went with the generation actions it existed for.
      test(
        'default placement never destroys the chapter when nothing is selected',
        () {
          for (final AssistantActionKind kind in AssistantActionKind.values) {
            final WritingAction action = kind == AssistantActionKind.improve
                ? WritingAction.improve(ImproveAspect.clarity)
                : WritingAction.of(kind);
            expect(
              action.defaultPlacement(hasSelection: true),
              AiSuggestionPlacement.replaceSelection,
            );
            expect(
              action.defaultPlacement(hasSelection: false),
              AiSuggestionPlacement.insertBelow,
            );
          }
        },
      );
    },
  );
}
