/// The Collaboration repository contract (AF6) — the boundary the presentation layer
/// depends on for membership, invitations, capabilities, comments, suggestions,
/// activity, and presence. Returns domain entities / [Failure]s only; the concrete
/// impl talks to the wire.
library;

import '../../../../core/utils/result.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../../shared/api/api_envelope.dart';
import '../entities/collaboration_activity_entry.dart';
import '../entities/collaboration_comment.dart';
import '../entities/collaborator_limit.dart';
import '../entities/edit_suggestion.dart';
import '../entities/invitee_candidate.dart';
import '../entities/policy_capability.dart';
import '../entities/presence_entry.dart';
import '../entities/story_invitation.dart';
import '../entities/story_member.dart';
import '../entities/text_anchor.dart';

abstract interface class CollaborationRepository {
  // ── Members ────────────────────────────────────────────────────────────────
  Future<Result<List<StoryMember>>> members(String storyId);
  Future<Result<StoryMember>> addMember({
    required String storyId,
    required String userId,
    required String role,
  });
  Future<Result<StoryMember>> changeRole({
    required String storyId,
    required String userId,
    required String role,
  });
  Future<Result<Unit>> removeMember({
    required String storyId,
    required String userId,
  });
  Future<Result<Unit>> leave(String storyId);

  /// The server-authoritative capability map the client gates affordances on.
  Future<Result<StoryCapabilities>> capabilities(String storyId);

  /// B6 — the story's collaborator seat allowance, by its OWNER's plan.
  Future<Result<CollaboratorLimit>> collaboratorLimit(String storyId);

  // ── Invitations ──────────────────────────────────────────────────────────────
  /// Resolve a `@handle` to the invite target's id — the invite contract takes an id, and there is
  /// no invite-by-email path (defect M-1, `platfrom/docs/48` §3.1).
  Future<Result<InviteeCandidate>> resolveInvitee(String username);

  /// The viewer's own id — needed for self-service affordances (C-12).
  Future<Result<InviteeCandidate>> me();

  /// Invite by **user id** (`{inviteeId, role}`) — the only shape the contract accepts.
  Future<Result<StoryInvitation>> invite({
    required String storyId,
    required String inviteeId,
    required String role,
  });
  Future<Result<List<StoryInvitation>>> storyInvitations(String storyId);
  Future<Result<List<StoryInvitation>>> myInvitations();

  /// Accepting returns the new **member** — the endpoint answers with `MemberDto`, not the
  /// invitation.
  Future<Result<StoryMember>> acceptInvitation(String invitationId);
  Future<Result<StoryInvitation>> declineInvitation(String invitationId);
  Future<Result<Unit>> revokeInvitation(String invitationId);

  // ── Comments ──────────────────────────────────────────────────────────────────

  /// One cursor page of ROOT comments, optionally filtered by open/resolved.
  Future<Result<CursorPage<CollaborationComment>>> comments(
    String storyId, {
    String? cursor,
    int? limit,
    String? status,
  });

  /// A root comment plus its replies — the only source of a thread (C-5).
  Future<Result<CommentThread>> commentThread(String commentId);

  Future<Result<CollaborationComment>> addComment({
    required String storyId,
    required String body,
    required String kind,
    TextAnchor? anchor,
    List<String> mentions,
  });
  Future<Result<CollaborationComment>> replyToComment({
    required String commentId,
    required String body,
    List<String> mentions,
  });
  Future<Result<CollaborationComment>> resolveComment(String commentId);
  Future<Result<Unit>> deleteComment(String commentId);

  // ── Suggestions ────────────────────────────────────────────────────────────────

  /// One cursor page of suggestions, optionally filtered by status.
  Future<Result<CursorPage<EditSuggestion>>> suggestions(
    String storyId, {
    String? cursor,
    int? limit,
    String? status,
  });
  Future<Result<EditSuggestion>> addSuggestion({
    required String storyId,
    required TextAnchor anchor,
    required String originalText,
    required String suggestedText,
  });
  Future<Result<EditSuggestion>> acceptSuggestion(String suggestionId);
  Future<Result<EditSuggestion>> rejectSuggestion(String suggestionId);
  Future<Result<EditSuggestion>> withdrawSuggestion(String suggestionId);

  // ── Activity + presence ──────────────────────────────────────────────────────

  /// One cursor page of the activity feed.
  Future<Result<CursorPage<CollaborationActivityEntry>>> activity(
    String storyId, {
    String? cursor,
    int? limit,
  });
  Future<Result<List<PresenceEntry>>> presence(String storyId);
  Future<Result<Unit>> heartbeat({
    required String storyId,
    required String state,
  });
}
