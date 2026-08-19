/// The Conversations list controller (AF2) — cursor-paginated history over the reused
/// AF1 conversation API, with on-device pins and rename/archive/delete. Search is a
/// client-side filter in the UI over the loaded rows. Pinned conversations sort first.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/api/api_envelope.dart';
import '../../domain/entities/ai_conversation.dart';
import '../../domain/value_objects/ai_feature_ids.dart';
import '../providers/ai_providers.dart';

part 'conversations_controller.g.dart';

class ConversationsState {
  const ConversationsState({
    required this.items,
    required this.pinnedIds,
    required this.shelf,
    this.nextCursor,
    this.hasMore = false,
    this.loadingMore = false,
  });

  final List<AiConversationSummary> items;
  final Set<String> pinnedIds;

  /// Which shelf these rows came from. The route filters by status server-side and defaults to
  /// `active`, so this is a request parameter rather than a view filter — and it decides whether a
  /// row's action is Archive or Restore.
  final AiConversationStatus shelf;
  final String? nextCursor;
  final bool hasMore;
  final bool loadingMore;

  bool get isArchivedShelf => shelf == AiConversationStatus.archived;

  bool isPinned(String id) => pinnedIds.contains(id);

  /// Pinned rows first (each group already newest-first from the server).
  List<AiConversationSummary> get ordered {
    final List<AiConversationSummary> pinned = items
        .where((AiConversationSummary c) => pinnedIds.contains(c.id))
        .toList();
    final List<AiConversationSummary> rest = items
        .where((AiConversationSummary c) => !pinnedIds.contains(c.id))
        .toList();
    return <AiConversationSummary>[...pinned, ...rest];
  }

  ConversationsState copyWith({
    List<AiConversationSummary>? items,
    Set<String>? pinnedIds,
    AiConversationStatus? shelf,
    String? nextCursor,
    bool? hasMore,
    bool? loadingMore,
  }) => ConversationsState(
    items: items ?? this.items,
    pinnedIds: pinnedIds ?? this.pinnedIds,
    shelf: shelf ?? this.shelf,
    nextCursor: nextCursor ?? this.nextCursor,
    hasMore: hasMore ?? this.hasMore,
    loadingMore: loadingMore ?? this.loadingMore,
  );
}

@riverpod
class ConversationsController extends _$ConversationsController {
  /// The shelf the next load reads. Held on the notifier rather than in the state because it is an
  /// INPUT to `build()`, not a product of it — `refresh()` re-runs `build()` and must not read the
  /// shelf back out of a state it is about to replace.
  AiConversationStatus _shelf = AiConversationStatus.active;

  @override
  Future<ConversationsState> build() async {
    final CursorPage<AiConversationSummary> page = await _loadPage(null);
    return ConversationsState(
      items: page.items,
      pinnedIds: ref.read(promptLibraryStoreProvider).pinnedConversationIds(),
      shelf: _shelf,
      nextCursor: page.meta.nextCursor,
      hasMore: page.hasMore,
    );
  }

  /// Switch shelves. A no-op when already there, so tapping the current tab does not refetch.
  Future<void> setShelf(AiConversationStatus shelf) async {
    if (_shelf == shelf) return;
    _shelf = shelf;
    await refresh();
  }

  Future<CursorPage<AiConversationSummary>> _loadPage(String? cursor) async {
    final Result<CursorPage<AiConversationSummary>> result = await ref
        .read(aiRepositoryProvider)
        .listConversations(cursor: cursor, status: _shelf);
    return switch (result) {
      Ok<CursorPage<AiConversationSummary>>(
        :final CursorPage<AiConversationSummary> value,
      ) =>
        value,
      Err<CursorPage<AiConversationSummary>>(:final Failure failure) =>
        throw failure,
    };
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(build);
  }

  Future<void> loadMore() async {
    final ConversationsState? current = state.asData?.value;
    if (current == null || !current.hasMore || current.loadingMore) return;
    state = AsyncData<ConversationsState>(current.copyWith(loadingMore: true));
    try {
      final CursorPage<AiConversationSummary> page = await _loadPage(
        current.nextCursor,
      );
      state = AsyncData<ConversationsState>(
        current.copyWith(
          items: <AiConversationSummary>[...current.items, ...page.items],
          nextCursor: page.meta.nextCursor,
          hasMore: page.hasMore,
          loadingMore: false,
        ),
      );
    } on Object {
      state = AsyncData<ConversationsState>(
        current.copyWith(loadingMore: false),
      );
    }
  }

