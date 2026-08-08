/// The Collaboration / Publishing / Trust feature's composition root (AF6, docs/40 §9).
/// Binds the three repositories to their data implementations, and exposes the
/// server-authoritative read models the UI renders: story membership + the capability
/// map (the affordance-gating source of truth), invitations, comments, suggestions,
/// presence, activity, the review workflow, snapshots, publication history, the
/// caller's trust standing, and the block list. Data sources + repos are kept alive
/// (stateless, cross-cutting); every screen read is autoDispose and story-scoped by a
/// `storyId` family where relevant.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/api/api_envelope.dart';
import '../../data/datasources/collaboration_remote_data_source.dart';
import '../../data/datasources/publishing_remote_data_source.dart';
import '../../data/datasources/trust_remote_data_source.dart';
import '../../data/repositories/collaboration_repository_impl.dart';
import '../../data/repositories/publishing_repository_impl.dart';
import '../../data/repositories/trust_repository_impl.dart';
import '../../domain/entities/block_entry.dart';
import '../../domain/entities/collaboration_activity_entry.dart';
import '../../domain/entities/collaboration_comment.dart';
import '../../domain/entities/collaborator_limit.dart';
import '../../domain/entities/edit_suggestion.dart';
import '../../domain/entities/invitee_candidate.dart';
import '../../domain/entities/policy_capability.dart';
import '../../domain/entities/presence_entry.dart';
import '../../domain/entities/publication_event.dart';
import '../../domain/entities/review_session.dart';
import '../../domain/entities/story_invitation.dart';
import '../../domain/entities/story_member.dart';
import '../../domain/entities/story_snapshot.dart';
import '../../domain/entities/trust_summary.dart';
import '../../domain/repositories/collaboration_repository.dart';
import '../../domain/repositories/publishing_repository.dart';
import '../../domain/repositories/trust_repository.dart';

part 'collaboration_providers.g.dart';

