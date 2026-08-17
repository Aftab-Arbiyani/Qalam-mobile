/// Follow-graph remote data source (docs/40 §17.1) — followers/following/requests
/// lists (cursor pages) and accept/reject (PATCH). The only place these touch the
/// wire.
library;

import '../../../core/network/api_client.dart';
import '../../../core/network/api_paths.dart';
import '../../../core/utils/typedefs.dart';
import '../../api/api_envelope.dart';
import '../domain/entities/follow_user.dart';
import 'mappers/social_mappers.dart';

class FollowRemoteDataSource {
  FollowRemoteDataSource(this._api);

  final ApiClient _api;

  static const int _limit = 20;

  Future<CursorPage<FollowUser>> followers(String username, {String? cursor}) =>
      _api.getPage<FollowUser>(
        ApiPaths.userFollowers(username),
        query: _page(cursor),
        decodeItem: followUserFromJson,
      );

  Future<CursorPage<FollowUser>> following(String username, {String? cursor}) =>
      _api.getPage<FollowUser>(
        ApiPaths.userFollowing(username),
        query: _page(cursor),
        decodeItem: followUserFromJson,
      );

  Future<CursorPage<FollowRequest>> requests({String? cursor}) =>
      _api.getPage<FollowRequest>(
        ApiPaths.meFollowRequests,
        query: _page(cursor),
        decodeItem: followRequestFromJson,
      );

  Future<void> acceptRequest(String followId) => _api.patch<void>(
    ApiPaths.followRequestAccept(followId),
    decode: (Json _) {},
  );

  Future<void> rejectRequest(String followId) => _api.patch<void>(
    ApiPaths.followRequestReject(followId),
    decode: (Json _) {},
  );

  Json _page(String? cursor) => <String, dynamic>{
    'cursor': ?cursor,
    'limit': _limit,
  };
}