  Future<void> togglePin(String id) async {
    final ConversationsState? current = state.asData?.value;
    if (current == null) return;
    final Set<String> next = <String>{...current.pinnedIds};
    if (!next.remove(id)) next.add(id);
    await ref.read(promptLibraryStoreProvider).setPinnedConversationIds(next);
    state = AsyncData<ConversationsState>(current.copyWith(pinnedIds: next));
  }

  /// Start a new conversation and prepend it to the list. Returns null on
  /// failure so the caller can report it rather than navigating nowhere.
  ///
  /// Defect **W8-1** (`platfrom/docs/48` §3.12): `createConversation` existed in
  /// every mobile AI layer with zero UI callers, so `GET /ai/conversations`
  /// returned an empty page forever and the whole screen behind it was dead
  /// code. This is the entry point that was missing.
  Future<AiConversationSummary?> create({
    String feature = AiFeatureIds.writingAssistant,
  }) async {
    final Result<AiConversationSummary> result = await ref
        .read(aiRepositoryProvider)
        .createConversation(feature: feature);
    return result.fold((AiConversationSummary created) {
      final ConversationsState? current = state.asData?.value;
      if (current != null) {
        state = AsyncData<ConversationsState>(
          current.copyWith(
            items: <AiConversationSummary>[created, ...current.items],
          ),
        );
      }
      return created;
    }, (_) => null);
  }

  Future<bool> rename(String id, String title) async {
    final Result<AiConversationSummary> result = await ref
        .read(aiRepositoryProvider)
        .renameConversation(id, title);
    return result.fold((AiConversationSummary updated) {
      _replace(updated);
      return true;
    }, (_) => false);
  }

  /// Archive a conversation, or restore one from the archive.
  ///
  /// **Both directions exist, and that is the point.** Between the backend gaining its status filter
  /// and this change, archiving on mobile removed a conversation from the only list that could show
  /// it — a delete with a gentler label (`platfrom/docs/48` §3.21). Archive is only honest to offer
  /// alongside a way back.
  ///
  /// The row leaves the list when it leaves this shelf, and its **pin survives**: a pin is on-device
  /// and archiving is not deleting, so restoring a pinned conversation brings the pin back with it.
  /// `_remove` drops pins, which is right for delete and wrong here.
  Future<bool> setStatus(String id, AiConversationStatus status) async {
    final Result<AiConversationSummary> result = await ref
        .read(aiRepositoryProvider)
        .setConversationStatus(id, status);
    return result.fold((AiConversationSummary updated) {
      if (status == _shelf) {
        _replace(updated);
      } else {
        _drop(id);
      }
      return true;
    }, (_) => false);
  }

  /// Archive. Kept as a named method because the screen reads better for it than for a status enum.
  Future<bool> archive(String id) =>
      setStatus(id, AiConversationStatus.archived);

  /// Restore from the archive.
  Future<bool> restore(String id) => setStatus(id, AiConversationStatus.active);

  Future<bool> delete(String id) async {
    final ConversationsState? current = state.asData?.value;
    if (current == null) return false;
    // Optimistic removal; restore on failure.
    _remove(id);
    final Result<void> result = await ref
        .read(aiRepositoryProvider)
        .deleteConversation(id);
    return result.fold((_) => true, (_) {
      state = AsyncData<ConversationsState>(current);
      return false;
    });
  }

  void _replace(AiConversationSummary updated) {
    final ConversationsState? current = state.asData?.value;
    if (current == null) return;
    state = AsyncData<ConversationsState>(
      current.copyWith(
        items: current.items
            .map((AiConversationSummary c) => c.id == updated.id ? updated : c)
            .toList(growable: false),
      ),
    );
  }

  /// Take a row off the current shelf WITHOUT touching its pin — it moved, it was not deleted.
  void _drop(String id) {
    final ConversationsState? current = state.asData?.value;
    if (current == null) return;
    state = AsyncData<ConversationsState>(
      current.copyWith(
        items: current.items
            .where((AiConversationSummary c) => c.id != id)
            .toList(growable: false),
      ),
    );
  }

  /// Take a row off the shelf AND drop its pin — for a conversation that no longer exists.
  void _remove(String id) {
    final ConversationsState? current = state.asData?.value;
    if (current == null) return;
    final Set<String> pins = <String>{...current.pinnedIds}..remove(id);
    state = AsyncData<ConversationsState>(
      current.copyWith(
        items: current.items
            .where((AiConversationSummary c) => c.id != id)
            .toList(growable: false),
        pinnedIds: pins,
      ),
    );
  }
}
