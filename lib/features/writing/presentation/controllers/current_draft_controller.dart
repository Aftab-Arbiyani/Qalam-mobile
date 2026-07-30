/// The current-draft controller (docs/40 §8.3, §8.5; M4). Owns one draft's editing
/// session: loads/hydrates it (local-first, else from the server), holds the live
/// [EditorDocument], debounce-autosaves to the local Hive store (offline-safe crash
/// recovery), and drives the lifecycle actions (save / publish / schedule / delete /
/// discard / resolve-conflict) through the sync engine so they queue offline and
/// replay on reconnect. All editor mutations funnel here — the block widgets and
/// metadata form hold NO business logic (docs/40 §44).
library;

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/media/cover_image_picker.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/domain/entities/taxonomy.dart';
import '../../../../shared/domain/enums.dart';
import '../../../../shared/domain/limits.dart';
import '../../data/datasources/draft_local_data_source.dart';
import '../../domain/editor/editor_block.dart';
import '../../domain/editor/editor_document.dart';
import '../../domain/editor/marked_text.dart';
import '../../domain/editor/tiptap_codec.dart';
import '../../domain/entities/draft.dart';
import '../../domain/entities/draft_sync.dart';
import '../../domain/repositories/piece_editor_repository.dart';
import '../providers/writing_providers.dart';
import 'editor_preferences_controller.dart';
import 'editor_state.dart';

part 'current_draft_controller.g.dart';

/// Debounced local-autosave window (docs/40 §36). A crash loses at most this.
const Duration _autosaveDebounce = Duration(seconds: 2);

@riverpod
class CurrentDraftController extends _$CurrentDraftController {
  Timer? _debounce;
  String _localId = '';
  bool _disposed = false;

  /// True once this session's draft has been removed from the local store or a
  /// delete has been queued — suppresses every later write (debounced autosave,
  /// saveNow, dispose flush) so a late flush cannot resurrect the removed draft
  /// or overwrite the queued delete.
  bool _closed = false;

  // Captured while mounted so [dispose] can flush WITHOUT touching `ref`/`state`
  // (both are illegal during disposal — Riverpod contract, docs/40 §mobile-conv).
  DraftLocalDataSource? _store;
  EditorState? _latest;

  @override
  Future<EditorState> build(String routeId) async {
    ref.onDispose(() {
      _disposed = true;
      _debounce?.cancel();
      _flushSync();
    });

    final DraftLocalDataSource store = ref.read(draftLocalDataSourceProvider);
    _store = store;
    final Draft? existing =
        store.read(routeId) ?? store.readByRemoteId(routeId);

    final Draft draft;
    if (existing != null) {
      draft = existing;
    } else {
      // A server-only piece opened by its remote id — hydrate for editing.
      final PieceEditorRepository repo = ref.read(
        pieceEditorRepositoryProvider,
      );
      final Result<Draft> result = await repo.fetchDraft(routeId);
      final Draft hydrated = result.fold(
        (Draft d) => d,
        (Failure failure) => throw failure,
      );
      await store.write(hydrated);
      draft = hydrated;
    }

    _localId = draft.localId;

    // Reflect background-sync changes (remote id assigned, published, conflict)
    // without clobbering the live in-memory document.
    ref.listen(draftsRevisionProvider, (_, _) => _reconcile());

    final EditorState initial = EditorState(
      draft: draft,
      document: decodeDocument(draft.content),
      lastSavedAt: draft.localUpdatedAt,
    );
    _latest = initial;
    return initial;
  }

  // ── Metadata mutations ───────────────────────────────────────────────────────

  void setTitle(String value) =>
      _editDraft((Draft d) => d.copyWith(title: value));

  void setSubtitle(String value) =>
      _editDraft((Draft d) => d.copyWith(subtitle: value));

  void setFeaturedQuote(String value) =>
      _editDraft((Draft d) => d.copyWith(featuredQuote: value));

  void setLanguage(LanguageRef language) => _editDraft(
    (Draft d) => d.copyWith(
      languageCode: language.code,
      languageName: language.nativeName,
      direction: language.direction,
    ),
  );

  void setGenre(GenreRef? genre) => _editDraft(
    (Draft d) => d.copyWith(genreSlug: genre?.slug, genreName: genre?.name),
  );

  void setVisibility(Visibility value) =>
      _editDraft((Draft d) => d.copyWith(visibility: value));

