/// The shared feed timeline controller (docs/40 §8.3). ONE controller drives all
/// four piece-summary tabs (Following / For You / Trending / Latest) via a family
/// keyed by [FeedTab] — no per-tab code. Page-1 load/error is the `AsyncValue`;
/// [loadMore] and [refresh] mutate through the shared [FeedPaginator]. A stale
/// cursor (`FEED_INVALID_CURSOR`) resets to page one (docs/40 §13.7).
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failure.dart';
import '../../../../shared/domain/error_codes.dart';
import '../../domain/entities/piece_summary.dart';
import '../../domain/value_objects/feed_query.dart';
import '../providers/feed_providers.dart';
import '../state/paged_list_state.dart';

part 'feed_list_controller.g.dart';

@riverpod
class FeedListController extends _$FeedListController {
  FeedPaginator<PieceSummary>? _paginator;

  @override
  Future<PagedListState<PieceSummary>> build(FeedTab tab) {
    final paginator = FeedPaginator<PieceSummary>(
      (String? cursor) =>
          ref.read(feedRepositoryProvider).pieceFeed(tab, cursor: cursor),
    );
    _paginator = paginator;
    return paginator.first();
  }

  Future<void> loadMore() async {
    final FeedPaginator<PieceSummary>? paginator = _paginator;
    final PagedListState<PieceSummary>? current = state.asData?.value;
    if (paginator == null ||
        current == null ||
        !current.hasMore ||
        current.isLoadingMore) {
      return;
    }
    state = AsyncData<PagedListState<PieceSummary>>(
      current.copyWith(isLoadingMore: true),
    );
    final PagedListState<PieceSummary> updated = await paginator.next(current);
    if (_isInvalidCursor(updated.loadMoreFailure)) {
      await refresh();
      return;
    }
    state = AsyncData<PagedListState<PieceSummary>>(updated);
  }

  /// Pull-to-refresh — re-fetch page one (network-first) and replace, keeping the
  /// old content painted while it runs.
  Future<void> refresh() async {
    final FeedPaginator<PieceSummary>? paginator = _paginator;
    if (paginator == null) return;
    state = await AsyncValue.guard(paginator.first);
  }

  bool _isInvalidCursor(Failure? failure) =>
      failure is ValidationFailure &&
      failure.code == ErrorCodes.feedInvalidCursor;
}
