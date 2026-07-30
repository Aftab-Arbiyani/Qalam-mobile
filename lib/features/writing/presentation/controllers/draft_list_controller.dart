/// Drafts-list controller (docs/40 §8.3; M4). Presents the writer's drafts as a
/// UNION of the local offline-first store and the server's `GET /me/drafts` page
/// (cache-then-network, offline fallback to the cached server list). Also mints new
/// drafts and queues deletes. Newest-edited first; truly-empty local drafts are
/// hidden until they have a title or content.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/utils/result.dart';
import '../../../../shared/api/api_envelope.dart';
import '../../data/datasources/draft_local_data_source.dart';
import '../../domain/editor/editor_block.dart';
import '../../domain/editor/editor_document.dart';
import '../../domain/editor/marked_text.dart';
import '../../domain/editor/tiptap_codec.dart';
import '../../domain/entities/draft.dart';
import '../../domain/entities/draft_summary.dart';
import '../../domain/entities/draft_sync.dart';
import '../providers/writing_providers.dart';

part 'draft_list_controller.g.dart';

@riverpod
class DraftListController extends _$DraftListController {
  @override
  Future<List<DraftSummary>> build() async {
    // Refresh whenever the sync engine mutates a draft.
    ref.watch(draftsRevisionProvider);
    final DraftLocalDataSource store = ref.read(draftLocalDataSourceProvider);

    final List<Draft> local = store.all();
    List<DraftSummary> serverList = store.serverSummaries();
    final Result<CursorPage<DraftSummary>> fetched = await ref
        .read(pieceEditorRepositoryProvider)
        .listDrafts();
    if (fetched case Ok<CursorPage<DraftSummary>>(
      :final CursorPage<DraftSummary> value,
    )) {
      serverList = value.items;
      await store.writeServerSummaries(serverList);
    }
    return _merge(local, serverList);
  }

  /// Mint a fresh local draft and return its id for navigation to the editor.
  Future<String> newDraft() async {
    final DateTime now = DateTime.now().toUtc();
    final String localId = 'loc-${now.microsecondsSinceEpoch}';
    final Draft draft = Draft(
      localId: localId,
      createdAt: now,
      localUpdatedAt: now,
      syncState: DraftSyncState.pending,
    );
    await ref.read(draftLocalDataSourceProvider).write(draft);
    ref.invalidateSelf();
    return localId;
  }

  /// Mint a fresh local draft seeded with [text] (paragraphs split on blank lines) —
  /// backs the assistant's "Save as draft". Returns its id for navigation.
  Future<String> newDraftFromText(String text) async {
    final DateTime now = DateTime.now().toUtc();
    final String localId = 'loc-${now.microsecondsSinceEpoch}';
    final List<String> paragraphs = text
        .trim()
        .split(RegExp(r'\n\s*\n'))
        .map((String p) => p.trim())
        .where((String p) => p.isNotEmpty)
        .toList(growable: false);
    final List<EditorBlock> blocks = <EditorBlock>[
      for (int i = 0; i < paragraphs.length; i++)
        EditorBlock(
          id: 'b$i',
          type: EditorBlockType.paragraph,
          text: MarkedText.plain(paragraphs[i]),
        ),
    ];
    final EditorDocument doc =
        blocks.isEmpty ? EditorDocument.blank() : EditorDocument.of(blocks);
    final Draft draft = Draft(
      localId: localId,
      createdAt: now,
      localUpdatedAt: now,
      content: encodeDocument(doc),
      wordCount: doc.wordCount,
      syncState: DraftSyncState.pending,
    );
    await ref.read(draftLocalDataSourceProvider).write(draft);
    ref.invalidateSelf();
    return localId;
  }

  /// Queue a delete for a row (local removal if never synced; else soft-delete).
  Future<void> deleteSummary(DraftSummary summary) async {
    final DraftLocalDataSource store = ref.read(draftLocalDataSourceProvider);
    final DateTime now = DateTime.now().toUtc();
    final Draft base =
        (summary.localId != null ? store.read(summary.localId!) : null) ??
        (summary.remoteId != null
            ? store.readByRemoteId(summary.remoteId!)
            : null) ??
        Draft(
          localId: 'srv-${summary.remoteId}',
          remoteId: summary.remoteId,
          status: summary.status,
          createdAt: now,
          localUpdatedAt: now,
        );
    if (!base.isRemote) {
      await store.remove(base.localId);
      ref.invalidateSelf();
      return;
    }
    await store.write(
      base.copyWith(
        intent: DraftIntent.delete,
        syncState: DraftSyncState.pending,
        localUpdatedAt: now,
      ),
    );
    await ref.read(draftSyncEngineProvider).syncDraftById(base.localId);
    ref.invalidateSelf();
  }

  /// Re-attempt syncing everything (pull-to-refresh / retry button).
  Future<void> retrySync() async {
    await ref.read(draftSyncEngineProvider).syncAll();
    ref.invalidateSelf();
  }

  List<DraftSummary> _merge(List<Draft> local, List<DraftSummary> server) {
    final List<DraftSummary> out = <DraftSummary>[];
    final Set<String> localRemoteIds = <String>{};

    for (final Draft d in local) {
      if (_isBlank(d)) continue; // hide empty, never-touched drafts
      out.add(DraftSummary.fromDraft(d));
      if (d.remoteId != null) localRemoteIds.add(d.remoteId!);
    }
    for (final DraftSummary s in server) {
      if (s.remoteId != null && localRemoteIds.contains(s.remoteId)) continue;
      out.add(s);
    }
    out.sort((DraftSummary a, DraftSummary b) {
      final DateTime ax = a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final DateTime bx = b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bx.compareTo(ax);
    });
    return out;
  }

  bool _isBlank(Draft d) =>
      !d.isRemote &&
      d.title.trim().isEmpty &&
      d.wordCount <= 0 &&
      d.intent == DraftIntent.save;
}

/// A compact rollup of the sync queue for the global offline/sync badge.
typedef SyncSummary = ({int pending, int syncing, int failed, int conflict});

@riverpod
SyncSummary draftSyncSummary(Ref ref) {
  ref.watch(draftsRevisionProvider);
  final List<Draft> all = ref.read(draftLocalDataSourceProvider).all();
  int pending = 0;
  int syncing = 0;
  int failed = 0;
  int conflict = 0;
  for (final Draft d in all) {
    switch (d.syncState) {
      case DraftSyncState.pending:
        pending++;
      case DraftSyncState.syncing:
        syncing++;
      case DraftSyncState.failed:
        failed++;
      case DraftSyncState.conflict:
        conflict++;
      case DraftSyncState.synced:
        break;
    }
  }
  return (
    pending: pending,
    syncing: syncing,
    failed: failed,
    conflict: conflict,
  );
}
