/// The D5 copy sweep, as a standing guard (**M4**).
///
/// The plan's final gate for this phase was a grep:
///
/// ```
/// grep -rn --include=*.dart -E "'[^']*\bAI\b[^']*'" lib | grep -v '\.g\.dart' | grep -v '///'
/// ```
///
/// It returns zero. **A grep that ran once proves nothing about tomorrow**, though, and
/// the single most likely way D5 unravels is not someone reinstating a deleted feature —
/// it is someone adding an error case, a lock card or a snackbar and reaching for the
/// word out of habit. So the interesting half of the sweep is pinned here instead.
///
/// [AiErrorCopy] is the right place to pin it: it is the largest concentration of
/// user-facing sentences in the feature, it is reached from every tool, and it is
/// exhaustive over a fixed set of codes — so this can walk *every* branch rather than
/// sampling the ones a screen happens to render.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:umberleaf_mobile/features/ai/domain/value_objects/ai_feature_ids.dart';
import 'package:umberleaf_mobile/features/ai/presentation/support/ai_error_copy.dart';
import 'package:umberleaf_mobile/features/ai/presentation/widgets/model_disclosure_note.dart';
import 'package:umberleaf_mobile/shared/domain/error_codes.dart';

/// Every code `AiErrorCopy` maps, plus the unknown-code fallback.
const List<String> _codes = <String>[
  ErrorCodes.aiDisabled,
  ErrorCodes.aiDisabledByUser,
  ErrorCodes.aiFeatureDisabled,
  ErrorCodes.aiUsageLimitExceeded,
  ErrorCodes.quotaExceeded,
  ErrorCodes.entitlementDenied,
  ErrorCodes.insufficientCredits,
  ErrorCodes.aiProviderNotConfigured,
  ErrorCodes.aiProviderError,
  ErrorCodes.aiProviderUnavailable,
  ErrorCodes.aiContextTooLarge,
  ErrorCodes.aiInputTooLong,
  ErrorCodes.aiInputBlocked,
  ErrorCodes.aiOutputBlocked,
  ErrorCodes.aiTimeout,
  ErrorCodes.aiRequestCancelled,
  ErrorCodes.aiStreamError,
  ErrorCodes.apiOffline,
  ErrorCodes.rateLimited,
  ErrorCodes.retrievalQueryInvalid,
  ErrorCodes.retrievalFailed,
  ErrorCodes.recommendationUnavailable,
  ErrorCodes.retrievalTimeout,
  ErrorCodes.storyNotFound,
  ErrorCodes.savedSearchLimitExceeded,
  ErrorCodes.savedSearchNotFound,
  'A_CODE_FROM_THE_FUTURE',
];

/// Words that would give the game away. Matched on word boundaries so "explain" and
/// "certain" survive; `AI` is checked case-sensitively, because "aiDisabled" is a code
/// and "Said" is a word.
final RegExp _branding = RegExp(
  r'\b(?:artificial intelligence|machine learning|LLM|GPT|OpenAI|Anthropic)\b',
  caseSensitive: false,
);
final RegExp _bareAi = RegExp(r'\bAI\b');

void main() {
  group('no user-facing sentence names the technology', () {
    test('across every error code, and both the named-feature variants', () {
      final List<String> sentences = <String>[
        for (final String code in _codes) ...<String>[
          AiErrorCopy.forCode(code).title,
          AiErrorCopy.forCode(code).message,
          // The two narrowed readings — a denial and a spent allowance both change
          // wording when the caller names its feature (D3, and D5's M3).
          AiErrorCopy.forCode(
            code,
            feature: AiFeatureIds.writingAssistant,
          ).title,
          AiErrorCopy.forCode(
            code,
            feature: AiFeatureIds.writingAssistant,
          ).message,
          AiErrorCopy.forCode(code, feature: AiFeatureIds.craftCoach).title,
          AiErrorCopy.forCode(code, feature: AiFeatureIds.craftCoach).message,
        ],
        AiErrorCopy.aiWritingLocked.title,
        AiErrorCopy.aiWritingLocked.message,
      ];

      for (final String sentence in sentences) {
        expect(_bareAi.hasMatch(sentence), isFalse, reason: sentence);
        expect(_branding.hasMatch(sentence), isFalse, reason: sentence);
      }
    });

    /// The one deliberate exception, and the reason the rest is allowed to be silent.
    ///
    /// D5 removed the branding, not the fact. Stating plainly — once, in the foot of
    /// each tool — that a language model produced the output and the writer's text is
    /// not training data is what earns the right to leave it out of everything else. A
    /// sweep that also erased this line would have turned de-branding into concealment,
    /// which is the *other* thing this audience rejects.
    test('the disclosure is the exception, and it is explicit', () {
      expect(ModelDisclosureNote.text, contains('language model'));
      expect(ModelDisclosureNote.text, contains('isn’t used to train it'));
    });
  });

  group('the sentences that had to be rewritten, not renamed', () {
    /// It said "Analyse this story first" while **no client could analyse anything**
    /// (48 §3.22d) — an instruction with no control behind it anywhere in the app.
    /// "Map this story" is that control, so the sentence finally names a real action.
    test('STORY_NOT_FOUND points at a control that now exists', () {
      final AiErrorCopy copy = AiErrorCopy.forCode(ErrorCodes.storyNotFound);
      expect(copy.title, 'Nothing mapped yet');
      expect(copy.message, contains('Map this story'));
      expect(copy.message.toLowerCase(), isNot(contains('ask')));
    });

    /// Naming the vendor tells a writer nothing they can act on, and the remedy is the
    /// same either way: wait.
    test('a provider failure names no vendor', () {
      for (final String code in <String>[
        ErrorCodes.aiProviderError,
        ErrorCodes.aiProviderUnavailable,
        ErrorCodes.aiProviderNotConfigured,
      ]) {
        final AiErrorCopy copy = AiErrorCopy.forCode(code);
        expect(copy.message.toLowerCase(), isNot(contains('service')));
        expect(copy.message.toLowerCase(), isNot(contains('provider')));
      }
    });

    /// `INSUFFICIENT_CREDITS` cannot be raised any more — B4 deleted the balance that
    /// could be insufficient — but it stays MAPPED. An unmapped code falls through to
    /// the generic retryable failure, which would tell a blocked writer to try again
    /// forever; the cost of keeping one arm alive is a line, and the cost of removing
    /// it early is an infinite retry loop.
    test('a now-unreachable code is still mapped, and is not retryable', () {
      final AiErrorCopy copy = AiErrorCopy.forCode(
        ErrorCodes.insufficientCredits,
      );
      expect(copy.canRetry, isFalse);
      expect(copy.canUpgrade, isTrue);
      expect(copy.title, isNot('Something went wrong'));
    });

    test('an unknown code still falls through to the retryable generic', () {
      expect(AiErrorCopy.forCode('A_CODE_FROM_THE_FUTURE').canRetry, isTrue);
    });
  });
}
