import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/error/failure.dart';
import 'package:qalam_mobile/features/ai/ai.dart';

import '../../support/fake_ai_repository.dart';

void main() {
  const AiWritingContext ctx = AiWritingContext(
    chapterText: 'A long chapter of prose to analyse.',
    title: 'Ch 1',
    language: 'English',
    wordCount: 7,
  );

  ProviderContainer withCompletion(AiCompletionResult result) {
    final ProviderContainer c = ProviderContainer(
      overrides: [
        aiRepositoryProvider.overrideWithValue(FakeAiRepository(completion: result)),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('parses a structured coach report', () async {
    final ProviderContainer c = withCompletion(
      const AiCompletionResult(
        content: '{"score": 74, "summary": "Solid draft.", "strengths": ["Voice"], '
            '"weaknesses": [], "suggestions": ["Trim adverbs"], "recommendations": [], '
            '"sections": []}',
        provider: 'openai',
        model: 'gpt-4o',
        finishReason: 'stop',
        estimatedCostUsd: 0.001,
        usage: AiTokenUsage(inputTokens: 20, outputTokens: 40, totalTokens: 60),
      ),
    );

    await c.read(craftCoachControllerProvider.notifier).run(CraftCoachTool.review, ctx);

    final CraftCoachState state = c.read(craftCoachControllerProvider);
    expect(state.phase, CoachPhase.ready);
    expect(state.report!.score, 74);
    expect(state.report!.strengths, <String>['Voice']);
    expect(state.usage?.totalTokens, 60);
  });

  test('falls back to raw text when the model returns no JSON', () async {
    final ProviderContainer c = withCompletion(
      const AiCompletionResult(
        content: 'Here is some plain advice with no JSON at all.',
        provider: 'openai',
        model: 'gpt-4o',
        finishReason: 'stop',
        estimatedCostUsd: 0,
      ),
    );

    await c.read(craftCoachControllerProvider.notifier).run(CraftCoachTool.pacing, ctx);

    final CraftCoachState state = c.read(craftCoachControllerProvider);
    expect(state.phase, CoachPhase.rawOnly);
    expect(state.report, isNull);
    expect(state.rawText, contains('plain advice'));
  });

  test('surfaces a failure as an error phase', () async {
    final ProviderContainer c = ProviderContainer(
      overrides: [
        aiRepositoryProvider.overrideWithValue(
          FakeAiRepository(failure: const Failure.rateLimit(code: 'RATE_LIMITED')),
        ),
      ],
    );
    addTearDown(c.dispose);

    await c.read(craftCoachControllerProvider.notifier).run(CraftCoachTool.readability, ctx);

    final CraftCoachState state = c.read(craftCoachControllerProvider);
    expect(state.phase, CoachPhase.error);
    expect(state.errorCode, 'RATE_LIMITED');
  });
}
