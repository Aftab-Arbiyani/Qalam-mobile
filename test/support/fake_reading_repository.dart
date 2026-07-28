/// Canned reading/engagement repositories for reader tests — no network.
library;

import 'package:qalam_mobile/core/error/failure.dart';
import 'package:qalam_mobile/core/utils/result.dart';
import 'package:qalam_mobile/core/utils/typedefs.dart';
import 'package:qalam_mobile/features/reading/domain/entities/piece_detail.dart';
import 'package:qalam_mobile/features/reading/domain/entities/piece_engagement.dart';
import 'package:qalam_mobile/features/reading/domain/entities/writer_profile.dart';
import 'package:qalam_mobile/features/reading/domain/repositories/reading_repository.dart';
import 'package:qalam_mobile/shared/domain/entities/piece_summary.dart';
import 'package:qalam_mobile/shared/domain/entities/taxonomy.dart';
import 'package:qalam_mobile/shared/domain/enums.dart';
import 'package:qalam_mobile/shared/social/domain/engagement_repository.dart';

class FakeReadingRepository implements ReadingRepository {
  FakeReadingRepository({
    this.piece,
    this.engagement = PieceEngagement.empty,
    this.profile,
    this.related = const <PieceSummary>[],
    this.relatedFails = false,
  });

  PieceDetail? piece;
  PieceEngagement engagement;
  WriterProfile? profile;

  /// Canned "More like this" results, and whether that load fails.
  List<PieceSummary> related;
  bool relatedFails;

  /// The tag + limit the last related-pieces call asked for.
  TagRef? lastRelatedTag;
  int? lastRelatedLimit;

  int viewBeacons = 0;
  int readBeacons = 0;
  int lastReadDuration = 0;
  int lastReadCompletion = 0;

  @override
  Future<Result<CachedDetail>> getPiece(String id) async {
    final PieceDetail? p = piece;
    if (p == null) {
      return const Err<CachedDetail>(NotFoundFailure(code: 'PIECE_NOT_FOUND'));
    }
    return Ok<CachedDetail>((piece: p, isStale: false));
  }

  @override
  Future<Result<PieceEngagement>> getEngagement(String id) async =>
      Ok<PieceEngagement>(engagement);

  @override
  Future<Result<WriterProfile>> getWriterProfile(String username) async {
    final WriterProfile? p = profile;
    if (p == null) {
      return const Err<WriterProfile>(NotFoundFailure(code: 'USER_NOT_FOUND'));
    }
    return Ok<WriterProfile>(p);
  }

  @override
  Future<Result<List<PieceSummary>>> getRelatedPieces(
    TagRef tag, {
    int limit = 5,
  }) async {
    lastRelatedTag = tag;
    lastRelatedLimit = limit;
    if (relatedFails) {
      return const Err<List<PieceSummary>>(
        NetworkFailure(code: 'API_NETWORK_ERROR'),
      );
    }
    return Ok<List<PieceSummary>>(related);
  }

  @override
  Future<void> recordView(String id, {String? sessionId}) async =>
      viewBeacons++;

  @override
  Future<void> recordRead(
    String id, {
    required int durationSeconds,
    required int completionPct,
    String? sessionId,
  }) async {
    readBeacons++;
    lastReadDuration = durationSeconds;
    lastReadCompletion = completionPct;
  }
}

class FakeEngagementRepository implements EngagementRepository {
  FakeEngagementRepository({this.likeTotal = 11, this.shareTotal = 3});

  int likeTotal;
  int shareTotal;

  /// When true, the next mutation returns a failure (then resets).
  bool nextFails = false;

  Result<T> _result<T>(T value) {
    if (nextFails) {
      nextFails = false;
      return Err<T>(const NetworkFailure(code: 'API_NETWORK_ERROR'));
    }
    return Ok<T>(value);
  }

  @override
  Future<Result<LikeOutcome>> like(String pieceId) async =>
      _result<LikeOutcome>((liked: true, totalLikes: likeTotal));

  @override
  Future<Result<Unit>> unlike(String pieceId) async => _result<Unit>(unit);

  @override
  Future<Result<bool>> bookmark(String pieceId) async => _result<bool>(true);

  @override
  Future<Result<Unit>> unbookmark(String pieceId) async => _result<Unit>(unit);

  @override
  Future<Result<int>> share(String pieceId, ShareChannel channel) async =>
      _result<int>(shareTotal);

  @override
  Future<Result<FollowStatus>> follow(String userId) async =>
      _result<FollowStatus>(FollowStatus.accepted);

  @override
  Future<Result<Unit>> unfollow(String userId) async => _result<Unit>(unit);

  @override
  Future<Result<Unit>> report({
    required ReportEntityType entityType,
    required String entityId,
    required ReportReason reason,
    String? description,
  }) async => _result<Unit>(unit);
}
