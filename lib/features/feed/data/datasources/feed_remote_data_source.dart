/// Feed remote data source (docs/40 §17.1) — the only place the feed feature
/// touches the wire. Each method reads one cursor page via [ApiClient.getPage],
/// which reads `meta.pagination` and unwraps the envelope. Knows nothing about
/// caching or `Failure`; returns [CursorPage]s of entities or throws
/// [ApiException] for the repository to translate.
library;

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_paths.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../../shared/api/api_envelope.dart';
import '../../../../shared/domain/enums.dart';
import '../../domain/entities/bookmark_item.dart';
import '../../domain/entities/piece_summary.dart';
import '../../domain/entities/trend_item.dart';
import '../../domain/entities/writer_summary.dart';
import '../../domain/value_objects/feed_query.dart';
import '../mappers/feed_mappers.dart';

class FeedRemoteDataSource {
  FeedRemoteDataSource(this._api);

  final ApiClient _api;

  /// Cursor page size — the frozen default (docs/40 §13.7), max 50.
  static const int _limit = 20;

  Future<CursorPage<PieceSummary>> pieceFeed(
    FeedTab tab, {
    FeedQuery query = FeedQuery.none,
    String? cursor,
  }) => _api.getPage<PieceSummary>(
    ApiPaths.feed(tab.wire),
    query: _page(cursor, query.toParams()),
    decodeItem: pieceSummaryFromJson,
  );

  Future<CursorPage<PieceSummary>> discoverPieces(
    DiscoverPieceKind kind, {
    String? cursor,
  }) => _api.getPage<PieceSummary>(
    ApiPaths.discoverPieces,
    query: _page(cursor, <String, dynamic>{'kind': kind.wire}),
    decodeItem: pieceSummaryFromJson,
  );

  Future<CursorPage<WriterSummary>> discoverWriters(
    WriterKind kind, {
    String? cursor,
  }) => _api.getPage<WriterSummary>(
    ApiPaths.discoverWriters,
    query: _page(cursor, <String, dynamic>{'kind': kind.wire}),
    decodeItem: writerSummaryFromJson,
  );

  Future<CursorPage<TrendingTag>> trendingTags({String? cursor}) =>
      _api.getPage<TrendingTag>(
        ApiPaths.discoverTags,
        query: _page(cursor),
        decodeItem: trendingTagFromJson,
      );

  Future<CursorPage<TrendingGenre>> trendingGenres({String? cursor}) =>
      _api.getPage<TrendingGenre>(
        ApiPaths.discoverGenres,
        query: _page(cursor),
        decodeItem: trendingGenreFromJson,
      );

  Future<CursorPage<TrendingLanguage>> trendingLanguages({String? cursor}) =>
      _api.getPage<TrendingLanguage>(
        ApiPaths.discoverLanguages,
        query: _page(cursor),
        decodeItem: trendingLanguageFromJson,
      );

  Future<CursorPage<BookmarkItem>> bookmarks({String? cursor}) =>
      _api.getPage<BookmarkItem>(
        ApiPaths.meBookmarks,
        query: _page(cursor),
        decodeItem: bookmarkItemFromJson,
      );

  /// Compose the paging query: cursor (when present) + limit + any extra params.
  Json _page(String? cursor, [Json extra = const <String, dynamic>{}]) =>
      <String, dynamic>{...extra, 'cursor': ?cursor, 'limit': _limit};
}
