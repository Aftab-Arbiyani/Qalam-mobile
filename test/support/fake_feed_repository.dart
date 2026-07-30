/// Canned [FeedRepository] + [DiscoveryRepository] for widget/provider tests —
/// return seeded pages with no network. Every surface can be seeded
/// independently; defaults are empty.
library;

import 'package:qalam_mobile/core/utils/result.dart';
import 'package:qalam_mobile/features/feed/domain/entities/bookmark_item.dart';
import 'package:qalam_mobile/features/feed/domain/repositories/feed_repository.dart';
import 'package:qalam_mobile/features/feed/domain/value_objects/feed_query.dart';
import 'package:qalam_mobile/shared/api/api_envelope.dart';
import 'package:qalam_mobile/shared/discovery/domain/discovery_repository.dart';
import 'package:qalam_mobile/shared/domain/entities/piece_summary.dart';
import 'package:qalam_mobile/shared/domain/entities/trend_item.dart';
import 'package:qalam_mobile/shared/domain/entities/writer_summary.dart';
import 'package:qalam_mobile/shared/domain/enums.dart';
import 'package:qalam_mobile/shared/pagination/cached_page.dart';

CachedPage<T> _fakePage<T>(List<T> items, {bool isStale = false}) =>
    CachedPage<T>(
      page: CursorPage<T>(items: items, meta: const CursorMeta()),
      isStale: isStale,
    );

class FakeFeedRepository implements FeedRepository {
  FakeFeedRepository({
    this.pieces = const <PieceSummary>[],
    this.bookmarkItems = const <BookmarkItem>[],
    this.isStale = false,
  });

  final List<PieceSummary> pieces;
  final List<BookmarkItem> bookmarkItems;
  final bool isStale;

  @override
  Future<Result<CachedPage<PieceSummary>>> pieceFeed(
    FeedTab tab, {
    FeedQuery query = FeedQuery.none,
    String? cursor,
  }) async => Ok<CachedPage<PieceSummary>>(_fakePage(pieces, isStale: isStale));

  @override
  Future<Result<CachedPage<BookmarkItem>>> bookmarks({String? cursor}) async =>
      Ok<CachedPage<BookmarkItem>>(_fakePage(bookmarkItems, isStale: isStale));
}

class FakeDiscoveryRepository implements DiscoveryRepository {
  FakeDiscoveryRepository({
    this.pieces = const <PieceSummary>[],
    this.writers = const <WriterSummary>[],
    this.tags = const <TrendingTag>[],
    this.genres = const <TrendingGenre>[],
    this.languages = const <TrendingLanguage>[],
    this.isStale = false,
  });

  final List<PieceSummary> pieces;
  final List<WriterSummary> writers;
  final List<TrendingTag> tags;
  final List<TrendingGenre> genres;
  final List<TrendingLanguage> languages;
  final bool isStale;

  @override
  Future<Result<CachedPage<PieceSummary>>> discoverPieces(
    DiscoverPieceKind kind, {
    String? cursor,
  }) async => Ok<CachedPage<PieceSummary>>(_fakePage(pieces, isStale: isStale));

  @override
  Future<Result<CachedPage<WriterSummary>>> discoverWriters(
    WriterKind kind, {
    String? cursor,
  }) async =>
      Ok<CachedPage<WriterSummary>>(_fakePage(writers, isStale: isStale));

  @override
  Future<Result<CachedPage<TrendingTag>>> trendingTags({String? cursor}) async =>
      Ok<CachedPage<TrendingTag>>(_fakePage(tags, isStale: isStale));

  @override
  Future<Result<CachedPage<TrendingGenre>>> trendingGenres({
    String? cursor,
  }) async => Ok<CachedPage<TrendingGenre>>(_fakePage(genres, isStale: isStale));

  @override
  Future<Result<CachedPage<TrendingLanguage>>> trendingLanguages({
    String? cursor,
  }) async =>
      Ok<CachedPage<TrendingLanguage>>(_fakePage(languages, isStale: isStale));
}
