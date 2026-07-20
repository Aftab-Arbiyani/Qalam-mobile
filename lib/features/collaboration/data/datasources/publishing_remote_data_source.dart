/// Publishing remote data source (AF6) — the only place the publish-workflow
/// endpoints (`/stories/{id}/{publish,unpublish,schedule,visibility,review,snapshots}`,
/// `/snapshots/{id}`) + `ApiClient` are touched. Maps envelope payloads to typed
/// entities; the server owns publication state + review transitions.
library;

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_paths.dart';
import '../../domain/entities/publication_event.dart';
import '../../domain/entities/review_session.dart';
import '../../domain/entities/story_snapshot.dart';

class PublishingRemoteDataSource {
  const PublishingRemoteDataSource(this._api);

  final ApiClient _api;

  // ── Publication ──────────────────────────────────────────────────────────────
  Future<PublicationEvent> publish({
    required String storyId,
    String? visibility,
    String? note,
  }) => _api.post(
    ApiPaths.storyPublish(storyId),
    body: <String, Object?>{'visibility': ?visibility, 'note': ?note},
    decode: PublicationEvent.fromJson,
  );

  Future<PublicationEvent> unpublish({required String storyId, String? note}) =>
      _api.post(
        ApiPaths.storyUnpublish(storyId),
        body: <String, Object?>{'note': ?note},
        decode: PublicationEvent.fromJson,
      );

  Future<PublicationEvent> schedule({
    required String storyId,
    required DateTime scheduledFor,
    String? visibility,
  }) => _api.post(
    ApiPaths.storySchedule(storyId),
    body: <String, Object?>{
      'scheduledFor': scheduledFor.toUtc().toIso8601String(),
      'visibility': ?visibility,
    },
    decode: PublicationEvent.fromJson,
  );

  Future<PublicationEvent> changeVisibility({
    required String storyId,
    required String visibility,
  }) => _api.patch(
    ApiPaths.storyVisibility(storyId),
    body: <String, Object?>{'visibility': visibility},
    decode: PublicationEvent.fromJson,
  );

  Future<List<PublicationEvent>> publicationHistory(
    String storyId, {
    CancelToken? cancelToken,
  }) => _api.getList(
    ApiPaths.storyPublicationHistory(storyId),
    decodeItem: PublicationEvent.fromJson,
    cancelToken: cancelToken,
  );

  // ── Review workflow ──────────────────────────────────────────────────────────
  Future<ReviewSession> review(String storyId, {CancelToken? cancelToken}) =>
      _api.get(
        ApiPaths.storyReview(storyId),
        decode: ReviewSession.fromJson,
        cancelToken: cancelToken,
      );

  Future<ReviewSession> requestReview({
    required String storyId,
    String? reviewerId,
    String? note,
  }) => _api.post(
    ApiPaths.storyReview(storyId),
    body: <String, Object?>{'reviewerId': ?reviewerId, 'note': ?note},
    decode: ReviewSession.fromJson,
  );

  Future<ReviewSession> approveReview({
    required String storyId,
    String? note,
  }) => _api.post(
    ApiPaths.storyReviewApprove(storyId),
    body: <String, Object?>{'note': ?note},
    decode: ReviewSession.fromJson,
  );

  Future<ReviewSession> requestChanges({
    required String storyId,
    String? note,
  }) => _api.post(
    ApiPaths.storyReviewChanges(storyId),
    body: <String, Object?>{'note': ?note},
    decode: ReviewSession.fromJson,
  );

  // ── Snapshots ──────────────────────────────────────────────────────────────────
  Future<List<StorySnapshot>> snapshots(
    String storyId, {
    CancelToken? cancelToken,
  }) => _api.getList(
    ApiPaths.storySnapshots(storyId),
    decodeItem: StorySnapshot.fromJson,
    cancelToken: cancelToken,
  );

  Future<StorySnapshot> createSnapshot({
    required String storyId,
    String? label,
  }) => _api.post(
    ApiPaths.storySnapshots(storyId),
    body: <String, Object?>{'label': ?label},
    decode: StorySnapshot.fromJson,
  );

  Future<StorySnapshot> snapshot(
    String snapshotId, {
    CancelToken? cancelToken,
  }) => _api.get(
    ApiPaths.snapshot(snapshotId),
    decode: StorySnapshot.fromJson,
    cancelToken: cancelToken,
  );

  Future<StorySnapshot> revertToSnapshot({
    required String storyId,
    required String snapshotId,
  }) => _api.post(
    ApiPaths.storySnapshotRevert(storyId, snapshotId),
    decode: StorySnapshot.fromJson,
  );
}
