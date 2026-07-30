/// Shared cursor-pagination state + engine (docs/40 §8.3, §36). EVERY feed,
/// bookmark, and profile timeline reuses this — there is no per-surface pagination
/// code. A list controller holds an `AsyncValue<PagedListState<T>>`: page-1
/// loading/error is the `AsyncValue` (→ skeleton / error view), while subsequent
/// pages live inside the state ([isLoadingMore], [loadMoreFailure]) so the
/// accumulated list stays painted while the next page loads (docs/41 §17). Cursors
/// stay opaque and out of the UI.
library;

import 'package:flutter/foundation.dart';

import '../../core/error/failure.dart';
import '../../core/utils/result.dart';
import 'cached_page.dart';

@immutable
class PagedListState<T> {
  const PagedListState({
    this.items = const <Never>[],
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.isStale = false,
    this.loadMoreFailure,
  });

  /// The accumulated items across all loaded pages.
  final List<T> items;

  /// Opaque cursor for the next page (`null` at the end).
  final String? nextCursor;

  /// Whether more pages exist AND a cursor is available.
  final bool hasMore;

  /// A subsequent-page fetch is in flight (drives the trailing loader).
  final bool isLoadingMore;

  /// The list was served from cache (offline / stale) — drives the stale banner.
  final bool isStale;

  /// A subsequent-page fetch failed; the existing items remain painted.
  final Failure? loadMoreFailure;

  bool get isEmpty => items.isEmpty;

  PagedListState<T> copyWith({
    List<T>? items,
    String? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isStale,
    Failure? loadMoreFailure,
    bool clearLoadMoreFailure = false,
    bool clearCursor = false,
  }) => PagedListState<T>(
    items: items ?? this.items,
    nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    isStale: isStale ?? this.isStale,
    loadMoreFailure: clearLoadMoreFailure
        ? null
        : (loadMoreFailure ?? this.loadMoreFailure),
  );
}

/// The pagination engine shared by every list controller. It takes one callback —
/// fetch a page for a cursor — and turns [CachedPage] results into state
/// transitions. All the loadMore / append / end-of-list / error handling lives
/// here, once (docs/40 §44.4 "no duplicated feed implementations").
class CursorPaginator<T> {
  const CursorPaginator(this._fetch);

  /// Fetch one page for [cursor] (`null` = first page).
  final Future<Result<CachedPage<T>>> Function(String? cursor) _fetch;

  /// Load the first page. On failure the [Failure] is THROWN so the owning
  /// `AsyncNotifier` surfaces `AsyncError` (→ full-screen error view).
  Future<PagedListState<T>> first() async {
    final Result<CachedPage<T>> result = await _fetch(null);
    return result.fold(
      (CachedPage<T> cached) => PagedListState<T>(
        items: cached.page.items,
        nextCursor: cached.page.meta.nextCursor,
        hasMore: cached.page.hasMore,
        isStale: cached.isStale,
      ),
      (Failure failure) => throw failure,
    );
  }

  /// Append the next page. A failure is captured in-state (existing items stay);
  /// end-of-list and in-flight are no-ops.
  Future<PagedListState<T>> next(PagedListState<T> current) async {
    if (!current.hasMore || current.isLoadingMore) return current;
    final Result<CachedPage<T>> result = await _fetch(current.nextCursor);
    return result.fold(
      (CachedPage<T> cached) => current.copyWith(
        items: <T>[...current.items, ...cached.page.items],
        nextCursor: cached.page.meta.nextCursor,
        hasMore: cached.page.hasMore,
        isLoadingMore: false,
        clearLoadMoreFailure: true,
        clearCursor: cached.page.meta.nextCursor == null,
      ),
      (Failure failure) =>
          current.copyWith(isLoadingMore: false, loadMoreFailure: failure),
    );
  }
}
