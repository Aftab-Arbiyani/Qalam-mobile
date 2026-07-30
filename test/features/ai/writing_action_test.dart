import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/ai/domain/entities/ai_suggestion.dart';
import 'package:qalam_mobile/features/ai/domain/value_objects/writing_action.dart';

void main() {
  group('WritingAction → server prompt key + variables (no prompt text in client)', () {
    test('simple actions map to their template key with no variables', () {
      final WritingAction rewrite = WritingAction.of(AssistantActionKind.rewrite);
      expect(rewrite.promptKey, 'writing_assistant.rewrite');
      expect(rewrite.promptVariables, isEmpty);
      expect(rewrite.label, 'Rewrite');
    });

    test('improve carries the aspect phrase as {{aspect}}', () {
      final WritingAction improve = WritingAction.improve(ImproveAspect.flow);
      expect(improve.promptKey, 'writing_assistant.improve');
      expect(improve.promptVariables, <String, dynamic>{'aspect': 'flow and rhythm'});
      expect(improve.label, 'Improve flow');
    });

    test('tone carries the tone phrase as {{tone}}', () {
      final WritingAction tone = WritingAction.tone(WritingTone.formal);
      expect(tone.promptKey, 'writing_assistant.tone');
      expect(tone.promptVariables, <String, dynamic>{'tone': 'formal'});
      expect(tone.label, 'Formal tone');
    });

    test('default placement never destroys the chapter when nothing is selected', () {
      final WritingAction rewrite = WritingAction.of(AssistantActionKind.rewrite);
      expect(
        rewrite.defaultPlacement(hasSelection: true),
        AiSuggestionPlacement.replaceSelection,
      );
      expect(
        rewrite.defaultPlacement(hasSelection: false),
        AiSuggestionPlacement.insertBelow,
      );
      expect(
        WritingAction.of(AssistantActionKind.continueWriting).defaultPlacement(hasSelection: true),
        AiSuggestionPlacement.insertBelow,
      );
    });
  });
}
