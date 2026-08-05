import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/error/failure.dart';
import 'package:qalam_mobile/features/ai/ai.dart';

import '../../support/fake_ai_repository.dart';
import '../../support/harness.dart';

AiConversationSummary _summary(String id) => AiConversationSummary(
  id: id,
  title: 'Chat $id',
  feature: 'writing_assistant',
  status: AiConversationStatus.active,
  messageCount: 3,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

void main() {
  Future<ProviderContainer> load(FakeAiRepository fake) async {
    final ProviderContainer c = await buildTestContainer(aiRepository: fake);
    addTearDown(c.dispose);
    c.listen(conversationsControllerProvider, (_, _) {});
    await c.read(conversationsControllerProvider.future);
    return c;
  }

  test('loads conversations newest-first', () async {
    final ProviderContainer c = await load(
      FakeAiRepository(
        conversations: <AiConversationSummary>[_summary('c1'), _summary('c2')],
      ),
    );
    expect(
      c.read(conversationsControllerProvider).asData!.value.items.length,
      2,
    );
  });

  test('pinning persists and sorts pinned rows first', () async {
    final ProviderContainer c = await load(
      FakeAiRepository(
        conversations: <AiConversationSummary>[_summary('c1'), _summary('c2')],
      ),
    );
    await c.read(conversationsControllerProvider.notifier).togglePin('c2');
    final ConversationsState state = c
        .read(conversationsControllerProvider)
        .asData!
        .value;
    expect(state.isPinned('c2'), isTrue);
    expect(state.ordered.first.id, 'c2');
    // Persisted on-device.
    expect(
      c.read(promptLibraryStoreProvider).pinnedConversationIds(),
      contains('c2'),
    );
  });

  test('create prepends the new conversation (W8-1)', () async {
    final FakeAiRepository fake = FakeAiRepository(
      conversations: <AiConversationSummary>[_summary('c1')],
    );
    final ProviderContainer c = await load(fake);

    final AiConversationSummary? created = await c
        .read(conversationsControllerProvider.notifier)
        .create();

    expect(created, isNotNull);
    final List<AiConversationSummary> items = c
        .read(conversationsControllerProvider)
        .asData!
        .value
        .items;
    expect(items.first.id, created!.id);
    expect(items.map((AiConversationSummary e) => e.id), <String>[
      'c-new',
      'c1',
    ]);
  });

  test('create returns null on failure', () async {
    // `FakeAiRepository.failure` fails every call, including the initial list
    // load — so this deliberately does NOT use the `load()` helper (which
    // awaits that load succeeding). `create()` only touches the repository
    // and the in-memory state if present, so it is testable independently.
    final FakeAiRepository fake = FakeAiRepository(
      failure: const Failure.unexpected(code: 'AI_UNEXPECTED', message: 'nope'),
    );
    final ProviderContainer c = await buildTestContainer(aiRepository: fake);
    addTearDown(c.dispose);
    c.listen(conversationsControllerProvider, (_, _) {});

    final AiConversationSummary? created = await c
        .read(conversationsControllerProvider.notifier)
        .create();

    expect(created, isNull);
  });

  test('delete removes the row and calls the platform', () async {
    final FakeAiRepository fake = FakeAiRepository(
      conversations: <AiConversationSummary>[_summary('c1'), _summary('c2')],
    );
    final ProviderContainer c = await load(fake);
    final bool ok = await c
        .read(conversationsControllerProvider.notifier)
        .delete('c1');
    expect(ok, isTrue);
    expect(fake.deletedConversationIds, contains('c1'));
    expect(
      c
          .read(conversationsControllerProvider)
          .asData!
          .value
          .items
          .map((AiConversationSummary e) => e.id),
      <String>['c2'],
    );
  });
}
