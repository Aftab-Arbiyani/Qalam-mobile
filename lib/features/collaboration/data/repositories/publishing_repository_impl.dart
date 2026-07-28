/// Publishing repository implementation (AF6). Wraps every remote call in
/// [guardResult] (ApiException → Failure) so error translation lives in one place.
library;

import '../../../../core/error/result_guard.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/publication_event.dart';
import '../../domain/entities/review_session.dart';
import '../../domain/entities/story_publication_state.dart';
import '../../domain/entities/story_snapshot.dart';
import '../../domain/repositories/publishing_repository.dart';
import '../datasources/publishing_remote_data_source.dart';

class PublishingRepositoryImpl implements PublishingRepository {
  PublishingRepositoryImpl(this._remote);

  final PublishingRemoteDataSource _remote;

  @override
  Future<Result<StoryPublicationState>> publish({required String storyId}) =>
      guardResult(() => _remote.publish(storyId: storyId));

  @override
  Future<Result<StoryPublicationState>> unpublish({required String storyId}) =>
      guardResult(() => _remote.unpublish(storyId: storyId));

  @override
  Future<Result<StoryPublicationState>> schedule({
    required String storyId,
    required DateTime scheduledAt,
  }) => guardResult(
    () => _remote.schedule(storyId: storyId, scheduledAt: scheduledAt),
  );

  @override
  Future<Result<StoryPublicationState>> changeVisibility({
    required String storyId,
    required String visibility,
  }) => guardResult(
    () => _remote.changeVisibility(storyId: storyId, visibility: visibility),
  );

  @override
  Future<Result<List<PublicationEvent>>> publicationHistory(String storyId) =>
      guardResult(() => _remote.publicationHistory(storyId));

  @override
  Future<Result<ReviewSession?>> review(String storyId) =>
      guardResult(() => _remote.review(storyId));

  @override
  Future<Result<ReviewSession>> requestReview({required String storyId}) =>
      guardResult(() => _remote.requestReview(storyId: storyId));

  @override
  Future<Result<ReviewSession>> approveReview({required String storyId}) =>
      guardResult(() => _remote.approveReview(storyId: storyId));

  @override
  Future<Result<ReviewSession>> requestChanges({
    required String storyId,
    String? notes,
  }) =>
      guardResult(() => _remote.requestChanges(storyId: storyId, notes: notes));

  @override
  Future<Result<List<StorySnapshot>>> snapshots(String storyId) =>
      guardResult(() => _remote.snapshots(storyId));

  @override
  Future<Result<StorySnapshot>> createSnapshot({required String storyId}) =>
      guardResult(() => _remote.createSnapshot(storyId: storyId));

  @override
  Future<Result<StorySnapshot>> snapshot(String snapshotId) =>
      guardResult(() => _remote.snapshot(snapshotId));

  @override
  Future<Result<StoryPublicationState>> revertToSnapshot({
    required String storyId,
    required String snapshotId,
  }) => guardResult(
    () => _remote.revertToSnapshot(storyId: storyId, snapshotId: snapshotId),
  );
}
