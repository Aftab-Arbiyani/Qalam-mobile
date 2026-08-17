/// Follow-graph list controllers (docs/40 §8.3) — followers, following, and the
/// signed-in user's pending requests, each an infinite cursor-paginated
/// [PagedListState] over the shared [FollowRepository], reusing the shared
/// [CursorPaginator] (no bespoke pagination). Requests additionally accept/reject
/// with optimistic removal + rollback.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../pagination/paged_list_state.dart';
import '../../domain/entities/follow_user.dart';
import '../../social_providers.dart';

part 'follow_controllers.g.dart';

@riverpod
class FollowersController extends _$FollowersController {
  CursorPaginator<FollowUser>? _paginator;

  @override
  Future<PagedListState<FollowUser>> build(String username) {
    final paginator = CursorPaginator<FollowUser>(
      (String? cursor) => ref
          .read(followRepositoryProvider)
          .followers(username, cursor: cursor),
    );
    _paginator = paginator;
    return paginator.first();
  }

  Future<void> loadMore() => _loadMore(_paginator, state, (s) => state = s);
  Future<void> refresh() async {
    final p = _paginator;
    if (p != null) state = await AsyncValue.guard(p.first);
  }
}

@riverpod
class FollowingController extends _$FollowingController {
  CursorPaginator<FollowUser>? _paginator;

  @override
  Future<PagedListState<FollowUser>> build(String username) {
    final paginator = CursorPaginator<FollowUser>(
      (String? cursor) => ref
          .read(followRepositoryProvider)
          .following(username, cursor: cursor),
    );
    _paginator = paginator;
    return paginator.first();
  }

  Future<void> loadMore() => _loadMore(_paginator, state, (s) => state = s);
  Future<void> refresh() async {
    final p = _paginator;
    if (p != null) state = await AsyncValue.guard(p.first);
  }
}

@riverpod
class FollowRequestsController extends _$FollowRequestsController {
  CursorPaginator<FollowRequest>? _paginator;

  @override
  Future<PagedListState<FollowRequest>> build() {
    final paginator = CursorPaginator<FollowRequest>(
      (String? cursor) =>
          ref.read(followRepositoryProvider).requests(cursor: cursor),
    );
    _paginator = paginator;
    return paginator.first();
  }

  Future<void> loadMore() => _loadMore(_paginator, state, (s) => state = s);
  Future<void> refresh() async {
    final p = _paginator;
    if (p != null) state = await AsyncValue.guard(p.first);
  }

  /// Accept a request; optimistically drop it from the list, restore on failure.
  Future<void> accept(String followId) => _resolve(followId, accept: true);

  /// Reject a request; optimistically drop it from the list, restore on failure.
  Future<void> reject(String followId) => _resolve(followId, accept: false);

  Future<void> _resolve(String followId, {required bool accept}) async {
    final PagedListState<FollowRequest>? current = state.asData?.value;
    if (current == null) return;
    final List<FollowRequest> without = current.items
        .where((FollowRequest r) => r.id != followId)
        .toList();
    state = AsyncData<PagedListState<FollowRequest>>(
      current.copyWith(items: without),
    );
    final repo = ref.read(followRepositoryProvider);
    final result = accept
        ? await repo.acceptRequest(followId)
        : await repo.rejectRequest(followId);
    if (result.isErr) {
      state = AsyncData<PagedListState<FollowRequest>>(current); // rollback
    }
  }
}

/// Shared load-more step for the follow lists — appends the next page, resetting
/// on a bad cursor (mirrors the feed/search controllers).
Future<void> _loadMore<T>(
  CursorPaginator<T>? paginator,
  AsyncValue<PagedListState<T>> currentAsync,
  void Function(AsyncValue<PagedListState<T>>) write,
) async {
  final PagedListState<T>? current = currentAsync.asData?.value;
  if (paginator == null ||
      current == null ||
      !current.hasMore ||
      current.isLoadingMore) {
    return;
  }
  write(AsyncData<PagedListState<T>>(current.copyWith(isLoadingMore: true)));
  final PagedListState<T> updated = await paginator.next(current);
  write(AsyncData<PagedListState<T>>(updated));
}
