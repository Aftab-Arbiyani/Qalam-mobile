/// A public profile resolved from a bare user **id** (B3, `platfrom/docs/45` §4).
///
/// Collaboration, retrieval and publishing DTOs carry ids and no names, so every
/// surface that names a person from one of them — comment author, suggestion
/// author, reviewer, blocked person, invitee, presence entry — had nothing to
/// resolve *from* and showed a truncated UUID to real users. This is the one
/// place the app turns an id into a profile; `ActorName` / `ActorAvatar` render
/// it, and no screen calls the wire itself.
///
/// **Cost.** `keepAlive` + a family key means one request per DISTINCT user for
/// the life of the session, not one per row: a 20-comment thread between three
/// people is three requests, and re-entering the screen is zero.
///
/// **Failure is not an error state here.** A deleted account, a lookup failure,
/// or an offline start all resolve to `null`, and the callers fall back to the
/// short id — an identity chip must never block a list or show a red state.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../providers/profile_providers.dart';

part 'actor_profile_controller.g.dart';

@Riverpod(keepAlive: true)
Future<Profile?> actorProfile(Ref ref, String userId) async {
  if (userId.isEmpty) return null;
  final Result<CachedProfile> result = await ref
      .read(profileRepositoryProvider)
      .publicProfileById(userId);
  return result.fold(
    (CachedProfile cached) => cached.profile,
    (_) => null, // Fall back to the short id; never surface a failure here.
  );
}
