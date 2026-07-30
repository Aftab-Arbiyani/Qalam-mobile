import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/di/providers.dart';
import 'package:qalam_mobile/features/writing/domain/editor/editor_block.dart';
import 'package:qalam_mobile/features/writing/domain/editor/editor_document.dart';
import 'package:qalam_mobile/features/writing/domain/editor/marked_text.dart';
import 'package:qalam_mobile/features/writing/domain/entities/draft.dart';
import 'package:qalam_mobile/features/writing/domain/entities/draft_sync.dart';
import 'package:qalam_mobile/features/writing/presentation/controllers/current_draft_controller.dart';
import 'package:qalam_mobile/features/writing/presentation/controllers/editor_state.dart';
import 'package:qalam_mobile/features/writing/presentation/providers/writing_providers.dart';

import '../../support/fake_writing.dart';
import '../../support/harness.dart';

Draft _seed(String id) => Draft(
      localId: id,
      title: 'Title',
      languageCode: 'en',
      wordCount: 4,
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
  group('EditorDocument generic bulk inserts (paste/import/AI apply)', () {
    test('insertParagraphsAfter adds paragraph blocks after the anchor', () {
      final EditorDocument doc = EditorDocument.of(<EditorBlock>[
        EditorBlock(id: 'b0', type: EditorBlockType.paragraph, text: MarkedText.plain('first')),
      ]);
      final EditorDocument next = doc.insertParagraphsAfter('b0', <String>['second', 'third']);
      expect(next.blocks.length, 3);
      expect(next.blocks[1].text.text, 'second');
      expect(next.blocks[2].text.text, 'third');
      // Fresh, unique ids past the existing counter.
      expect(next.blocks.map((EditorBlock b) => b.id).toSet().length, 3);
    });

    test('appendParagraphs appends at the end and skips blanks', () {
      final EditorDocument doc = EditorDocument.of(<EditorBlock>[
        EditorBlock(id: 'b0', type: EditorBlockType.paragraph, text: MarkedText.plain('only')),
      ]);
      final EditorDocument next = doc.appendParagraphs(<String>['tail', '   ']);
      expect(next.blocks.length, 2);
      expect(next.blocks.last.text.text, 'tail');
    });
  });

  group('CurrentDraftController AI-apply commands flow through the editor funnel', () {
    late FakePieceEditorRepository repo;

    Future<ProviderContainer> container() async {
      repo = FakePieceEditorRepository();
      final ProviderContainer c = await buildTestContainer(
        pieceEditorRepository: repo,
        taxonomyRepository: FakeTaxonomyRepository(),
      );
      addTearDown(c.dispose);
      await c.read(preferencesStoreProvider).setEditorAutosave(false);
      await c.read(draftLocalDataSourceProvider).write(_seed('loc-1'));
      c.listen(currentDraftControllerProvider('loc-1'), (_, _) {});
      await c.read(currentDraftControllerProvider('loc-1').future);
      return c;
    }

    test('replaceRange edits the block AND marks the draft dirty (same as typing)', () async {
      final ProviderContainer c = await container();
      final CurrentDraftController notifier =
          c.read(currentDraftControllerProvider('loc-1').notifier);
      final EditorState before = c.read(currentDraftControllerProvider('loc-1')).asData!.value;
      final String blockId = before.document.blocks.single.id;
      final int baseVersion = before.draft.version;

      notifier.replaceRange(blockId, 0, 4, 'ONCE');

      final EditorState st = c.read(currentDraftControllerProvider('loc-1')).asData!.value;
      expect(st.document.blockById(blockId)!.text.text, 'ONCE upon a time');
      // Proof it used the ordinary edit path: dirty + version bump (→ autosave/sync).
      expect(st.draft.syncState, DraftSyncState.pending);
      expect(st.draft.version, baseVersion + 1);
    });

    test('insertParagraphsAfter inserts accepted suggestion content below', () async {
      final ProviderContainer c = await container();
      final CurrentDraftController notifier =
          c.read(currentDraftControllerProvider('loc-1').notifier);
      final String blockId =
          c.read(currentDraftControllerProvider('loc-1')).asData!.value.document.blocks.single.id;

      notifier.insertParagraphsAfter(blockId, <String>['a new AI paragraph']);

      final EditorState st = c.read(currentDraftControllerProvider('loc-1')).asData!.value;
      expect(st.document.blocks.length, 2);
      expect(st.document.blocks[1].text.text, 'a new AI paragraph');
    });

    test('replaceDocument restores a snapshot — the "Undo AI application" path', () async {
      final ProviderContainer c = await container();
      final CurrentDraftController notifier =
          c.read(currentDraftControllerProvider('loc-1').notifier);
      final EditorDocument snapshot =
          c.read(currentDraftControllerProvider('loc-1')).asData!.value.document;

      notifier.appendParagraphs(<String>['temporary AI text']);
      expect(
        c.read(currentDraftControllerProvider('loc-1')).asData!.value.document.blocks.length,
        2,
      );

      notifier.replaceDocument(snapshot);
      final EditorState st = c.read(currentDraftControllerProvider('loc-1')).asData!.value;
      expect(st.document.blocks.length, 1);
      expect(st.document.blocks.single.text.text, 'once upon a time');
    });
  });
}
