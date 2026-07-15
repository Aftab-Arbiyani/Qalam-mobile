/// Piece remote data source (docs/40 §17.1) — reads for the reading surface and
/// the fire-and-forget analytics beacons. The only place the reading feature reads
/// the wire. Returns entities or throws [ApiException]; the repository translates.
///
/// Beacons (`view`/`read`) are best-effort (docs/40 §30.1): they never block the
/// UI. The data source just issues them; the repository swallows their failures.
library;

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_paths.dart';
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
