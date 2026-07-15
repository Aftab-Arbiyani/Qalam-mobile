/// The Bookmarks feed controller (docs/40 §8.3) — the same shared pagination
/// engine as the piece feeds, over `GET /me/bookmarks`. Cache-then-network with
/// offline fallback; infinite scroll + pull-to-refresh.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/pagination/paged_list_state.dart';
import '../../domain/entities/bookmark_item.dart';
import '../providers/feed_providers.dart';

part 'bookmarks_controller.g.dart';

@riverpod
class BookmarksController extends _$BookmarksController {
  CursorPaginator<BookmarkItem>? _paginator;

  @override
  Future<PagedListState<BookmarkItem>> build() {
    final paginator = CursorPaginator<BookmarkItem>(
      (String? cursor) =>
          ref.read(feedRepositoryProvider).bookmarks(cursor: cursor),
    );
    _paginator = paginator;
    return paginator.first();
  }

  Future<void> loadMore() async {
    final CursorPaginator<BookmarkItem>? paginator = _paginator;
    final PagedListState<BookmarkItem>? current = state.asData?.value;
    if (paginator == null ||
        current == null ||
        !current.hasMore ||
        current.isLoadingMore) {
      return;
    }
    state = AsyncData<PagedListState<BookmarkItem>>(
      current.copyWith(isLoadingMore: true),
    );
    state = AsyncData<PagedListState<BookmarkItem>>(
      await paginator.next(current),
    );
  }

  Future<void> refresh() async {
    final CursorPaginator<BookmarkItem>? paginator = _paginator;
    if (paginator == null) return;
    state = await AsyncValue.guard(paginator.first);
  }

  /// Optimistically drop a piece from the bookmarks list after it is un-bookmarked
  /// elsewhere (the reader), without a round-trip.
  void removeLocally(String pieceId) {
    final PagedListState<BookmarkItem>? current = state.asData?.value;
    if (current == null) return;
    state = AsyncData<PagedListState<BookmarkItem>>(
      current.copyWith(
        items: current.items
            .where((BookmarkItem b) => b.pieceId != pieceId)
            .toList(growable: false),
      ),
    );
  }
}
