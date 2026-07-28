/// Piece remote data source (docs/40 §17.1) — reads for the reading surface and
/// the fire-and-forget analytics beacons. The only place the reading feature reads
/// the wire. Returns entities or throws [ApiException]; the repository translates.
///
/// Beacons (`view`/`read`) are best-effort (docs/40 §30.1): they never block the
/// UI. The data source just issues them; the repository swallows their failures.
library;

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_paths.dart';
import '../../../../shared/api/api_envelope.dart';
import '../../../../shared/data/entity_mappers.dart';
import '../../../../shared/domain/entities/piece_summary.dart';
import '../../../../shared/domain/entities/taxonomy.dart';
import '../../../../shared/domain/enums.dart';
import '../../domain/entities/piece_detail.dart';
import '../../domain/entities/piece_engagement.dart';
import '../../domain/entities/writer_profile.dart';
import '../mappers/piece_mappers.dart';

class PieceRemoteDataSource {
  PieceRemoteDataSource(this._api);

  final ApiClient _api;

  Future<PieceDetail> getPiece(String id) => _api.get<PieceDetail>(
    ApiPaths.pieceById(id),
    decode: pieceDetailFromJson,
  );

  Future<PieceEngagement> getEngagement(String id) => _api.get<PieceEngagement>(
    ApiPaths.pieceEngagement(id),
    decode: pieceEngagementFromJson,
  );

  Future<WriterProfile> getWriterProfile(String username) =>
      _api.get<WriterProfile>(
        ApiPaths.userByUsername(username),
        decode: writerProfileFromJson,
      );

  /// "More like this" — `GET /search/pieces` filtered to one tag (docs/48 §3.1).
  /// The frozen contract requires a non-empty `q`, so the tag's NAME is the query
  /// and its SLUG is the filter: FTS matches tags, so the two agree rather than
  /// fight. Only the page's items matter here — the section never paginates.
  Future<List<PieceSummary>> getRelatedPieces(TagRef tag, {int limit = 5}) =>
      _api
          .getPage<PieceSummary>(
            ApiPaths.searchPieces,
            query: <String, dynamic>{
              'q': tag.name,
              'tag': tag.slug,
              'sort': SearchSort.trending.wire,
              'limit': limit,
            },
            decodeItem: pieceSummaryFromJson,
          )
          .then((CursorPage<PieceSummary> page) => page.items);

  /// Beacon: the reader opened the piece (server dedups per viewer/day).
  Future<void> recordView(String id, {String? sessionId}) => _api.postVoid(
    ApiPaths.analyticsView(id),
    body: sessionId == null ? null : <String, Object?>{'sessionId': sessionId},
  );

  /// Beacon: a read session ended (server applies the ≥30s AND ≥50% rule).
  Future<void> recordRead(
    String id, {
    required int durationSeconds,
    required int completionPct,
    String? sessionId,
  }) => _api.postVoid(
    ApiPaths.analyticsRead(id),
    body: <String, Object?>{
      'durationSeconds': durationSeconds,
      'completionPct': completionPct,
      'sessionId': ?sessionId,
    },
  );
}
