import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/error/failure.dart';
import 'package:qalam_mobile/features/ai/ai.dart';

import '../../support/fake_ai_repository.dart';
import '../../support/harness.dart';

AiConversationSummary _summary(
  String id, {
  AiConversationStatus status = AiConversationStatus.active,
}) => AiConversationSummary(
  id: id,
  title: 'Chat $id',
  feature: 'writing_assistant',
  status: status,
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

  /// The archive shelf (`platfrom/docs/48` §3.21).
  ///
  /// Archiving already worked before this: the row left the list and the server persisted the
  /// status. What did not exist was any way back — no shelf to see it on, no restore — so between
  /// the backend gaining its status filter and this change, Archive was a delete with a gentler
  /// label. These assert the pair, not the action.
  group('archive shelf', () {
    test('reads the active shelf by default, as a request parameter', () async {
      final FakeAiRepository fake = FakeAiRepository(
        conversations: <AiConversationSummary>[
          _summary('c1'),
          _summary('c2', status: AiConversationStatus.archived),
        ],
      );
      final ProviderContainer c = await load(fake);

      final ConversationsState state = c
          .read(conversationsControllerProvider)
          .asData!
          .value;
      expect(state.shelf, AiConversationStatus.active);
      expect(state.isArchivedShelf, isFalse);
      // One row, because the archived one is not in the active page to begin with — it is filtered
      // server-side, not hidden here.
      expect(state.items.map((AiConversationSummary c) => c.id), <String>[
        'c1',
      ]);
      expect(fake.lastListedStatus, AiConversationStatus.active);
    });

    test('switching shelves re-reads with the archived status', () async {
      final FakeAiRepository fake = FakeAiRepository(
        conversations: <AiConversationSummary>[
          _summary('c1'),
          _summary('c2', status: AiConversationStatus.archived),
        ],
      );
      final ProviderContainer c = await load(fake);

      await c
          .read(conversationsControllerProvider.notifier)
          .setShelf(AiConversationStatus.archived);

      final ConversationsState state = c
          .read(conversationsControllerProvider)
          .asData!
          .value;
      expect(fake.lastListedStatus, AiConversationStatus.archived);
      expect(state.isArchivedShelf, isTrue);
      expect(state.items.map((AiConversationSummary c) => c.id), <String>[
        'c2',
      ]);
    });

    test('switching to the shelf already shown does not refetch', () async {
      final FakeAiRepository fake = FakeAiRepository(
        conversations: <AiConversationSummary>[_summary('c1')],
      );
      final ProviderContainer c = await load(fake);
      fake.lastListedStatus = null;

      await c
          .read(conversationsControllerProvider.notifier)
          .setShelf(AiConversationStatus.active);

      expect(fake.lastListedStatus, isNull);
    });

    test('archiving drops the row from the active shelf', () async {
      final ProviderContainer c = await load(
        FakeAiRepository(
          conversations: <AiConversationSummary>[
            _summary('c1'),
            _summary('c2'),
          ],
        ),
      );

      final bool ok = await c
          .read(conversationsControllerProvider.notifier)
          .archive('c1');

      expect(ok, isTrue);
      expect(
        c
            .read(conversationsControllerProvider)
            .asData!
            .value
            .items
            .map((AiConversationSummary c) => c.id),
        <String>['c2'],
      );
    });

    test(
      'archiving KEEPS the on-device pin, so a restore comes back pinned',
      () async {
        final ProviderContainer c = await load(
          FakeAiRepository(
            conversations: <AiConversationSummary>[
              _summary('c1'),
              _summary('c2'),
            ],
          ),
        );
        final ConversationsController notifier = c.read(
          conversationsControllerProvider.notifier,
        );
        await notifier.togglePin('c1');

        await notifier.archive('c1');

        // `_remove` strips pins — right for delete, wrong for a row that still exists. A pin lost
        // here is silently lost forever: the pin set is on-device and nothing re-adds it on restore.
        expect(
          c.read(conversationsControllerProvider).asData!.value.isPinned('c1'),
          isTrue,
        );
      },
    );

    test('restoring drops the row from the archived shelf', () async {
      final FakeAiRepository fake = FakeAiRepository(
        conversations: <AiConversationSummary>[
          _summary('c1', status: AiConversationStatus.archived),
          _summary('c2', status: AiConversationStatus.archived),
        ],
      );
      final ProviderContainer c = await load(fake);
      final ConversationsController notifier = c.read(
        conversationsControllerProvider.notifier,
      );
      await notifier.setShelf(AiConversationStatus.archived);

      final bool ok = await notifier.restore('c1');

      expect(ok, isTrue);
      expect(
        c
            .read(conversationsControllerProvider)
            .asData!
            .value
            .items
            .map((AiConversationSummary c) => c.id),
        <String>['c2'],
      );
    });

    test('a failed status change leaves the row where it was', () async {
      final ProviderContainer c = await load(
        FakeAiRepository(
          conversations: <AiConversationSummary>[_summary('c1')],
          statusChangeFailure: const Failure.unexpected(
            code: 'BOOM',
            message: 'nope',
          ),
        ),
      );

      final bool ok = await c
          .read(conversationsControllerProvider.notifier)
          .archive('c1');

      expect(ok, isFalse);
      expect(
        c.read(conversationsControllerProvider).asData!.value.items.length,
        1,
      );
    });
  });
}
