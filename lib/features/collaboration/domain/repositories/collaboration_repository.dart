/// The Collaboration repository contract (AF6) — the boundary the presentation layer
/// depends on for membership, invitations, capabilities, comments, suggestions,
/// activity, and presence. Returns domain entities / [Failure]s only; the concrete
/// impl talks to the wire.
library;

import '../../../../core/utils/result.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/collaboration_activity_entry.dart';
import '../entities/collaboration_comment.dart';
import '../entities/edit_suggestion.dart';
import '../entities/policy_capability.dart';
import '../entities/presence_entry.dart';
import '../entities/story_invitation.dart';
import '../entities/story_member.dart';

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

  // ── Invitations ──────────────────────────────────────────────────────────────
  Future<Result<StoryInvitation>> invite({
    required String storyId,
    required String role,
    String? email,
    String? userId,
  });
  Future<Result<List<StoryInvitation>>> storyInvitations(String storyId);
  Future<Result<List<StoryInvitation>>> myInvitations();
  Future<Result<StoryInvitation>> acceptInvitation(String invitationId);
  Future<Result<StoryInvitation>> declineInvitation(String invitationId);
  Future<Result<Unit>> revokeInvitation(String invitationId);

  // ── Comments ──────────────────────────────────────────────────────────────────
  Future<Result<List<CollaborationComment>>> comments(String storyId);
  Future<Result<CollaborationComment>> addComment({
    required String storyId,
    required String body,
    required String kind,
    CommentAnchor? anchor,
    List<String> mentions,
    String? parentId,
  });
  Future<Result<CollaborationComment>> replyToComment({
    required String commentId,
    required String body,
    List<String> mentions,
  });
  Future<Result<CollaborationComment>> resolveComment(String commentId);
  Future<Result<Unit>> deleteComment(String commentId);

  // ── Suggestions ────────────────────────────────────────────────────────────────
  Future<Result<List<EditSuggestion>>> suggestions(String storyId);
  Future<Result<EditSuggestion>> addSuggestion({
    required String storyId,
    required String originalText,
    required String suggestedText,
    String? blockId,
    String? rationale,
  });
  Future<Result<EditSuggestion>> acceptSuggestion(String suggestionId);
  Future<Result<EditSuggestion>> rejectSuggestion(String suggestionId);
  Future<Result<EditSuggestion>> withdrawSuggestion(String suggestionId);

  // ── Activity + presence ──────────────────────────────────────────────────────
  Future<Result<List<CollaborationActivityEntry>>> activity(String storyId);
  Future<Result<List<PresenceEntry>>> presence(String storyId);
  Future<Result<Unit>> heartbeat({
    required String storyId,
    required String state,
    String? blockId,
  });
}
