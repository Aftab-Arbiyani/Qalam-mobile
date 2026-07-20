/// The Publishing repository contract (AF6) — the boundary the presentation layer
/// depends on for the publish workflow: review sessions, publish / unpublish /
/// schedule / visibility, snapshots, and publication history. Returns domain entities
/// / [Failure]s only; the concrete impl talks to the wire.
library;

import '../../../../core/utils/result.dart';
import '../entities/publication_event.dart';
import '../entities/review_session.dart';
import '../entities/story_snapshot.dart';

abstract interface class PublishingRepository {
  // ── Publication ──────────────────────────────────────────────────────────────
  Future<Result<PublicationEvent>> publish({
    required String storyId,
    String? visibility,
    String? note,
  });
  Future<Result<PublicationEvent>> unpublish({
    required String storyId,
    String? note,
  });
  Future<Result<PublicationEvent>> schedule({
    required String storyId,
    required DateTime scheduledFor,
    String? visibility,
  });
  Future<Result<PublicationEvent>> changeVisibility({
    required String storyId,
    required String visibility,
  });
  Future<Result<List<PublicationEvent>>> publicationHistory(String storyId);

  // ── Review workflow ──────────────────────────────────────────────────────────
  Future<Result<ReviewSession>> review(String storyId);
  Future<Result<ReviewSession>> requestReview({
    required String storyId,
    String? reviewerId,
    String? note,
  });
  Future<Result<ReviewSession>> approveReview({
    required String storyId,
    String? note,
  });
  Future<Result<ReviewSession>> requestChanges({
    required String storyId,
    String? note,
  });

  // ── Snapshots ──────────────────────────────────────────────────────────────────
  Future<Result<List<StorySnapshot>>> snapshots(String storyId);
  Future<Result<StorySnapshot>> createSnapshot({
    required String storyId,
    String? label,
  });
  Future<Result<StorySnapshot>> snapshot(String snapshotId);
  Future<Result<StorySnapshot>> revertToSnapshot({
    required String storyId,
    required String snapshotId,
  });
}
