/// Engagement-mutation repository (docs/40 §16, §21.4). Thin over the remote data
/// source: each call is guarded, translating a transport [ApiException] to a domain
/// [Failure] (and any other error to `UnexpectedFailure`). Mutations are never
/// retried (docs/40 §13.5); the presentation owns optimistic apply/rollback.
library;

import '../../../../core/error/api_exception.dart';
import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../../shared/domain/enums.dart';
import '../../../../shared/domain/error_codes.dart';
import '../../domain/repositories/engagement_repository.dart';
import '../datasources/engagement_remote_data_source.dart';

class EngagementRepositoryImpl implements EngagementRepository {
  EngagementRepositoryImpl(this._remote);

  final EngagementRemoteDataSource _remote;

  @override
  Future<Result<LikeOutcome>> like(String pieceId) =>
      _guard(() => _remote.like(pieceId));

  @override
  Future<Result<Unit>> unlike(String pieceId) =>
      _guardUnit(() => _remote.unlike(pieceId));

  @override
  Future<Result<bool>> bookmark(String pieceId) =>
      _guard(() => _remote.bookmark(pieceId));

  @override
  Future<Result<Unit>> unbookmark(String pieceId) =>
      _guardUnit(() => _remote.unbookmark(pieceId));

  @override
  Future<Result<int>> share(String pieceId, ShareChannel channel) =>
      _guard(() => _remote.share(pieceId, channel));

  @override
  Future<Result<FollowStatus>> follow(String userId) =>
      _guard(() => _remote.follow(userId));

  @override
  Future<Result<Unit>> unfollow(String userId) =>
      _guardUnit(() => _remote.unfollow(userId));

  @override
  Future<Result<Unit>> report({
    required String pieceId,
    required ReportReason reason,
    String? description,
  }) => _guardUnit(
    () => _remote.report(
      pieceId: pieceId,
      reason: reason,
      description: description,
    ),
  );

  Future<Result<T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Ok<T>(await run());
    } on ApiException catch (e) {
      return Err<T>(mapApiExceptionToFailure(e));
    } on Object catch (e) {
      return Err<T>(
        Failure.unexpected(
          code: ErrorCodes.apiUnexpected,
          message: e.toString(),
        ),
      );
    }
  }

  Future<Result<Unit>> _guardUnit(Future<void> Function() run) =>
      _guard<Unit>(() async {
        await run();
        return unit;
      });
}
