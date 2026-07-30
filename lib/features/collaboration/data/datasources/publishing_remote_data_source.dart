/// Publishing remote data source (AF6) — the only place the publish-workflow
/// endpoints (`/stories/{id}/{publish,unpublish,schedule,visibility,review,snapshots}`,
/// `/snapshots/{id}`) + `ApiClient` are touched. Maps envelope payloads to typed
/// entities; the server owns publication state + review transitions.
///
/// Shapes here are pinned to `publishing.controller.ts` + `publishing-request.dto.ts`
/// + `publishing-response.dto.ts`. Three classes of defect were fixed against them
/// (`docs/56` §2.2): responses decoded as the wrong entity (**P-1**), bodies whose
/// keys no DTO accepts (**P-2**, **P-5**), and bodies sent to handlers that declare
/// no `@Body()` at all and therefore discard them silently (**P-8**).
library;

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_paths.dart';
import '../../domain/entities/publication_event.dart';
import '../../domain/entities/review_session.dart';
import '../../domain/entities/story_publication_state.dart';
import '../../domain/entities/story_snapshot.dart';

class PublishingRemoteDataSource {
  const PublishingRemoteDataSource(this._api);

  final ApiClient _api;

  // ── Publication ──────────────────────────────────────────────────────────────

  /// Publish. Takes **no body**: `publish` declares no `@Body()`, so the
  /// `{visibility, note}` mobile used to send was silently discarded — the writer's
  /// chosen visibility never reached the server (P-8). Visibility is a separate
  /// call ([changeVisibility]).
  Future<StoryPublicationState> publish({required String storyId}) => _api.post(
    ApiPaths.storyPublish(storyId),
    decode: StoryPublicationState.fromJson,
  );

  /// Unpublish (archive). No body, for the same reason as [publish].
  Future<StoryPublicationState> unpublish({required String storyId}) =>
      _api.post(
        ApiPaths.storyUnpublish(storyId),
        decode: StoryPublicationState.fromJson,
      );

  /// Schedule a future publish. The key is **`scheduledAt`** (`@IsDateString()`),
  /// not `scheduledFor`, and `visibility` is not accepted — the old body failed
  /// `forbidNonWhitelisted` on two keys *and* omitted the required one, so every
  /// schedule returned 400 (P-2).
  Future<StoryPublicationState> schedule({
    required String storyId,
    required DateTime scheduledAt,
  }) => _api.post(
    ApiPaths.storySchedule(storyId),
    body: <String, Object?>{
      'scheduledAt': scheduledAt.toUtc().toIso8601String(),
    },
    decode: StoryPublicationState.fromJson,
  );

  Future<StoryPublicationState> changeVisibility({
    required String storyId,
    required String visibility,
  }) => _api.patch(
    ApiPaths.storyVisibility(storyId),
    body: <String, Object?>{'visibility': visibility},
    decode: StoryPublicationState.fromJson,
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

  /// The current review session, or **null** when the story has never been
  /// submitted. The endpoint returns `ReviewDto | null`, i.e. a 200 carrying
  /// `data: null` — decoding that with `get` raised `API_MALFORMED_RESPONSE`, so
  /// the default state of every story surfaced as an error (P-4).
  Future<ReviewSession?> review(String storyId, {CancelToken? cancelToken}) =>
      _api.getOrNull(
        ApiPaths.storyReview(storyId),
        decode: ReviewSession.fromJson,
        cancelToken: cancelToken,
      );

  /// Request a review. No body — `requestReview` declares no `@Body()`, so the
  /// `reviewerId` mobile used to send was discarded without error (P-8). Reviewer
  /// assignment is not part of the contract.
  Future<ReviewSession> requestReview({required String storyId}) =>
      _api.post(ApiPaths.storyReview(storyId), decode: ReviewSession.fromJson);

  /// Approve. No body (no `@Body()` on the handler).
  Future<ReviewSession> approveReview({required String storyId}) => _api.post(
    ApiPaths.storyReviewApprove(storyId),
    decode: ReviewSession.fromJson,
  );

  /// Request changes. The key is **`notes`** (`RequestChangesDto`), not `note` —
  /// the old key passed only because no caller ever set it (P-5).
  Future<ReviewSession> requestChanges({
    required String storyId,
    String? notes,
  }) => _api.post(
    ApiPaths.storyReviewChanges(storyId),
    body: <String, Object?>{'notes': ?notes},
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

  /// Capture a manual snapshot. No body: the handler declares no `@Body()` and
  /// hard-codes `SnapshotReason.Manual`, so the `label` mobile used to send was
  /// discarded (P-7/P-8). Snapshots are identified by `version`, not a label.
  Future<StorySnapshot> createSnapshot({required String storyId}) => _api.post(
    ApiPaths.storySnapshots(storyId),
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

  /// Revert to a snapshot. Answers the **piece** in its reverted state, not the
  /// snapshot: decoding it as a [StorySnapshot] produced a snapshot whose `id` was
  /// the piece id, which would 404 against `GET /snapshots/{id}` (P-1).
  Future<StoryPublicationState> revertToSnapshot({
    required String storyId,
    required String snapshotId,
  }) => _api.post(
    ApiPaths.storySnapshotRevert(storyId, snapshotId),
    decode: StoryPublicationState.fromJson,
  );
}