  /// Add a tag (deduped, capped at the server's `TAGS_MAX_PER_PIECE`). Returns
  /// false if it was rejected (duplicate or over the cap) so the UI can react.
  bool addTag(String raw) {
    final String tag = raw.trim();
    final EditorState? cur = state.asData?.value;
    if (cur == null || tag.isEmpty) return false;
    final List<String> tags = cur.draft.tags;
    if (tags.length >= Limits.tagsMaxPerPiece) return false;
    if (tags.any((String t) => t.toLowerCase() == tag.toLowerCase())) {
      return false;
    }
    _editDraft((Draft d) => d.copyWith(tags: <String>[...d.tags, tag]));
    return true;
  }

  void removeTag(String tag) => _editDraft(
    (Draft d) =>
        d.copyWith(tags: d.tags.where((String t) => t != tag).toList()),
  );

  // ── Cover ─────────────────────────────────────────────────────────────────────

  void setCover(PickedImage image) =>
      _editDraft((Draft d) => d.copyWith(pendingCoverPath: image.path));

  void removeCover() => _editDraft(
    (Draft d) => d.copyWith(coverImageKey: null, pendingCoverPath: null),
  );

  // ── Block / document mutations ─────────────────────────────────────────────────

  void updateBlockText(String blockId, MarkedText text) =>
      _editDocument((EditorDocument doc) => doc.setBlockText(blockId, text));

  void toggleMark(String blockId, TextMark mark, int start, int end) {
    final EditorState? cur = state.asData?.value;
    if (cur == null) return;
    final EditorBlock? block = cur.document.blockById(blockId);
    if (block == null) return;
    _editDocument(
      (EditorDocument doc) =>
          doc.setBlockText(blockId, block.text.toggleMark(mark, start, end)),
    );
  }

  void setBlockType(String blockId, EditorBlockType type) =>
      _editDocument((EditorDocument doc) => doc.setBlockType(blockId, type));

  /// Split a block at [offset] (Enter). Places focus at the start of the new block.
  void splitBlock(String blockId, int offset) {
    final EditorState? cur = state.asData?.value;
    if (cur == null) return;
    final result = cur.document.splitBlock(blockId, offset);
    _commit(
      cur.copyWith(
        document: result.document,
        focus: FocusRequest(result.newBlockId, 0),
      ),
    );
  }

  /// Merge a block into its predecessor (Backspace at offset 0).
  void mergeBackward(String blockId) {
    final EditorState? cur = state.asData?.value;
    if (cur == null) return;
    final result = cur.document.mergeIntoPrevious(blockId);
    if (result == null) return;
    _commit(
      cur.copyWith(
        document: result.document,
        focus: FocusRequest(result.focusId, result.caret),
      ),
    );
  }

  /// Append a fresh paragraph after [blockId] and focus it.
  void addBlockAfter(String blockId) {
    final EditorState? cur = state.asData?.value;
    if (cur == null) return;
    final result = cur.document.insertParagraphAfter(blockId);
    _commit(
      cur.copyWith(
        document: result.document,
        focus: FocusRequest(result.newBlockId, 0),
      ),
    );
  }

  void removeBlock(String blockId) =>
      _editDocument((EditorDocument doc) => doc.removeBlock(blockId));

  // ── Generic bulk / range edits (paste · import · accepted AI suggestion) ────────
  // Ordinary editor commands, NOT AI-specific: they funnel through the SAME edit path
  // as typing (mark dirty → debounced autosave → offline sync → version bump), so an
  // accepted AI suggestion produces exactly the editor events manual editing does. The
  // editor stays the sole owner of document state (docs/34, AF2).

  /// Replace `[start, end)` in [blockId] with [text] (accepted "Replace selection").
  void replaceRange(String blockId, int start, int end, String text) {
    _editDocument((EditorDocument doc) {
      final EditorBlock? block = doc.blockById(blockId);
      if (block == null) return doc;
      final int s = start.clamp(0, block.text.length);
      final int e = end.clamp(s, block.text.length);
      return doc.setBlockText(blockId, block.text.replace(s, e - s, text));
    });
  }

  /// Insert [paragraphs] as new paragraph blocks after [afterId] ("Insert below").
  void insertParagraphsAfter(String afterId, List<String> paragraphs) =>
      _editDocument((EditorDocument doc) => doc.insertParagraphsAfter(afterId, paragraphs));

  /// Append [paragraphs] as new paragraph blocks at the end ("Append").
  void appendParagraphs(List<String> paragraphs) =>
      _editDocument((EditorDocument doc) => doc.appendParagraphs(paragraphs));

  /// Replace the whole live document (undo/redo/import). The caller keeps the prior
  /// [EditorDocument] to offer an "Undo AI application".
  void replaceDocument(EditorDocument document) =>
      _editDocument((EditorDocument _) => document);

