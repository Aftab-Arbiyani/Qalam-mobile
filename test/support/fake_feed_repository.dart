/// A canned [FeedRepository] for widget/provider tests — returns seeded pages with
/// no network. Every surface can be seeded independently; defaults are empty.
library;

import 'package:qalam_mobile/core/utils/result.dart';
import 'package:qalam_mobile/features/feed/domain/entities/bookmark_item.dart';
import 'package:qalam_mobile/features/feed/domain/entities/cached_page.dart';
import 'package:qalam_mobile/features/feed/domain/entities/piece_summary.dart';
import 'package:qalam_mobile/features/feed/domain/entities/trend_item.dart';
import 'package:qalam_mobile/features/feed/domain/entities/writer_summary.dart';
import 'package:qalam_mobile/features/feed/domain/repositories/feed_repository.dart';
import 'package:qalam_mobile/features/feed/domain/value_objects/feed_query.dart';
import 'package:qalam_mobile/shared/api/api_envelope.dart';

class FakeFeedRepository implements FeedRepository {
  FakeFeedRepository({
    this.pieces = const <PieceSummary>[],
    this.writers = const <WriterSummary>[],
    this.tags = const <TrendingTag>[],
    this.bookmarkItems = const <BookmarkItem>[],
    this.isStale = false,
  });

  final List<PieceSummary> pieces;
  final List<WriterSummary> writers;
  final List<TrendingTag> tags;
  final List<BookmarkItem> bookmarkItems;
  final bool isStale;

  CachedPage<T> _page<T>(List<T> items) => CachedPage<T>(
    page: CursorPage<T>(items: items, meta: const CursorMeta()),
    isStale: isStale,
  );

  @override
  Future<Result<CachedPage<PieceSummary>>> pieceFeed(
    FeedTab tab, {
    FeedQuery query = FeedQuery.none,
    String? cursor,
  }) async => Ok<CachedPage<PieceSummary>>(_page(pieces));

  @override
  Future<Result<CachedPage<PieceSummary>>> discoverPieces(
    kind, {
    String? cursor,
  }) async => Ok<CachedPage<PieceSummary>>(_page(pieces));

  @override
  Future<Result<CachedPage<WriterSummary>>> discoverWriters(
    kind, {
    String? cursor,
  }) async => Ok<CachedPage<WriterSummary>>(_page(writers));

  @override
  Future<Result<CachedPage<TrendingTag>>> trendingTags({
    String? cursor,
  }) async => Ok<CachedPage<TrendingTag>>(_page(tags));

  @override
  Future<Result<CachedPage<TrendingGenre>>> trendingGenres({
    String? cursor,
  }) async => Ok<CachedPage<TrendingGenre>>(_page(const <TrendingGenre>[]));

  @override
  Future<Result<CachedPage<TrendingLanguage>>> trendingLanguages({
    String? cursor,
  }) async =>
      Ok<CachedPage<TrendingLanguage>>(_page(const <TrendingLanguage>[]));

  @override
  Future<Result<CachedPage<BookmarkItem>>> bookmarks({String? cursor}) async =>
      Ok<CachedPage<BookmarkItem>>(_page(bookmarkItems));
}
