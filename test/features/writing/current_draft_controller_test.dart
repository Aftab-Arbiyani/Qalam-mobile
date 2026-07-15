import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/di/providers.dart';
import 'package:qalam_mobile/features/writing/domain/entities/draft.dart';
import 'package:qalam_mobile/features/writing/domain/entities/draft_sync.dart';
import 'package:qalam_mobile/features/writing/presentation/controllers/current_draft_controller.dart';
import 'package:qalam_mobile/features/writing/presentation/controllers/editor_state.dart';
import 'package:qalam_mobile/features/writing/presentation/providers/writing_providers.dart';
import 'package:qalam_mobile/shared/domain/enums.dart';

import '../../support/fake_writing.dart';
import '../../support/harness.dart';

Draft _seed(String id) => Draft(
  localId: id,
  title: 'Working title',
  languageCode: 'ur',
  genreSlug: 'ghazal',
  wordCount: 10,
  content: const <String, dynamic>{
    'type': 'doc',
    'content': <dynamic>[
      <String, dynamic>{
        'type': 'paragraph',
        'content': <dynamic>[
          <String, dynamic>{'type': 'text', 'text': 'once upon a time'},
        ],
      },
    ],
  },
  createdAt: DateTime.utc(2026, 7),
  localUpdatedAt: DateTime.utc(2026, 7, 2),
);

void main() {
  late FakePieceEditorRepository repo;

  Future<ProviderContainer> container() async {
    repo = FakePieceEditorRepository();
    final ProviderContainer c = await buildTestContainer(
      pieceEditorRepository: repo,
      editorTaxonomyRepository: FakeEditorTaxonomyRepository(),
    );
    addTearDown(c.dispose);
    // Deterministic: no debounced autosave timers bleeding across tests.
    await c.read(preferencesStoreProvider).setEditorAutosave(false);
    await c.read(draftLocalDataSourceProvider).write(_seed('loc-1'));
    // Keep the autodispose controller mounted for the test's lifetime, and load it.
    c.listen(currentDraftControllerProvider('loc-1'), (_, _) {});
    await c.read(currentDraftControllerProvider('loc-1').future);
    return c;
  }

  test('loads an existing local draft with its decoded document', () async {
    final ProviderContainer c = await container();
    final EditorState st = await c.read(
      currentDraftControllerProvider('loc-1').future,
    );
    expect(st.draft.title, 'Working title');
    expect(st.document.blocks.single.text.text, 'once upon a time');
  });

  test('editing the title marks the draft pending', () async {
    final ProviderContainer c = await container();
    await c.read(currentDraftControllerProvider('loc-1').future);
    final CurrentDraftController notifier = c.read(
      currentDraftControllerProvider('loc-1').notifier,
    );
    notifier.setTitle('New title');
    final EditorState st = c
        .read(currentDraftControllerProvider('loc-1'))
        .asData!
        .value;
    expect(st.draft.title, 'New title');
    expect(st.draft.syncState, DraftSyncState.pending);
  });

  test('addTag dedupes and caps at the shared limit', () async {
    final ProviderContainer c = await container();
    await c.read(currentDraftControllerProvider('loc-1').future);
    final CurrentDraftController notifier = c.read(
      currentDraftControllerProvider('loc-1').notifier,
    );
    expect(notifier.addTag('love'), isTrue);
    expect(notifier.addTag('love'), isFalse); // duplicate
    expect(notifier.addTag('a'), isTrue);
    expect(notifier.addTag('b'), isTrue);
    expect(notifier.addTag('c'), isTrue);
    expect(notifier.addTag('d'), isTrue);
    expect(notifier.addTag('e'), isFalse); // over the cap of 5
    final EditorState st = c
        .read(currentDraftControllerProvider('loc-1'))
        .asData!
        .value;
    expect(st.draft.tags.length, 5);
  });

  test(
    'publish queues the intent and (online) publishes on the server',
    () async {
      final ProviderContainer c = await container();
      await c.read(currentDraftControllerProvider('loc-1').future);
      final CurrentDraftController notifier = c.read(
        currentDraftControllerProvider('loc-1').notifier,
      );
      await notifier.publish();
      // The fake creates then publishes; the stored draft ends published + synced.
      final Draft stored = c.read(draftLocalDataSourceProvider).read('loc-1')!;
      expect(repo.publishCalls, 1);
      expect(stored.status, PieceStatus.published);
      expect(stored.syncState, DraftSyncState.synced);
    },
  );

  test('saveNow flushes the live document into the local store', () async {
    final ProviderContainer c = await container();
    await c.read(currentDraftControllerProvider('loc-1').future);
    final CurrentDraftController notifier = c.read(
      currentDraftControllerProvider('loc-1').notifier,
    );
    notifier.setTitle('Flushed');
    await notifier.saveNow();
    expect(
      c.read(draftLocalDataSourceProvider).read('loc-1')!.title,
      'Flushed',
    );
    // saveNow fires an unawaited background drain — settle it before teardown.
    await c.read(draftSyncEngineProvider).syncAll();
  });

  test('edits landing while a save is in flight are not clobbered', () async {
    final ProviderContainer c = await container();
    await c.read(currentDraftControllerProvider('loc-1').future);
    final CurrentDraftController notifier = c.read(
      currentDraftControllerProvider('loc-1').notifier,
    );
    notifier.setTitle('Before');
    final Future<void> saving = notifier.saveNow();
    // Lands after the persist captured its snapshot but before its write returns.
    notifier.setTitle('During');
    await saving;
    final EditorState st = c
        .read(currentDraftControllerProvider('loc-1'))
        .asData!
        .value;
    expect(st.draft.title, 'During');
    expect(st.autosaving, isFalse);
    await c.read(draftSyncEngineProvider).syncAll();
  });

  test(
    'a deleted never-synced draft cannot be resurrected by a later save',
    () async {
      final ProviderContainer c = await container();
      await c.read(currentDraftControllerProvider('loc-1').future);
      final CurrentDraftController notifier = c.read(
        currentDraftControllerProvider('loc-1').notifier,
      );
      notifier.setTitle('Edited then deleted');
      await notifier.deleteDraft();
      expect(c.read(draftLocalDataSourceProvider).read('loc-1'), isNull);
      // A late flush (debounced autosave / dispose flush / saveNow) must be a no-op.
      await notifier.saveNow();
      expect(c.read(draftLocalDataSourceProvider).read('loc-1'), isNull);
      await c.read(draftSyncEngineProvider).syncAll();
    },
  );
}
