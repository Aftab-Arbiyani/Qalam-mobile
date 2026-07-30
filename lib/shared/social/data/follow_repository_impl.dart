/// Follow-graph repository (docs/40 §16, §23). Followers/following delegate to the
/// shared [loadCachedPage] engine (page-1 cached for offline + stale fallback);
/// pending requests are NOT cached (they must stay fresh). Accept/reject are
/// guarded mutations.
library;

import '../../../core/error/api_exception.dart';
import '../../../core/error/error_mapper.dart';
import '../../../core/error/failure.dart';
import '../../../core/storage/cache_policy.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/typedefs.dart';
import '../../data/cache_list_data_source.dart';
import '../../data/cached_page_loader.dart';
import '../../domain/error_codes.dart';
import '../../pagination/cached_page.dart';
import '../domain/entities/follow_user.dart';
import '../domain/follow_repository.dart';
import 'follow_remote_data_source.dart';

class FollowRepositoryImpl implements FollowRepository {
  FollowRepositoryImpl(this._remote, this._cache);

  final FollowRemoteDataSource _remote;
  final CacheListDataSource _cache;

  @override
  Future<Result<CachedPage<FollowUser>>> followers(
    String username, {
    String? cursor,
  }) => loadCachedPage<FollowUser>(
    cache: _cache,
    cacheKey: 'follow:followers:$username',
    cursor: cursor,
    fetch: (String? c) => _remote.followers(username, cursor: c),
    toJson: (FollowUser x) => x.toJson(),
    fromJson: FollowUser.fromJson,
    tier: CacheTier.content,
  );

  @override
  Future<Result<CachedPage<FollowUser>>> following(
    String username, {
    String? cursor,
  }) => loadCachedPage<FollowUser>(
    cache: _cache,
    cacheKey: 'follow:following:$username',
    cursor: cursor,
    fetch: (String? c) => _remote.following(username, cursor: c),
    toJson: (FollowUser x) => x.toJson(),
    fromJson: FollowUser.fromJson,
    tier: CacheTier.content,
  );

  @override
  Future<Result<CachedPage<FollowRequest>>> requests({String? cursor}) =>
      loadCachedPage<FollowRequest>(
        cache: _cache,
        cacheKey: null, // pending requests must stay fresh — never cached
        cursor: cursor,
        fetch: (String? c) => _remote.requests(cursor: c),
        toJson: (FollowRequest x) => x.toJson(),
        fromJson: FollowRequest.fromJson,
        tier: CacheTier.live,
      );

  @override
  Future<Result<Unit>> acceptRequest(String followId) =>
      _guardUnit(() => _remote.acceptRequest(followId));

  @override
  Future<Result<Unit>> rejectRequest(String followId) =>
      _guardUnit(() => _remote.rejectRequest(followId));

  Future<Result<Unit>> _guardUnit(Future<void> Function() run) async {
    try {
      await run();
      return const Ok<Unit>(unit);
    } on ApiException catch (e) {
      return Err<Unit>(mapApiExceptionToFailure(e));
    } on Object catch (e) {
      return Err<Unit>(
        Failure.unexpected(
          code: ErrorCodes.apiUnexpected,
          message: e.toString(),
        ),
      );
    }
  }
}