  /// The editor consumed the pending focus request.
  void clearFocus() {
    final EditorState? cur = state.asData?.value;
    if (cur == null || cur.focus == null) return;
    state = AsyncData<EditorState>(cur.copyWith(clearFocus: true));
  }

  // ── Lifecycle actions ──────────────────────────────────────────────────────────

  /// Flush edits to the local store now, then push to the server (queues offline).
  Future<void> saveNow() async {
    _debounce?.cancel();
    await _persistLocal();
    if (_disposed) return;
    unawaited(ref.read(draftSyncEngineProvider).syncAll());
  }

  /// Queue a publish. Persists locally with intent=publish, then attempts sync;
  /// offline it stays queued and publishes on reconnect (docs/40 §42).
  Future<void> publish() =>
      _queueIntent(DraftIntent.publish, status: PieceStatus.published);

  /// Queue a scheduled publish for [at].
  Future<void> schedule(DateTime at) => _queueIntent(
    DraftIntent.schedule,
    status: PieceStatus.scheduled,
    scheduledAt: at.toUtc(),
  );

  /// Delete the draft (local removal if never synced; else queued soft-delete).
  Future<void> deleteDraft() async {
    final EditorState? cur = state.asData?.value;
    if (cur == null) return;
    _debounce?.cancel();
    final DraftLocalDataSource store = ref.read(draftLocalDataSourceProvider);
    if (!cur.draft.isRemote) {
      _closed = true;
      await store.remove(_localId);
      ref.read(draftSyncEngineProvider).revision.value++;
      return;
    }
    final Draft queued = cur.draft.copyWith(
      intent: DraftIntent.delete,
      syncState: DraftSyncState.pending,
      localUpdatedAt: DateTime.now().toUtc(),
    );
    await store.write(queued);
    _setData(cur.copyWith(draft: queued));
    _closed = true;
    unawaited(ref.read(draftSyncEngineProvider).syncDraftById(_localId));
  }

  /// Discard local changes: re-adopt the server copy if the draft exists remotely,
  /// otherwise delete the never-synced draft.
  Future<void> discardChanges() async {
    final EditorState? cur = state.asData?.value;
    if (cur == null) return;
    _debounce?.cancel();
    final DraftLocalDataSource store = ref.read(draftLocalDataSourceProvider);
    if (!cur.draft.isRemote) {
      _closed = true;
      await store.remove(_localId);
      ref.read(draftSyncEngineProvider).revision.value++;
      return;
    }
    final result = await ref
        .read(pieceEditorRepositoryProvider)
        .fetchDraft(cur.draft.remoteId!);
    await result.fold((Draft server) async {
      final Draft adopted = server.copyWith(localId: _localId);
      await store.write(adopted);
      _setData(
        EditorState(
          draft: adopted,
          document: decodeDocument(adopted.content),
          lastSavedAt: adopted.localUpdatedAt,
        ),
      );
    }, (_) async {});
  }

  /// Resolve a detected sync conflict (docs/40 §42.1).
  Future<void> resolveConflict(ConflictResolution resolution) async {
    final EditorState? cur = state.asData?.value;
    if (cur == null) return;
    switch (resolution) {
      case ConflictResolution.keepServer:
        await discardChanges();
      case ConflictResolution.keepLocal:
        // Adopt the server's current updatedAt as our base so the next push wins,
        // then re-queue the local content.
        final result = await ref
            .read(pieceEditorRepositoryProvider)
            .fetchDraft(cur.draft.remoteId!);
        final DateTime? base = result.fold(
          (Draft s) => s.remoteUpdatedAt,
          (_) => cur.draft.remoteUpdatedAt,
        );
        final Draft rebased = cur.liveDraft.copyWith(
          remoteUpdatedAt: base,
          syncState: DraftSyncState.pending,
          intent: DraftIntent.save,
          localUpdatedAt: DateTime.now().toUtc(),
        );
        await ref.read(draftLocalDataSourceProvider).write(rebased);
        _setData(cur.copyWith(draft: rebased));
        unawaited(ref.read(draftSyncEngineProvider).syncDraftById(_localId));
    }
  }

  // ── Internals ────────────────────────────────────────────────────────────────

