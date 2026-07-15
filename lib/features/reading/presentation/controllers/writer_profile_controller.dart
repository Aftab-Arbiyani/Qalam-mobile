/// The author-card controller (docs/40 §21.4) — loads a writer's profile by
/// username (the only source of the follow-target id + follow relation) and
/// applies OPTIMISTIC follow / unfollow with rollback. Non-critical: a failed load
/// simply hides the rich card (the byline still shows from the piece).
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/domain/enums.dart';
import '../../domain/entities/writer_profile.dart';
import '../../domain/repositories/engagement_repository.dart';
import '../providers/reading_providers.dart';

part 'writer_profile_controller.g.dart';

@riverpod
class WriterProfileController extends _$WriterProfileController {
  @override
  Future<WriterProfile> build(String username) async {
    final result = await ref
        .watch(readingRepositoryProvider)
        .getWriterProfile(username);
    return result.fold(
      (WriterProfile p) => p,
      (Object failure) => throw failure,
    );
  }

  Future<void> toggleFollow() async {
    final WriterProfile? p = state.asData?.value;
    if (p == null || p.isSelf) return;
    final EngagementRepository repo = ref.read(engagementRepositoryProvider);

    if (p.isFollowing || p.hasPendingRequest) {
      // Unfollow / cancel a pending request.
      final WriterProfile optimistic = p.copyWith(
        isFollowing: false,
        hasPendingRequest: false,
        followersCount: _clamp(p.followersCount - (p.isFollowing ? 1 : 0)),
      );
      state = AsyncData<WriterProfile>(optimistic);
      final Result<void> res = await repo.unfollow(p.id);
      if (res.isErr) state = AsyncData<WriterProfile>(p);
    } else {
      // Follow — public accounts accept immediately; private ones go pending.
      state = AsyncData<WriterProfile>(
        p.copyWith(
          isFollowing: !p.isPrivate,
          hasPendingRequest: p.isPrivate,
          followersCount: _clamp(p.followersCount + (p.isPrivate ? 0 : 1)),
        ),
      );
      final Result<FollowStatus> res = await repo.follow(p.id);
      res.fold((FollowStatus status) {
        final bool accepted = status == FollowStatus.accepted;
        state = AsyncData<WriterProfile>(
          p.copyWith(
            isFollowing: accepted,
            hasPendingRequest: !accepted,
            followersCount: _clamp(p.followersCount + (accepted ? 1 : 0)),
          ),
        );
      }, (Failure _) => state = AsyncData<WriterProfile>(p));
    }
  }

  int _clamp(int value) => value < 0 ? 0 : value;
}
