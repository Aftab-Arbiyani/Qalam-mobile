/// Engagement mutation data source (docs/40 §17.1) — like/bookmark/share on a
/// piece, follow on a writer, and report any entity. The only place these
/// mutations touch the wire. Returns the server's authoritative result (new
/// count / state) or throws [ApiException]. No retries (docs/40 §13.5).
library;

import '../../../core/network/api_client.dart';
import '../../../core/network/api_paths.dart';
import '../../../core/utils/json_read.dart';
import '../../../core/utils/typedefs.dart';
import '../../domain/enums.dart';
import '../domain/engagement_repository.dart' show ClapOutcome, LikeOutcome;

class EngagementRemoteDataSource {
  EngagementRemoteDataSource(this._api);

  final ApiClient _api;

  Future<LikeOutcome> like(String pieceId) => _api.post<LikeOutcome>(
    ApiPaths.pieceLikes(pieceId),
    decode: (Json j) =>
        (liked: asBool(j['liked'], true), totalLikes: asInt(j['totalLikes'])),
  );

  Future<void> unlike(String pieceId) =>
      _api.delete(ApiPaths.pieceLikes(pieceId));

  /// `POST /pieces/:id/claps { count }` → `ClapResponseDto`.
  Future<ClapOutcome> clap(String pieceId, int count) => _api.post<ClapOutcome>(
    ApiPaths.pieceClaps(pieceId),
    body: <String, Object?>{'count': count},
    decode: (Json j) => (
      viewerClaps: asInt(j['viewerClaps']),
      totalClaps: asInt(j['totalClaps']),
    ),
  );

  Future<void> unclap(String pieceId) =>
      _api.delete(ApiPaths.pieceClaps(pieceId));

  Future<bool> bookmark(String pieceId) => _api.post<bool>(
    ApiPaths.pieceBookmarks(pieceId),
    decode: (Json j) => asBool(j['bookmarked'], true),
  );

  Future<void> unbookmark(String pieceId) =>
      _api.delete(ApiPaths.pieceBookmarks(pieceId));

  Future<int> share(String pieceId, ShareChannel channel) => _api.post<int>(
    ApiPaths.pieceShares(pieceId),
    body: <String, Object?>{'channel': channel.wire},
    decode: (Json j) => asInt(j['totalShares']),
  );

  Future<FollowStatus> follow(String userId) => _api.post<FollowStatus>(
    ApiPaths.userFollow(userId),
    decode: (Json j) => FollowStatus.fromWire(asStringOrNull(j['status'])),
  );

  Future<void> unfollow(String userId) =>
      _api.delete(ApiPaths.userFollow(userId));

  Future<void> report({
    required ReportEntityType entityType,
    required String entityId,
    required ReportReason reason,
    String? description,
  }) => _api.postVoid(
    ApiPaths.reports,
    body: <String, Object?>{
      'entityType': entityType.wire,
      'entityId': entityId,
      'reason': reason.wire,
      if (description != null && description.trim().isNotEmpty)
        'description': description.trim(),
    },
  );
}
