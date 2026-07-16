/// Feed remote data source (docs/40 §17.1) — the only place the feed feature
/// touches the wire. Each method reads one cursor page via [ApiClient.getPage],
/// which reads `meta.pagination` and unwraps the envelope. Knows nothing about
/// caching or `Failure`; returns [CursorPage]s of entities or throws
/// [ApiException] for the repository to translate. The shared read-model mappers
/// (piece summary) come from `shared/data/entity_mappers.dart` via feed_mappers.
library;

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_paths.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../../shared/api/api_envelope.dart';
import '../../../../shared/domain/entities/piece_summary.dart';
import '../../domain/entities/bookmark_item.dart';
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
