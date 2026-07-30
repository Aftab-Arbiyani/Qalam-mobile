/// Trust repository implementation (AF6). Wraps every remote call in [guardResult] /
/// [guardUnit] (ApiException → Failure) so error translation lives in one place.
library;

import '../../../../core/error/result_guard.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/block_entry.dart';
import '../../domain/entities/trust_summary.dart';
import '../../domain/repositories/trust_repository.dart';
import '../datasources/trust_remote_data_source.dart';

class TrustRepositoryImpl implements TrustRepository {
  TrustRepositoryImpl(this._remote);

  final TrustRemoteDataSource _remote;

  @override
  Future<Result<TrustSummary>> myTrust() => guardResult(_remote.myTrust);

  @override
  Future<Result<List<BlockEntry>>> myBlocks() => guardResult(_remote.myBlocks);

  @override
  Future<Result<Unit>> block(String userId) =>
      guardUnit(() => _remote.block(userId));

  @override
  Future<Result<Unit>> unblock(String userId) =>
      guardUnit(() => _remote.unblock(userId));

  @override
  Future<Result<Unit>> mute(String userId) =>
      guardUnit(() => _remote.mute(userId));

  @override
  Future<Result<Unit>> unmute(String userId) =>
      guardUnit(() => _remote.unmute(userId));
}
