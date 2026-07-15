import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/writing/domain/entities/draft.dart';
import 'package:qalam_mobile/features/writing/domain/value_objects/draft_validation.dart';

Draft _draft({
  String title = 'Title',
  String language = 'ur',
  String? genre = 'ghazal',
  int words = 10,
}) => Draft(
  localId: 'loc-1',
  title: title,
  languageCode: language,
  genreSlug: genre,
  wordCount: words,
  createdAt: DateTime.utc(2026, 7),
  localUpdatedAt: DateTime.utc(2026, 7),
);

void main() {
  group('DraftValidation', () {
    test('a complete draft can publish', () {
      expect(DraftValidation.of(_draft()).canPublish, isTrue);
      expect(DraftValidation.of(_draft()).missing, isEmpty);
    });

    test('flags a missing title', () {
      final v = DraftValidation.of(_draft(title: '  '));
      expect(v.canPublish, isFalse);
      expect(v.isMissing(PublishRequirement.title), isTrue);
    });

    test('flags a missing language', () {
      expect(
        DraftValidation.of(
          _draft(language: ''),
        ).isMissing(PublishRequirement.language),
        isTrue,
      );
    });

    test('flags a missing genre', () {
      expect(
        DraftValidation.of(
          _draft(genre: null),
        ).isMissing(PublishRequirement.genre),
        isTrue,
      );
    });

    test('flags empty content', () {
      expect(
        DraftValidation.of(
          _draft(words: 0),
        ).isMissing(PublishRequirement.content),
        isTrue,
      );
    });

    test('reports every missing requirement for a blank draft', () {
      final v = DraftValidation.of(
        _draft(title: '', language: '', genre: null, words: 0),
      );
      expect(v.missing, <PublishRequirement>[
        PublishRequirement.title,
        PublishRequirement.language,
        PublishRequirement.genre,
        PublishRequirement.content,
      ]);
    });
  });
}
