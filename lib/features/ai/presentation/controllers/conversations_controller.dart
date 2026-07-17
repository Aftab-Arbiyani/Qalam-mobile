/// The Conversations list controller (AF2) — cursor-paginated history over the reused
/// AF1 conversation API, with on-device pins and rename/archive/delete. Search is a
/// client-side filter in the UI over the loaded rows. Pinned conversations sort first.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/api/api_envelope.dart';
import '../../domain/entities/ai_conversation.dart';
import '../providers/ai_providers.dart';

part 'conversations_controller.g.dart';

class ConversationsState {
  const ConversationsState({
    required this.items,
    required this.pinnedIds,
    this.nextCursor,
    this.hasMore = false,
    this.loadingMore = false,
  });

  final List<AiConversationSummary> items;
  final Set<String> pinnedIds;
  final String? nextCursor;
  final bool hasMore;
  final bool loadingMore;

  bool isPinned(String id) => pinnedIds.contains(id);

  /// Pinned rows first (each group already newest-first from the server).
  List<AiConversationSummary> get ordered {
    final List<AiConversationSummary> pinned =
        items.where((AiConversationSummary c) => pinnedIds.contains(c.id)).toList();
    final List<AiConversationSummary> rest =
        items.where((AiConversationSummary c) => !pinnedIds.contains(c.id)).toList();
    return <AiConversationSummary>[...pinned, ...rest];
  }

  ConversationsState copyWith({
    List<AiConversationSummary>? items,
    Set<String>? pinnedIds,
    String? nextCursor,
    bool? hasMore,
    bool? loadingMore,
  }) =>
      ConversationsState(
        items: items ?? this.items,
        pinnedIds: pinnedIds ?? this.pinnedIds,
        nextCursor: nextCursor ?? this.nextCursor,
        hasMore: hasMore ?? this.hasMore,
        loadingMore: loadingMore ?? this.loadingMore,
      );
}

@riverpod
class ConversationsController extends _$ConversationsController {
  @override
  Future<ConversationsState> build() async {
    final CursorPage<AiConversationSummary> page = await _loadPage(null);
    return ConversationsState(
      items: page.items,
      pinnedIds: ref.read(promptLibraryStoreProvider).pinnedConversationIds(),
      nextCursor: page.meta.nextCursor,
      hasMore: page.hasMore,
    );
  }

  Future<CursorPage<AiConversationSummary>> _loadPage(String? cursor) async {
    final Result<CursorPage<AiConversationSummary>> result =
        await ref.read(aiRepositoryProvider).listConversations(cursor: cursor);
    return switch (result) {
      Ok<CursorPage<AiConversationSummary>>(:final CursorPage<AiConversationSummary> value) => value,
      Err<CursorPage<AiConversationSummary>>(:final Failure failure) => throw failure,
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
      final CursorPage<AiConversationSummary> page = await _loadPage(current.nextCursor);
      state = AsyncData<ConversationsState>(current.copyWith(
        items: <AiConversationSummary>[...current.items, ...page.items],
        nextCursor: page.meta.nextCursor,
        hasMore: page.hasMore,
        loadingMore: false,
      ));
    } on Object {
      state = AsyncData<ConversationsState>(current.copyWith(loadingMore: false));
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

  Future<bool> rename(String id, String title) async {
    final Result<AiConversationSummary> result =
        await ref.read(aiRepositoryProvider).renameConversation(id, title);
    return result.fold((AiConversationSummary updated) {
      _replace(updated);
      return true;
    }, (_) => false);
  }

  Future<bool> archive(String id) async {
    final Result<AiConversationSummary> result = await ref
        .read(aiRepositoryProvider)
        .setConversationStatus(id, AiConversationStatus.archived);
    return result.fold((AiConversationSummary updated) {
      // Archived rows drop out of the default (active) list.
      _remove(id);
      return true;
    }, (_) => false);
  }

  Future<bool> delete(String id) async {
    final ConversationsState? current = state.asData?.value;
    if (current == null) return false;
    // Optimistic removal; restore on failure.
    _remove(id);
    final Result<void> result = await ref.read(aiRepositoryProvider).deleteConversation(id);
    return result.fold((_) => true, (_) {
      state = AsyncData<ConversationsState>(current);
      return false;
    });
  }

  void _replace(AiConversationSummary updated) {
    final ConversationsState? current = state.asData?.value;
    if (current == null) return;
    state = AsyncData<ConversationsState>(current.copyWith(
      items: current.items
          .map((AiConversationSummary c) => c.id == updated.id ? updated : c)
          .toList(growable: false),
    ));
  }

  void _remove(String id) {
    final ConversationsState? current = state.asData?.value;
    if (current == null) return;
    final Set<String> pins = <String>{...current.pinnedIds}..remove(id);
    state = AsyncData<ConversationsState>(current.copyWith(
      items: current.items.where((AiConversationSummary c) => c.id != id).toList(growable: false),
      pinnedIds: pins,
    ));
  }
}
