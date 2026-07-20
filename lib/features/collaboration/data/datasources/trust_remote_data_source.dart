/// Trust remote data source (AF6) — the only place the trust/safety endpoints
/// (`/me/trust`, `/me/blocks`, `/users/{id}/{block,mute}`) + `ApiClient` are touched.
/// Maps envelope payloads to typed entities; the server owns trust scoring +
/// enforcement.
library;

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_paths.dart';
import '../../domain/entities/block_entry.dart';
import '../../domain/entities/trust_summary.dart';

class TrustRemoteDataSource {
  const TrustRemoteDataSource(this._api);

  final ApiClient _api;

  Future<TrustSummary> myTrust({CancelToken? cancelToken}) => _api.get(
    ApiPaths.meTrust,
    decode: TrustSummary.fromJson,
    cancelToken: cancelToken,
  );

  Future<List<BlockEntry>> myBlocks({CancelToken? cancelToken}) => _api.getList(
    ApiPaths.meBlocks,
    decodeItem: BlockEntry.fromJson,
    cancelToken: cancelToken,
  );

  Future<void> block(String userId) =>
      _api.postVoid(ApiPaths.userBlock(userId));

  Future<void> unblock(String userId) =>
      _api.delete(ApiPaths.userBlock(userId));

  Future<void> mute(String userId) => _api.postVoid(ApiPaths.userMute(userId));

  Future<void> unmute(String userId) => _api.delete(ApiPaths.userMute(userId));
}
