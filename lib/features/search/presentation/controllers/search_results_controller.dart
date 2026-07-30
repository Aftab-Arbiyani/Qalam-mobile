/// Search result providers (docs/40 §8.3, §13.7, E8). The grouped preview for the
/// "All" tab is a single [globalSearch] future (no pagination). Each per-type tab
/// (pieces / writers / tags / genres / languages) is an infinite, cursor-paginated
/// [SearchResultsController] keyed by the concrete [SearchRequest] — one controller
/// for every type, no per-type duplication, reusing the shared [CursorPaginator]
/// and cache-then-network repository. A stale cursor resets to page one.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/api/api_envelope.dart';
import '../../../../shared/domain/enums.dart';
import '../../../../shared/domain/error_codes.dart';
import '../../../../shared/pagination/cached_page.dart';
import '../../../../shared/pagination/paged_list_state.dart';
import '../../domain/entities/global_search_result.dart';
import '../../domain/value_objects/search_request.dart';
import '../providers/search_providers.dart';

part 'search_results_controller.g.dart';

/// The grouped "All" preview for [query] (≥ min length). Errors surface as
/// `AsyncError`; the repository already falls back to a cached preview offline.
@riverpod
Future<GlobalSearchResult> globalSearch(Ref ref, String query) async {
  if (query.trim().isEmpty) return const GlobalSearchResult();
  final result = await ref.read(searchRepositoryProvider).globalSearch(query);
  return result.fold(
    (GlobalSearchResult value) => value,
    (Object failure) => throw failure,
  );
}

@riverpod
class SearchResultsController extends _$SearchResultsController {
  CursorPaginator<Object>? _paginator;

  @override
  Future<PagedListState<Object>> build(SearchRequest request) {
    final paginator = CursorPaginator<Object>(
      (String? cursor) => _fetch(request, cursor),
    );
    _paginator = paginator;
    return paginator.first();
  }

  Future<Result<CachedPage<Object>>> _fetch(
    SearchRequest request,
    String? cursor,
  ) {
    final repo = ref.read(searchRepositoryProvider);
    final String q = request.query;
    switch (request.type) {
      case SearchType.pieces:
        return _erase(repo.searchPieces(q, request.filters, cursor: cursor));
      case SearchType.writers:
        return _erase(repo.searchWriters(q, request.filters, cursor: cursor));
      case SearchType.tags:
        return _erase(repo.searchTags(q, cursor: cursor));
      case SearchType.genres:
        return _erase(repo.searchGenres(q, cursor: cursor));
      case SearchType.languages:
        return _erase(repo.searchLanguages(q, cursor: cursor));
      case SearchType.all:
        // The "All" tab uses [globalSearch]; never paginated here.
        return Future<Result<CachedPage<Object>>>.value(
          const Ok<CachedPage<Object>>(
            CachedPage<Object>(
              page: CursorPage<Object>(items: <Object>[], meta: CursorMeta()),
            ),
          ),
        );
    }
  }

  /// Widen a typed cached page to `Object` items so one controller serves every
  /// result type (a `List` of `T` is covariantly a `List` of `Object`).
  Future<Result<CachedPage<Object>>> _erase<T extends Object>(
    Future<Result<CachedPage<T>>> future,
  ) async {
    final Result<CachedPage<T>> result = await future;
    return result.map(
      (CachedPage<T> c) => CachedPage<Object>(
        page: CursorPage<Object>(items: c.page.items, meta: c.page.meta),
        isStale: c.isStale,
      ),
    );
  }

  Future<void> loadMore() async {
    final CursorPaginator<Object>? paginator = _paginator;
    final PagedListState<Object>? current = state.asData?.value;
    if (paginator == null ||
        current == null ||
        !current.hasMore ||
        current.isLoadingMore) {
      return;
    }
    final PagedListState<Object> pending = current.copyWith(
      isLoadingMore: true,
    );
    state = AsyncData<PagedListState<Object>>(pending);
    final PagedListState<Object> updated = await paginator.next(current);
    // A refresh() may have replaced the list while this page was in flight;
    // committing would resurrect the pre-refresh list with a stale cursor.
    if (!identical(state.asData?.value, pending)) return;
    if (_isInvalidCursor(updated.loadMoreFailure)) {
      await refresh();
      return;
    }
    state = AsyncData<PagedListState<Object>>(updated);
  }

  Future<void> refresh() async {
    final CursorPaginator<Object>? paginator = _paginator;
    if (paginator == null) return;
    state = await AsyncValue.guard(paginator.first);
  }

  bool _isInvalidCursor(Failure? failure) =>
      failure is ValidationFailure &&
      failure.code == ErrorCodes.feedInvalidCursor;
}