  Future<void> _queueIntent(
    DraftIntent intent, {
    required PieceStatus status,
    DateTime? scheduledAt,
  }) async {
    final EditorState? cur = state.asData?.value;
    if (cur == null) return;
    _debounce?.cancel();
    final Draft queued = cur.liveDraft.copyWith(
      intent: intent,
      status: status,
      scheduledAt: scheduledAt ?? cur.draft.scheduledAt,
      syncState: DraftSyncState.pending,
      localUpdatedAt: DateTime.now().toUtc(),
    );
    await ref.read(draftLocalDataSourceProvider).write(queued);
    _setData(cur.copyWith(draft: queued));
    // Await the sync so the publish/schedule action reflects the outcome (offline
    // it fails transiently and stays queued — replayed on reconnect).
    await ref.read(draftSyncEngineProvider).syncDraftById(_localId);
    _reconcile();
  }

  /// Apply a metadata edit, mark dirty, and schedule autosave.
  void _editDraft(Draft Function(Draft) edit) {
    final EditorState? cur = state.asData?.value;
    if (cur == null) return;
    _commit(cur.copyWith(draft: _markDirty(edit(cur.draft))));
  }

  /// Apply a document edit, mark dirty, and schedule autosave.
  void _editDocument(EditorDocument Function(EditorDocument) edit) {
    final EditorState? cur = state.asData?.value;
    if (cur == null) return;
    _commit(
      cur.copyWith(document: edit(cur.document), draft: _markDirty(cur.draft)),
    );
  }

  void _commit(EditorState next) {
    _setData(next);
    _scheduleSave();
  }

  void _setData(EditorState next) {
    if (_disposed) return;
    _latest = next;
    state = AsyncData<EditorState>(next);
  }

  Draft _markDirty(Draft draft) => draft.copyWith(
    version: draft.version + 1,
    syncState: DraftSyncState.pending,
    intent: DraftIntent.save,
    localUpdatedAt: DateTime.now().toUtc(),
  );

  void _scheduleSave() {
    final bool autosave = ref
        .read(editorPreferencesControllerProvider)
        .autosaveEnabled;
    if (!autosave) return;
    _debounce?.cancel();
    _debounce = Timer(_autosaveDebounce, () => unawaited(_persistLocal()));
  }

  Future<void> _persistLocal() async {
    final EditorState? cur = state.asData?.value;
    if (cur == null || _closed) return;
    _setData(cur.copyWith(autosaving: true));
    final Draft toSave = cur.liveDraft;
    await ref.read(draftLocalDataSourceProvider).write(toSave);
    if (_disposed || _closed) return;
    ref.read(draftSyncEngineProvider).revision.value++;
    // Edits or sync reconciles (e.g. a freshly assigned remoteId) may have landed
    // during the write — fold the save bookkeeping into the CURRENT state, never
    // the pre-await snapshot. The persisted `content` may lag the live document;
    // that is the documented model (EditorState.liveDraft re-encodes).
    final EditorState? after = state.asData?.value;
    if (after == null) return;
    _setData(
      after.copyWith(autosaving: false, lastSavedAt: toSave.localUpdatedAt),
    );
  }

  /// Best-effort synchronous flush on dispose (screen left / app killed) so the
  /// last edits survive even inside the debounce window. Uses the CAPTURED store +
  /// state — never `ref`/`state`, which are illegal to touch during disposal.
  void _flushSync() {
    if (_closed) return;
    final DraftLocalDataSource? store = _store;
    final EditorState? cur = _latest;
    if (store == null || cur == null || _localId.isEmpty) return;
    // Fire-and-forget: Hive writes to memory immediately; do not await in dispose.
    unawaited(store.write(cur.liveDraft));
  }

  /// Merge background-sync outcomes (remote id, status, conflict) onto the live
  /// state without discarding the writer's in-memory edits.
  void _reconcile() {
    final EditorState? cur = state.asData?.value;
    if (cur == null || _localId.isEmpty) return;
    final Draft? stored = ref.read(draftLocalDataSourceProvider).read(_localId);
    if (stored == null) return;
    // Only adopt sync metadata; the live document + editable fields stay ours.
    final Draft merged = cur.draft.copyWith(
      remoteId: stored.remoteId,
      slug: stored.slug,
      status: stored.status,
      syncState: stored.syncState,
      intent: stored.intent,
      remoteUpdatedAt: stored.remoteUpdatedAt,
      coverImageKey: stored.coverImageKey,
      pendingCoverPath: stored.pendingCoverPath,
      publishedAt: stored.publishedAt,
      scheduledAt: stored.scheduledAt,
      lastError: stored.lastError,
    );
    _setData(cur.copyWith(draft: merged));
  }
}

/// A tiny derived provider so the autosave toggle can gate scheduling without the
/// controller taking a hard dependency on the preferences controller's build.
