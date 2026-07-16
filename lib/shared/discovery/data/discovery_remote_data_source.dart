/// Discovery remote data source (docs/40 §17.1) — the only place the discovery
/// module touches the wire. Each method reads one cursor page from a `/discover/*`
/// endpoint via [ApiClient.getPage]. Reuses the shared read-model mappers; knows
/// nothing about caching or `Failure`.
library;

import '../../../core/network/api_client.dart';
import '../../../core/network/api_paths.dart';
import '../../../core/utils/typedefs.dart';
import '../../api/api_envelope.dart';
import '../../data/entity_mappers.dart';
import '../../domain/entities/piece_summary.dart';
import '../../domain/entities/trend_item.dart';
import '../../domain/entities/writer_summary.dart';
import '../../domain/enums.dart';

class DiscoveryRemoteDataSource {
  DiscoveryRemoteDataSource(this._api);

  final ApiClient _api;

  static const int _limit = 20;

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

  Json _page(String? cursor, [Json extra = const <String, dynamic>{}]) =>
      <String, dynamic>{...extra, 'cursor': ?cursor, 'limit': _limit};
}
