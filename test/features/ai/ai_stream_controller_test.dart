import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/ai/ai.dart';

import '../../support/fake_ai_repository.dart';

void main() {
  test('AiStreamController accumulates deltas and finalizes on done', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        aiRepositoryProvider.overrideWithValue(
          FakeAiRepository(
            streamEvents: const <AiStreamEvent>[
              AiStreamEvent(type: AiStreamEventType.start, provider: 'openai', model: 'gpt-4o'),
              AiStreamEvent(type: AiStreamEventType.delta, text: 'Hel'),
              AiStreamEvent(type: AiStreamEventType.delta, text: 'lo'),
              AiStreamEvent(
                type: AiStreamEventType.done,
                usage: AiTokenUsage(inputTokens: 1, outputTokens: 2, totalTokens: 3),
              ),
            ],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(aiStreamControllerProvider.notifier).start(
          const AiCompletionRequest(
            feature: 'playground',
            messages: <AiMessage>[AiMessage(role: 'user', content: 'hi')],
          ),
        );

    final AiStreamState state = container.read(aiStreamControllerProvider);
    expect(state.status, AiStreamStatus.done);
    expect(state.text, 'Hello');
    expect(state.model, 'gpt-4o');
    expect(state.provider, 'openai');
    expect(state.usage?.totalTokens, 3);
  });

  test('start carries the conversation id from the start event', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        aiRepositoryProvider.overrideWithValue(
          FakeAiRepository(
            streamEvents: const <AiStreamEvent>[
              AiStreamEvent(type: AiStreamEventType.start, conversationId: 'conv-9'),
              AiStreamEvent(type: AiStreamEventType.delta, text: 'x'),
              AiStreamEvent(type: AiStreamEventType.done),
            ],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(aiStreamControllerProvider.notifier)
        .start(const AiCompletionRequest(feature: 'writing_assistant'));

    expect(container.read(aiStreamControllerProvider).conversationId, 'conv-9');
  });
}
