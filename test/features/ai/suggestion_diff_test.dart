import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/ai/domain/entities/ai_suggestion.dart';

void main() {
  group('SuggestionDiff.compute', () {
    test('detects a single word substitution', () {
      final SuggestionDiff diff = SuggestionDiff.compute('the cat sat', 'the dog sat');
      expect(diff.addedWords, 1);
      expect(diff.removedWords, 1);
      expect(diff.isNoChange, isFalse);
      expect(
        diff.segments.where((DiffSegment s) => s.kind == DiffKind.removed).single.text,
        'cat',
      );
      expect(
        diff.segments.where((DiffSegment s) => s.kind == DiffKind.added).single.text,
        'dog',
      );
    });

    test('identical text is a no-change diff', () {
      final SuggestionDiff diff = SuggestionDiff.compute('same words here', 'same words here');
      expect(diff.isNoChange, isTrue);
      expect(diff.segments.every((DiffSegment s) => s.kind == DiffKind.equal), isTrue);
    });

    test('empty original yields all additions', () {
      final SuggestionDiff diff = SuggestionDiff.compute('', 'brand new line');
      expect(diff.removedWords, 0);
      expect(diff.addedWords, 3);
    });
  });

  group('AiSuggestion', () {
    test('withStatus preserves content and flips only the status', () {
      final AiSuggestion s = AiSuggestion(
        id: '1',
        sourceFeature: 'writing_assistant',
        sourceLabel: 'Rewrite',
        content: 'new text',
        originalText: 'old text',
        placement: AiSuggestionPlacement.replaceSelection,
        createdAt: DateTime(2026),
        status: AiSuggestionStatus.ready,
      );
      final AiSuggestion applied = s.withStatus(AiSuggestionStatus.applied);
      expect(applied.status, AiSuggestionStatus.applied);
      expect(applied.content, 'new text');
      expect(identical(applied, s), isFalse);
    });
  });
}
