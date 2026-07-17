import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/utils/result.dart';
import 'package:qalam_mobile/features/ai/ai.dart';

/// A fake [AiRepository] that replays a fixed event script.
class _FakeAiRepository implements AiRepository {
  _FakeAiRepository(this._events);

  final List<AiStreamEvent> _events;

  @override
  Stream<AiStreamEvent> streamCompletion(AiCompletionRequest request) async* {
    for (final AiStreamEvent event in _events) {
      yield event;
    }
  }

  @override
  Future<Result<AiFeatures>> features() async =>
      const Ok<AiFeatures>(AiFeatures(aiEnabled: true, features: <AiFeatureFlag>[]));

  @override
  Future<Result<AiCompletionResult>> complete(AiCompletionRequest request) async =>
      const Ok<AiCompletionResult>(
        AiCompletionResult(
          content: 'ok',
          provider: 'openai',
          model: 'gpt-4o',
          finishReason: 'stop',
          estimatedCostUsd: 0,
        ),
      );
}

void main() {
  test('AiStreamController accumulates deltas and finalizes on done', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        aiRepositoryProvider.overrideWithValue(
          _FakeAiRepository(const <AiStreamEvent>[
            AiStreamEvent(type: AiStreamEventType.start, provider: 'openai', model: 'gpt-4o'),
            AiStreamEvent(type: AiStreamEventType.delta, text: 'Hel'),
            AiStreamEvent(type: AiStreamEventType.delta, text: 'lo'),
            AiStreamEvent(
              type: AiStreamEventType.done,
              usage: AiTokenUsage(inputTokens: 1, outputTokens: 2, totalTokens: 3),
            ),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(aiStreamControllerProvider.notifier)
        .start(
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
}
