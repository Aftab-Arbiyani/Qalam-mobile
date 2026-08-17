/// Comment + reply controllers (docs/40 §8.3, §21.4) — infinite cursor-paginated
/// threads over the shared [CommentRepository], with OPTIMISTIC add / edit /
/// delete and rollback. Add prepends a provisional node (authored by the current
/// user) then reconciles to the server node or removes it on failure. Delete
/// applies the soft-delete tombstone locally (replies stay visible), matching the
/// server. Reuses the shared [CursorPaginator]; no bespoke pagination.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/session/current_user.dart';
import '../../../../core/session/current_user_controller.dart';
import '../../../../core/sync/sync_providers.dart';
import '../../../pagination/paged_list_state.dart';
import '../../data/sync/comment_sync_handler.dart';
import '../../domain/entities/comment.dart';
import '../../social_providers.dart';

part 'comments_controller.g.dart';

/// The tombstone body the server uses for a soft-deleted comment.
const String kDeletedCommentBody = 'This comment has been deleted.';

@riverpod
class CommentsController extends _$CommentsController {
  CursorPaginator<Comment>? _paginator;

  @override
  Future<PagedListState<Comment>> build(String pieceId) {
    final paginator = CursorPaginator<Comment>(
      (String? cursor) => ref
          .read(commentRepositoryProvider)
          .listComments(pieceId, cursor: cursor),
    );
    _paginator = paginator;
    return paginator.first();
  }

  Future<void> loadMore() => loadMorePaged(_paginator, state, (s) => state = s);

  Future<void> refresh() async {
    final p = _paginator;
    if (p != null) state = await AsyncValue.guard(p.first);
  }

  /// Optimistically prepend a provisional comment, then reconcile with the server
  /// node (id/timestamps) or remove it on failure.
  Future<void> add(String body) async {
    final PagedListState<Comment>? current = state.asData?.value;
    if (current == null) return;
    final Comment provisional = _provisional(body);
    state = AsyncData<PagedListState<Comment>>(
      current.copyWith(items: <Comment>[provisional, ...current.items]),
    );
    // Offline: keep the provisional node and queue the create on the unified engine
    // — a later refresh reconciles it to the real server node (docs/40 §23).
    if (!ref.read(connectivityServiceProvider).isOnline) {
      await ref
          .read(syncEngineProvider)
          .enqueue(
            buildCommentOperation(
              tempId: provisional.id,
              pieceId: pieceId,
              body: body,
              label: 'Comment',
            ),
          );
      return;
    }
    final result = await ref
        .read(commentRepositoryProvider)
        .addComment(pieceId, body);
    result.fold(
      (Comment saved) => _replace(provisional.id, saved),
      (Object _) => _remove(provisional.id),
    );
  }

  /// Optimistically apply an edit (new body + edit stamp), reconcile / roll back.
  Future<void> edit(String commentId, String body) async {
    final PagedListState<Comment>? current = state.asData?.value;
    if (current == null) return;
    final Comment? original = _find(commentId);
    if (original == null) return;
    _replace(
      commentId,
      original.copyWith(body: body, editedAt: DateTime.now()),
    );
    final result = await ref
        .read(commentRepositoryProvider)
        .edit(commentId, body);
    result.fold(
      (Comment saved) => _replace(commentId, saved),
      (Object _) => _replace(commentId, original), // rollback
    );
  }

  /// Optimistically tombstone a comment (replies stay), reconcile / roll back.
  Future<void> delete(String commentId) async {
    final Comment? original = _find(commentId);
    if (original == null) return;
    _replace(
      commentId,
      original.copyWith(
        isDeleted: true,
        author: null,
        body: kDeletedCommentBody,
      ),
    );
    final result = await ref.read(commentRepositoryProvider).delete(commentId);
    if (result.isErr) _replace(commentId, original); // rollback
  }

  Comment _provisional(String body) {
    final CurrentUser? user = ref.read(currentUserControllerProvider);
    return Comment(
      id: 'temp:${DateTime.now().microsecondsSinceEpoch}',
      author: user == null ? null : CommentAuthor(username: user.username),
      body: body,
      createdAt: DateTime.now(),
    );
  }

  Comment? _find(String id) {
    for (final Comment c in state.asData?.value.items ?? const <Comment>[]) {
      if (c.id == id) return c;
    }
    return null;
  }

  void _replace(String id, Comment next) {
    final PagedListState<Comment>? current = state.asData?.value;
    if (current == null) return;
    state = AsyncData<PagedListState<Comment>>(
      current.copyWith(
        items: current.items.map((Comment c) => c.id == id ? next : c).toList(),
      ),
    );
  }

