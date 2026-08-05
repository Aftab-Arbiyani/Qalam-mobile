import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/ai/ai.dart';

import '../../support/fake_ai_repository.dart';

void main() {
  ProviderContainer containerWith(List<AiStreamEvent> events) {
    final ProviderContainer c = ProviderContainer(
      overrides: [
        aiRepositoryProvider.overrideWithValue(
          FakeAiRepository(streamEvents: events),
        ),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  const AiWritingContext selectionContext = AiWritingContext(
    selectionText: 'The old house stood alone.',
    chapterText: 'The old house stood alone.',
    title: 'Chapter 1',
    language: 'English',
    wordCount: 5,
  );

  test('a completed stream becomes an immutable ready suggestion', () async {
    final ProviderContainer c = containerWith(const <AiStreamEvent>[
      AiStreamEvent(
        type: AiStreamEventType.start,
        provider: 'anthropic',
        model: 'claude',
      ),
      AiStreamEvent(type: AiStreamEventType.delta, text: 'The ancient house '),
      AiStreamEvent(
        type: AiStreamEventType.delta,
        text: 'stood alone, weathered.',
      ),
      AiStreamEvent(
        type: AiStreamEventType.done,
        usage: AiTokenUsage(inputTokens: 10, outputTokens: 6, totalTokens: 16),
      ),
    ]);

    await c
        .read(assistantSessionControllerProvider.notifier)
        .runAction(
          WritingAction.of(AssistantActionKind.rewrite),
          selectionContext,
        );

    final AssistantSessionState state = c.read(
      assistantSessionControllerProvider,
    );
    expect(state.phase, AssistantPhase.ready);
    final AiSuggestion s = state.suggestion!;
    expect(s.content, 'The ancient house stood alone, weathered.');
    expect(s.sourceFeature, AiFeatureIds.writingAssistant);
    expect(s.sourceLabel, 'Rewrite');
    expect(s.promptKey, 'writing_assistant.rewrite');
    expect(s.placement, AiSuggestionPlacement.replaceSelection);
    expect(s.originalText, 'The old house stood alone.');
    expect(s.usage?.totalTokens, 16);
    expect(s.provider, 'anthropic');
  });

  test(
    'sends the right feature + prompt key + context to the platform',
    () async {
      final FakeAiRepository fake = FakeAiRepository(
        streamEvents: const <AiStreamEvent>[
          AiStreamEvent(type: AiStreamEventType.delta, text: 'x'),
          AiStreamEvent(type: AiStreamEventType.done),
        ],
      );
      final ProviderContainer c = ProviderContainer(
        overrides: [aiRepositoryProvider.overrideWithValue(fake)],
      );
      addTearDown(c.dispose);

      await c
          .read(assistantSessionControllerProvider.notifier)
          .runAction(
            WritingAction.improve(ImproveAspect.clarity),
            selectionContext,
          );

      final AiCompletionRequest req = fake.lastStreamRequest!;
      expect(req.feature, 'writing_assistant');
      expect(req.promptKey, 'writing_assistant.improve');
      expect(req.promptVariables, <String, dynamic>{'aspect': 'clarity'});
      // Operand goes as the user message; metadata context is attached (reuses AF1
      // context builders) — the client never embeds a prompt body.
      expect(req.messages!.single.content, 'The old house stood alone.');
      expect(
        req.context!.any(
          (AiContextRequest ctx) => ctx.type == 'writing_metadata',
        ),
        isTrue,
      );
    },
  );

  test(
    'sends conversationId only when the writer opted into keeping history (W8-1)',
    () async {
      final FakeAiRepository fake = FakeAiRepository(
        streamEvents: const <AiStreamEvent>[
          AiStreamEvent(type: AiStreamEventType.delta, text: 'x'),
          AiStreamEvent(type: AiStreamEventType.done),
        ],
      );
      final ProviderContainer c = ProviderContainer(
        overrides: [aiRepositoryProvider.overrideWithValue(fake)],
      );
      addTearDown(c.dispose);

      // Not kept: `ai-completion.service.ts:338` drops a turn with no
      // conversationId, so the client must not invent one.
      await c
          .read(assistantSessionControllerProvider.notifier)
          .runAction(
            WritingAction.of(AssistantActionKind.rewrite),
            selectionContext,
          );
      expect(fake.lastStreamRequest!.conversationId, isNull);

      // Kept: the bound id rides along on the next turn.
      await c
          .read(assistantSessionControllerProvider.notifier)
          .runAction(
            WritingAction.of(AssistantActionKind.rewrite),
            selectionContext,
            conversationId: 'conv-1',
          );
      expect(fake.lastStreamRequest!.conversationId, 'conv-1');
    },
  );

  test('regenerate resends the bound conversationId (W8-1)', () async {
    final FakeAiRepository fake = FakeAiRepository(
      streamEvents: const <AiStreamEvent>[
        AiStreamEvent(type: AiStreamEventType.delta, text: 'x'),
        AiStreamEvent(type: AiStreamEventType.done),
      ],
    );
    final ProviderContainer c = ProviderContainer(
      overrides: [aiRepositoryProvider.overrideWithValue(fake)],
    );
    addTearDown(c.dispose);

    await c
        .read(assistantSessionControllerProvider.notifier)
        .runAction(
          WritingAction.of(AssistantActionKind.rewrite),
          selectionContext,
          conversationId: 'conv-1',
        );
    await c.read(assistantSessionControllerProvider.notifier).regenerate();

    expect(fake.lastStreamRequest!.conversationId, 'conv-1');
  });

  test('a stream error surfaces the error code, no suggestion', () async {
    final ProviderContainer c = containerWith(const <AiStreamEvent>[
      AiStreamEvent(
        type: AiStreamEventType.error,
        code: 'AI_USAGE_LIMIT_EXCEEDED',
      ),
    ]);

    await c
        .read(assistantSessionControllerProvider.notifier)
        .runAction(
          WritingAction.of(AssistantActionKind.expand),
          selectionContext,
        );

    final AssistantSessionState state = c.read(
      assistantSessionControllerProvider,
    );
    expect(state.phase, AssistantPhase.error);
    expect(state.errorCode, 'AI_USAGE_LIMIT_EXCEEDED');
    expect(state.suggestion, isNull);
  });
}
