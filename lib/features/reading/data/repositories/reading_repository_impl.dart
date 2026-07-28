/// Reading-reads repository (docs/40 §16, §23) — cache-then-network for the piece,
/// engagement, and profile, with offline fallback to the cached copy; best-effort
/// analytics beacons. Translates every transport error to a domain [Failure]; no
/// DTO/`DioException`/HTTP status escapes upward.
library;

import '../../../../core/error/api_exception.dart';
import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/storage/cache_policy.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/domain/entities/piece_summary.dart';
import '../../../../shared/domain/entities/taxonomy.dart';
import '../../../../shared/domain/error_codes.dart';
import '../../domain/entities/piece_detail.dart';
import '../../domain/entities/piece_engagement.dart';
import '../../domain/entities/writer_profile.dart';
import '../../domain/repositories/reading_repository.dart';
import '../datasources/piece_local_data_source.dart';
import '../datasources/piece_remote_data_source.dart';

class ReadingRepositoryImpl implements ReadingRepository {
  ReadingRepositoryImpl(this._remote, this._local);

  final PieceRemoteDataSource _remote;
  final PieceLocalDataSource _local;

  @override
  Future<Result<CachedDetail>> getPiece(String id) async {
    final String key = PieceLocalDataSource.pieceKey(id);
    try {
      final PieceDetail piece = await _remote.getPiece(id);
      await _local.write<PieceDetail>(
        key,
        piece,
        (PieceDetail p) => p.toJson(),
        tier: CacheTier.content,
      );
      return Ok<CachedDetail>((piece: piece, isStale: false));
    } on ApiException catch (e) {
      final CachedObject<PieceDetail>? cached = await _local.read<PieceDetail>(
        key,
        PieceDetail.fromJson,
      );
      // Serve a cached copy offline — but never mask a real 404 with stale data.
      if (cached != null && e.isTransport) {
        return Ok<CachedDetail>((piece: cached.value, isStale: true));
      }
      return Err<CachedDetail>(mapApiExceptionToFailure(e));
    } on Object catch (e) {
      return Err<CachedDetail>(
        Failure.unexpected(
          code: ErrorCodes.apiUnexpected,
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<PieceEngagement>> getEngagement(String id) async {
    final String key = PieceLocalDataSource.engagementKey(id);
    try {
      final PieceEngagement engagement = await _remote.getEngagement(id);
      await _local.write<PieceEngagement>(
        key,
        engagement,
        (PieceEngagement e) => e.toJson(),
        tier: CacheTier.live,
      );
      return Ok<PieceEngagement>(engagement);
    } on ApiException catch (e) {
      final CachedObject<PieceEngagement>? cached = await _local
          .read<PieceEngagement>(key, PieceEngagement.fromJson);
      if (cached != null) return Ok<PieceEngagement>(cached.value);
      return Err<PieceEngagement>(mapApiExceptionToFailure(e));
    } on Object catch (e) {
      return Err<PieceEngagement>(
        Failure.unexpected(
          code: ErrorCodes.apiUnexpected,
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<WriterProfile>> getWriterProfile(String username) async {
    final String key = PieceLocalDataSource.profileKey(username);
    try {
      final WriterProfile profile = await _remote.getWriterProfile(username);
      await _local.write<WriterProfile>(
        key,
        profile,
        (WriterProfile p) => p.toJson(),
        tier: CacheTier.identity,
      );
      return Ok<WriterProfile>(profile);
    } on ApiException catch (e) {
      final CachedObject<WriterProfile>? cached = await _local
          .read<WriterProfile>(key, WriterProfile.fromJson);
      if (cached != null && e.isTransport) {
        return Ok<WriterProfile>(cached.value);
      }
      return Err<WriterProfile>(mapApiExceptionToFailure(e));
    } on Object catch (e) {
      return Err<WriterProfile>(
        Failure.unexpected(
          code: ErrorCodes.apiUnexpected,
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<List<PieceSummary>>> getRelatedPieces(
    TagRef tag, {
    int limit = 5,
  }) async {
    // Deliberately NOT cached — the documented exception in docs/40 §25.4: a
    // cached suggestion offline links to a piece that is not cached, and the
    // section is non-critical, so showing nothing is a correct outcome.
    try {
      return Ok<List<PieceSummary>>(
        await _remote.getRelatedPieces(tag, limit: limit),
      );
    } on ApiException catch (e) {
      return Err<List<PieceSummary>>(mapApiExceptionToFailure(e));
    } on Object catch (e) {
      return Err<List<PieceSummary>>(
        Failure.unexpected(
          code: ErrorCodes.apiUnexpected,
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> recordView(String id, {String? sessionId}) async {
    try {
      await _remote.recordView(id, sessionId: sessionId);
    } on Object {
      // Fire-and-forget (docs/40 §30.1) — a lost beacon is acceptable.
    }
  }

  @override
  Future<void> recordRead(
    String id, {
    required int durationSeconds,
    required int completionPct,
    String? sessionId,
  }) async {
    try {
      await _remote.recordRead(
        id,
        durationSeconds: durationSeconds,
        completionPct: completionPct,
        sessionId: sessionId,
      );
    } on Object {
      // Fire-and-forget (docs/40 §30.1).
    }
  }
}