  void _remove(String id) {
    final PagedListState<Comment>? current = state.asData?.value;
    if (current == null) return;
    state = AsyncData<PagedListState<Comment>>(
      current.copyWith(
        items: current.items.where((Comment c) => c.id != id).toList(),
      ),
    );
  }
}

@riverpod
class RepliesController extends _$RepliesController {
  CursorPaginator<Comment>? _paginator;

  @override
  Future<PagedListState<Comment>> build(String commentId) {
    final paginator = CursorPaginator<Comment>(
      (String? cursor) => ref
          .read(commentRepositoryProvider)
          .listReplies(commentId, cursor: cursor),
    );
    _paginator = paginator;
    return paginator.first();
  }

  Future<void> loadMore() => loadMorePaged(_paginator, state, (s) => state = s);

  Future<void> refresh() async {
    final p = _paginator;
    if (p != null) state = await AsyncValue.guard(p.first);
  }

  /// Optimistically apply an edit to a reply, reconcile / roll back.
  Future<void> edit(String replyId, String body) async {
    final Comment? original = _find(replyId);
    if (original == null) return;
    _replace(replyId, original.copyWith(body: body, editedAt: DateTime.now()));
    final result = await ref
        .read(commentRepositoryProvider)
        .edit(replyId, body);
    result.fold(
      (Comment saved) => _replace(replyId, saved),
      (Object _) => _replace(replyId, original),
    );
  }

  /// Optimistically tombstone a reply, reconcile / roll back.
  Future<void> delete(String replyId) async {
    final Comment? original = _find(replyId);
    if (original == null) return;
    _replace(
      replyId,
      original.copyWith(
        isDeleted: true,
        author: null,
        body: kDeletedCommentBody,
      ),
    );
    final result = await ref.read(commentRepositoryProvider).delete(replyId);
    if (result.isErr) _replace(replyId, original);
  }

  Comment? _find(String id) {
    for (final Comment c in state.asData?.value.items ?? const <Comment>[]) {
      if (c.id == id) return c;
    }
    return null;
  }

  void _replace(String id, Comment next) {
    final PagedListState<Comment>? current = state.asData?.value;
    if (current == null) return;
    state = AsyncData<PagedListState<Comment>>(
      current.copyWith(
        items: current.items.map((Comment c) => c.id == id ? next : c).toList(),
      ),
    );
  }

  /// Optimistically prepend a provisional reply, reconcile / roll back.
  Future<void> add(String body) async {
    final PagedListState<Comment>? current = state.asData?.value;
    if (current == null) return;
    final CurrentUser? user = ref.read(currentUserControllerProvider);
    final Comment provisional = Comment(
      id: 'temp:${DateTime.now().microsecondsSinceEpoch}',
      parentId: commentId,
      depth: 2,
      author: user == null ? null : CommentAuthor(username: user.username),
      body: body,
      createdAt: DateTime.now(),
    );
    state = AsyncData<PagedListState<Comment>>(
      current.copyWith(items: <Comment>[provisional, ...current.items]),
    );
    if (!ref.read(connectivityServiceProvider).isOnline) {
      await ref
          .read(syncEngineProvider)
          .enqueue(
            buildCommentOperation(
              tempId: provisional.id,
              pieceId: commentId,
              body: body,
              parentId: commentId,
              label: 'Reply',
            ),
          );
      return;
    }
    final result = await ref
        .read(commentRepositoryProvider)
        .reply(commentId, body);
    result.fold(
      (Comment saved) {
        final PagedListState<Comment>? now = state.asData?.value;
        if (now == null) return;
        state = AsyncData<PagedListState<Comment>>(
          now.copyWith(
            items: now.items
                .map((Comment c) => c.id == provisional.id ? saved : c)
                .toList(),
          ),
        );
      },
      (Object _) {
        final PagedListState<Comment>? now = state.asData?.value;
        if (now == null) return;
        state = AsyncData<PagedListState<Comment>>(
          now.copyWith(
            items: now.items
                .where((Comment c) => c.id != provisional.id)
                .toList(),
          ),
        );
      },
    );
  }
}

/// Shared load-more step for comment threads — appends the next page.
Future<void> loadMorePaged(
  CursorPaginator<Comment>? paginator,
  AsyncValue<PagedListState<Comment>> currentAsync,
  void Function(AsyncValue<PagedListState<Comment>>) write,
) async {
  final PagedListState<Comment>? current = currentAsync.asData?.value;
  if (paginator == null ||
      current == null ||
      !current.hasMore ||
      current.isLoadingMore) {
    return;
  }
  write(
    AsyncData<PagedListState<Comment>>(current.copyWith(isLoadingMore: true)),
  );
  write(AsyncData<PagedListState<Comment>>(await paginator.next(current)));
}
