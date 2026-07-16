/// The follow-graph read boundary (docs/40 §follows, E5) — a user's followers and
/// following (cursor-paginated, privacy-gated server-side) and the signed-in
/// user's incoming pending requests with accept/reject. The follow / unfollow
/// ACTION itself lives on [EngagementRepository] (keyed on the target user id), so
/// there is one follow-mutation path. Returns domain [Result]s.
library;

import '../../../core/utils/result.dart';
import '../../../core/utils/typedefs.dart';
import '../../pagination/cached_page.dart';
import 'entities/follow_user.dart';

abstract interface class FollowRepository {
  Future<Result<CachedPage<FollowUser>>> followers(
    String username, {
    String? cursor,
  });

  Future<Result<CachedPage<FollowUser>>> following(
    String username, {
    String? cursor,
  });

  Future<Result<CachedPage<FollowRequest>>> requests({String? cursor});

  Future<Result<Unit>> acceptRequest(String followId);

  Future<Result<Unit>> rejectRequest(String followId);
}