// ── Data sources ──────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
CollaborationRemoteDataSource collaborationRemoteDataSource(Ref ref) =>
    CollaborationRemoteDataSource(ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
PublishingRemoteDataSource publishingRemoteDataSource(Ref ref) =>
    PublishingRemoteDataSource(ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
TrustRemoteDataSource trustRemoteDataSource(Ref ref) =>
    TrustRemoteDataSource(ref.watch(apiClientProvider));

// ── Repositories ──────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
CollaborationRepository collaborationRepository(Ref ref) =>
    CollaborationRepositoryImpl(
      ref.watch(collaborationRemoteDataSourceProvider),
    );

@Riverpod(keepAlive: true)
PublishingRepository publishingRepository(Ref ref) =>
    PublishingRepositoryImpl(ref.watch(publishingRemoteDataSourceProvider));

@Riverpod(keepAlive: true)
TrustRepository trustRepository(Ref ref) =>
    TrustRepositoryImpl(ref.watch(trustRemoteDataSourceProvider));

// ── Collaboration reads (story-scoped) ────────────────────────────────────────

/// The collaborators on a story.
@riverpod
Future<List<StoryMember>> storyMembers(Ref ref, String storyId) async {
  final Result<List<StoryMember>> result = await ref
      .watch(collaborationRepositoryProvider)
      .members(storyId);
  return _unwrapList(result);
}

/// The server-authoritative capability map — the SINGLE thing collaboration UI gates
/// affordances on. Never throws: on failure it falls back to a fail-closed read-only
/// map so gating always resolves (the policy engine re-checks anyway).
@riverpod
Future<StoryCapabilities> storyCapabilities(Ref ref, String storyId) async {
  final Result<StoryCapabilities> result = await ref
      .watch(collaborationRepositoryProvider)
      .capabilities(storyId);
  return switch (result) {
    Ok<StoryCapabilities>(:final StoryCapabilities value) => value,
    Err<StoryCapabilities>() => StoryCapabilities.readOnly,
  };
}

/// The story's collaborator seat allowance (B6, `platfrom/docs/45` §4.11) — used / limit /
/// remaining, charged to the story OWNER's plan.
///
/// **Never throws.** The route is `story.invite`-authorized, so a reader gets a 403 and a
/// story whose allowance cannot be read would otherwise take the collaborators screen down
/// with it. It falls back to [CollaboratorLimit.unknown], which the screen reads as "no
/// number to show" rather than as a refusal: the invite control stays live unless the
/// server actually said there is no seat. Losing an upsell is a missed sale; hiding the
/// only management action on the screen is a broken app.
@riverpod
Future<CollaboratorLimit> storyCollaboratorLimit(Ref ref, String storyId) async {
  final Result<CollaboratorLimit> result = await ref
      .watch(collaborationRepositoryProvider)
      .collaboratorLimit(storyId);
  return switch (result) {
    Ok<CollaboratorLimit>(:final CollaboratorLimit value) => value,
    Err<CollaboratorLimit>() => CollaboratorLimit.unknown,
  };
}

/// The first page of root comments on a story. The endpoint is cursor-paginated
/// (C-10); this provider exposes the first page and [storyCommentThread] fetches a
/// thread's replies on demand (C-5).
@riverpod
Future<CursorPage<CollaborationComment>> storyComments(
  Ref ref,
  String storyId,
) async {
  final Result<CursorPage<CollaborationComment>> result = await ref
      .watch(collaborationRepositoryProvider)
      .comments(storyId);
  return _unwrap(result);
}

/// A comment's replies (`GET /comments/:id/thread`). `CommentDto` carries no
/// `replies`, so a thread is a separate read.
@riverpod
Future<CommentThread> storyCommentThread(Ref ref, String commentId) async {
  final Result<CommentThread> result = await ref
      .watch(collaborationRepositoryProvider)
      .commentThread(commentId);
  return _unwrap(result);
}

/// The first page of edit suggestions on a story (cursor-paginated, C-10).
@riverpod
Future<CursorPage<EditSuggestion>> storySuggestions(
  Ref ref,
  String storyId,
) async {
  final Result<CursorPage<EditSuggestion>> result = await ref
      .watch(collaborationRepositoryProvider)
      .suggestions(storyId);
  return _unwrap(result);
}

/// The outstanding invitations issued for a story.
@riverpod
Future<List<StoryInvitation>> storyInvitations(Ref ref, String storyId) async {
  final Result<List<StoryInvitation>> result = await ref
      .watch(collaborationRepositoryProvider)
      .storyInvitations(storyId);
  return _unwrapList(result);
}

/// The live presence roster on a story (drives the presence bar).
@riverpod
Future<List<PresenceEntry>> storyPresence(Ref ref, String storyId) async {
  final Result<List<PresenceEntry>> result = await ref
      .watch(collaborationRepositoryProvider)
      .presence(storyId);
  return _unwrapList(result);
}

/// The collaboration audit feed for a story.
@riverpod
Future<CursorPage<CollaborationActivityEntry>> storyActivity(
  Ref ref,
  String storyId,
) async {
  final Result<CursorPage<CollaborationActivityEntry>> result = await ref
      .watch(collaborationRepositoryProvider)
      .activity(storyId);
  return _unwrap(result);
}

/// The current user's inbound invitation inbox (`GET /me/invitations`).
@riverpod
Future<List<StoryInvitation>> myInvitations(Ref ref) async {
  final Result<List<StoryInvitation>> result = await ref
      .watch(collaborationRepositoryProvider)
      .myInvitations();
  return _unwrapList(result);
}

/// The viewer's own user id, or null if it cannot be resolved. Used only for
/// self-service affordances the capability map cannot express (C-12); never for an
/// authorization decision — the server re-checks every action.
@riverpod
Future<String?> viewerId(Ref ref) async {
  final Result<InviteeCandidate> result = await ref
      .watch(collaborationRepositoryProvider)
      .me();
  return switch (result) {
    Ok<InviteeCandidate>(:final InviteeCandidate value) => value.id,
    Err<InviteeCandidate>() => null,
  };
}

// ── Publishing reads (story-scoped) ────────────────────────────────────────────

/// The review session for a story, or null when review has never been requested —
/// which the endpoint expresses as `200 {data: null}`, not a 404.
///
/// This used to map `NOT_FOUND → null`, a code the endpoint never returns. The real
/// null-data response became `API_MALFORMED_RESPONSE` inside `ApiClient.get` and was
/// rethrown here, so the Review card showed an error for every story that had never
/// been submitted — the default state — and its `review == null` branch was dead
/// code. The nullability now comes from the data source via `getOrNull`
/// (defect **P-4**, `docs/56` §2.2).
@riverpod
Future<ReviewSession?> storyReview(Ref ref, String storyId) async {
  final Result<ReviewSession?> result = await ref
      .watch(publishingRepositoryProvider)
      .review(storyId);
  return switch (result) {
    Ok<ReviewSession?>(:final ReviewSession? value) => value,
    Err<ReviewSession?>(:final Failure failure) => throw failure,
  };
}

/// The snapshots (versions) of a story, newest first as the server returns them.
@riverpod
Future<List<StorySnapshot>> storySnapshots(Ref ref, String storyId) async {
  final Result<List<StorySnapshot>> result = await ref
      .watch(publishingRepositoryProvider)
      .snapshots(storyId);
  return _unwrapList(result);
}

/// The publication history for a story.
@riverpod
Future<List<PublicationEvent>> publicationHistory(
  Ref ref,
  String storyId,
) async {
  final Result<List<PublicationEvent>> result = await ref
      .watch(publishingRepositoryProvider)
      .publicationHistory(storyId);
  return _unwrapList(result);
}

// ── Trust reads ────────────────────────────────────────────────────────────────

/// The current user's trust standing (the restricted-state screens read this).
@riverpod
Future<TrustSummary> trustSummary(Ref ref) async {
  final Result<TrustSummary> result = await ref
      .watch(trustRepositoryProvider)
      .myTrust();
  return switch (result) {
    Ok<TrustSummary>(:final TrustSummary value) => value,
    Err<TrustSummary>(:final Failure failure) => throw failure,
  };
}

/// The users the current user has blocked or muted.
@riverpod
Future<List<BlockEntry>> myBlocks(Ref ref) async {
  final Result<List<BlockEntry>> result = await ref
      .watch(trustRepositoryProvider)
      .myBlocks();
  return _unwrapList(result);
}

/// Unwrap a list [Result], rethrowing the [Failure] so read providers surface it as
/// `AsyncError` (the feature's presentation convention, docs/40 §16.2).
List<T> _unwrapList<T>(Result<List<T>> result) => switch (result) {
  Ok<List<T>>(:final List<T> value) => value,
  Err<List<T>>(:final Failure failure) => throw failure,
};

/// Unwrap a single-value [Result] the same way.
T _unwrap<T>(Result<T> result) => switch (result) {
  Ok<T>(:final T value) => value,
  Err<T>(:final Failure failure) => throw failure,
};
