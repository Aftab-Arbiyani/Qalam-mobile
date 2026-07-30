/// The Publishing repository contract (AF6) — the boundary the presentation layer
/// depends on for the publish workflow: review sessions, publish / unpublish /
/// schedule / visibility, snapshots, and publication history. Returns domain entities
/// / [Failure]s only; the concrete impl talks to the wire.
///
/// Signatures mirror the contract exactly (`docs/56` §2.2): the publication actions
/// answer the **piece** ([StoryPublicationState], not an event — P-1), `review` is
/// **nullable** (no session yet ≠ an error — P-4), and the parameters the endpoints
/// never accepted are gone rather than accepted-and-discarded (P-2, P-5, P-8).
library;

import '../../../../core/utils/result.dart';
import '../entities/publication_event.dart';
import '../entities/review_session.dart';
import '../entities/story_publication_state.dart';
import '../entities/story_snapshot.dart';

abstract interface class PublishingRepository {
  // ── Publication ──────────────────────────────────────────────────────────────
  Future<Result<StoryPublicationState>> publish({required String storyId});
  Future<Result<StoryPublicationState>> unpublish({required String storyId});
  Future<Result<StoryPublicationState>> schedule({
    required String storyId,
    required DateTime scheduledAt,
  });
  Future<Result<StoryPublicationState>> changeVisibility({
    required String storyId,
    required String visibility,
  });
  Future<Result<List<PublicationEvent>>> publicationHistory(String storyId);

  // ── Review workflow ──────────────────────────────────────────────────────────

  /// Null when the story has never been submitted for review (the Draft state).
  Future<Result<ReviewSession?>> review(String storyId);
  Future<Result<ReviewSession>> requestReview({required String storyId});
  Future<Result<ReviewSession>> approveReview({required String storyId});
  Future<Result<ReviewSession>> requestChanges({
    required String storyId,
    String? notes,
  });

  // ── Snapshots ──────────────────────────────────────────────────────────────────
  Future<Result<List<StorySnapshot>>> snapshots(String storyId);
  Future<Result<StorySnapshot>> createSnapshot({required String storyId});
  Future<Result<StorySnapshot>> snapshot(String snapshotId);

  /// Answers the reverted **piece**, not the snapshot.
  Future<Result<StoryPublicationState>> revertToSnapshot({
    required String storyId,
    required String snapshotId,
  });
}
