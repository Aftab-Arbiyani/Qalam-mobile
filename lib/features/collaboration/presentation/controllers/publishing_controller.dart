/// Publishing write-side controller (AF6). Drives the publish workflow (review
/// request / approve / request-changes, publish / unpublish / schedule / visibility,
/// snapshot / revert), reflects a busy/error state via [AsyncValue], and invalidates
/// the review / snapshots / publication-history reads on success. The server owns the
/// state machine — the client only requests transitions the policy engine authorizes.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/publication_event.dart';
import '../../domain/entities/review_session.dart';
import '../../domain/entities/story_snapshot.dart';
import '../../domain/repositories/publishing_repository.dart';
import '../providers/collaboration_providers.dart';

part 'publishing_controller.g.dart';

@riverpod
class PublishingController extends _$PublishingController {
  @override
  Future<void> build() async {}

  PublishingRepository get _repo => ref.read(publishingRepositoryProvider);

  // ── Publication ──────────────────────────────────────────────────────────────
  Future<PublicationEvent?> publish({
    required String storyId,
    String? visibility,
    String? note,
  }) => _run(
    () => _repo.publish(storyId: storyId, visibility: visibility, note: note),
    _refreshPublication,
  );

  Future<PublicationEvent?> unpublish({
    required String storyId,
    String? note,
  }) => _run(
    () => _repo.unpublish(storyId: storyId, note: note),
    _refreshPublication,
  );

  Future<PublicationEvent?> schedule({
    required String storyId,
    required DateTime scheduledFor,
    String? visibility,
  }) => _run(
    () => _repo.schedule(
      storyId: storyId,
      scheduledFor: scheduledFor,
      visibility: visibility,
    ),
    _refreshPublication,
  );

  Future<PublicationEvent?> changeVisibility({
    required String storyId,
    required String visibility,
  }) => _run(
    () => _repo.changeVisibility(storyId: storyId, visibility: visibility),
    _refreshPublication,
  );

  // ── Review workflow ──────────────────────────────────────────────────────────
  Future<ReviewSession?> requestReview({
    required String storyId,
    String? reviewerId,
    String? note,
  }) => _run(
    () => _repo.requestReview(
      storyId: storyId,
      reviewerId: reviewerId,
      note: note,
    ),
    () => ref.invalidate(storyReviewProvider),
  );

  Future<ReviewSession?> approveReview({
    required String storyId,
    String? note,
  }) => _run(
    () => _repo.approveReview(storyId: storyId, note: note),
    _refreshReview,
  );

  Future<ReviewSession?> requestChanges({
    required String storyId,
    String? note,
  }) => _run(
    () => _repo.requestChanges(storyId: storyId, note: note),
    () => ref.invalidate(storyReviewProvider),
  );

  // ── Snapshots ──────────────────────────────────────────────────────────────────
  Future<StorySnapshot?> createSnapshot({
    required String storyId,
    String? label,
  }) => _run(
    () => _repo.createSnapshot(storyId: storyId, label: label),
    () => ref.invalidate(storySnapshotsProvider),
  );

  Future<StorySnapshot?> revertToSnapshot({
    required String storyId,
    required String snapshotId,
  }) => _run(
    () => _repo.revertToSnapshot(storyId: storyId, snapshotId: snapshotId),
    _refreshPublication,
  );

  // ── Internals ────────────────────────────────────────────────────────────────

  Future<T?> _run<T>(
    Future<Result<T>> Function() op,
    void Function() onOk,
  ) async {
    state = const AsyncValue<void>.loading();
    final Result<T> result = await op();
    switch (result) {
      case Ok<T>(:final T value):
        state = const AsyncValue<void>.data(null);
        onOk();
        return value;
      case Err<T>(:final Failure failure):
        state = AsyncValue<void>.error(failure, StackTrace.current);
        return null;
    }
  }

  void _refreshPublication() {
    ref.invalidate(publicationHistoryProvider);
    ref.invalidate(storyReviewProvider);
    ref.invalidate(storySnapshotsProvider);
  }

  void _refreshReview() {
    ref.invalidate(storyReviewProvider);
    ref.invalidate(storyCapabilitiesProvider);
  }
}
