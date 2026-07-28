/// Collaboration remote data source (AF6) — the only place the collaboration
/// `/stories/{id}/*`, `/invitations/*`, `/comments/*`, and `/suggestions/*` endpoints
/// + `ApiClient` are touched. Maps envelope payloads to typed entities; the client
/// sends only declared params and never trusts a local authorization decision (the
/// policy engine owns capabilities).
library;

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_paths.dart';
import '../../domain/entities/collaboration_activity_entry.dart';
import '../../domain/entities/collaboration_comment.dart';
import '../../domain/entities/edit_suggestion.dart';
import '../../domain/entities/invitee_candidate.dart';
import '../../domain/entities/policy_capability.dart';
import '../../domain/entities/presence_entry.dart';
import '../../domain/entities/story_invitation.dart';
import '../../domain/entities/story_member.dart';

class CollaborationRemoteDataSource {
  const CollaborationRemoteDataSource(this._api);

  final ApiClient _api;

  // ── Members ────────────────────────────────────────────────────────────────
  Future<List<StoryMember>> members(
    String storyId, {
    CancelToken? cancelToken,
  }) => _api.getList(
    ApiPaths.storyMembers(storyId),
    decodeItem: StoryMember.fromJson,
    cancelToken: cancelToken,
  );

  Future<StoryMember> addMember({
    required String storyId,
    required String userId,
    required String role,
  }) => _api.post(
    ApiPaths.storyMembers(storyId),
    body: <String, Object?>{'userId': userId, 'role': role},
    decode: StoryMember.fromJson,
  );

  Future<StoryMember> changeRole({
    required String storyId,
    required String userId,
    required String role,
  }) => _api.patch(
    ApiPaths.storyMember(storyId, userId),
    body: <String, Object?>{'role': role},
    decode: StoryMember.fromJson,
  );

  Future<void> removeMember({
    required String storyId,
    required String userId,
  }) => _api.delete(ApiPaths.storyMember(storyId, userId));

  Future<void> leave(String storyId) =>
      _api.postVoid(ApiPaths.storyLeave(storyId));

  Future<StoryCapabilities> capabilities(
    String storyId, {
    CancelToken? cancelToken,
  }) => _api.get(
    ApiPaths.storyCapabilities(storyId),
    decode: StoryCapabilities.fromJson,
    cancelToken: cancelToken,
  );

  // ── Invitations ──────────────────────────────────────────────────────────────

  /// Resolve a `@handle` to the id the invite contract needs (`GET /users/{username}`).
  ///
  /// The collaboration feature makes this call itself rather than reusing the reading feature's
  /// profile fetch, because a feature may never import another feature (docs/folder-structure).
  Future<InviteeCandidate> resolveInvitee(
    String username, {
    CancelToken? cancelToken,
  }) => _api.get(
    ApiPaths.userByUsername(username),
    decode: InviteeCandidate.fromJson,
    cancelToken: cancelToken,
  );

  /// Invite by **user id**, the only shape the contract accepts.
  ///
  /// `CreateInvitationDto` requires exactly `{inviteeId, role}` and the API runs
  /// `ValidationPipe({whitelist: true, forbidNonWhitelisted: true})`. The previous version sent
  /// `{role, email?, userId?}` — an unknown property AND a missing required field, so every
  /// invitation 400'd (defect **M-1**, `platfrom/docs/48` §3.1). Callers resolve the handle first
  /// via [resolveInvitee].
  Future<StoryInvitation> invite({
    required String storyId,
    required String inviteeId,
    required String role,
  }) => _api.post(
    ApiPaths.storyInvitations(storyId),
    body: <String, Object?>{'inviteeId': inviteeId, 'role': role},
    decode: StoryInvitation.fromJson,
  );

  Future<List<StoryInvitation>> storyInvitations(
    String storyId, {
    CancelToken? cancelToken,
  }) => _api.getList(
    ApiPaths.storyInvitations(storyId),
    decodeItem: StoryInvitation.fromJson,
    cancelToken: cancelToken,
  );

  Future<List<StoryInvitation>> myInvitations({CancelToken? cancelToken}) =>
      _api.getList(
        ApiPaths.meInvitations,
        decodeItem: StoryInvitation.fromJson,
        cancelToken: cancelToken,
      );

  /// Accept → become a collaborator. The response is the new **member**, not the invitation
  /// (`MemberDto`), which is what the endpoint has always returned; decoding it as a
  /// [StoryInvitation] silently produced an invitation with empty fields, because that entity's
  /// `fromJson` defaults every missing key.
  Future<StoryMember> acceptInvitation(String invitationId) => _api.post(
    ApiPaths.invitationAccept(invitationId),
    decode: StoryMember.fromJson,
  );

  Future<StoryInvitation> declineInvitation(String invitationId) => _api.post(
    ApiPaths.invitationDecline(invitationId),
    decode: StoryInvitation.fromJson,
  );

  Future<void> revokeInvitation(String invitationId) =>
      _api.delete(ApiPaths.invitation(invitationId));

  // ── Comments ──────────────────────────────────────────────────────────────────
  Future<List<CollaborationComment>> comments(
    String storyId, {
    CancelToken? cancelToken,
  }) => _api.getList(
    ApiPaths.storyComments(storyId),
    decodeItem: CollaborationComment.fromJson,
    cancelToken: cancelToken,
  );

  Future<CollaborationComment> addComment({
    required String storyId,
    required String body,
    required String kind,
    CommentAnchor? anchor,
    List<String> mentions = const <String>[],
    String? parentId,
  }) => _api.post(
    ApiPaths.storyComments(storyId),
    body: <String, Object?>{
      'body': body,
      'kind': kind,
      'anchor': ?anchor?.toJson(),
      if (mentions.isNotEmpty) 'mentions': mentions,
      'parentId': ?parentId,
    },
    decode: CollaborationComment.fromJson,
  );

  Future<CollaborationComment> replyToComment({
    required String commentId,
    required String body,
    List<String> mentions = const <String>[],
  }) => _api.post(
    ApiPaths.collaborationCommentReplies(commentId),
    body: <String, Object?>{
      'body': body,
      if (mentions.isNotEmpty) 'mentions': mentions,
    },
    decode: CollaborationComment.fromJson,
  );

  Future<CollaborationComment> resolveComment(String commentId) => _api.post(
    ApiPaths.collaborationCommentResolve(commentId),
    decode: CollaborationComment.fromJson,
  );

  Future<void> deleteComment(String commentId) =>
      _api.delete(ApiPaths.collaborationComment(commentId));

  // ── Suggestions ────────────────────────────────────────────────────────────────
  Future<List<EditSuggestion>> suggestions(
    String storyId, {
    CancelToken? cancelToken,
  }) => _api.getList(
    ApiPaths.storySuggestions(storyId),
    decodeItem: EditSuggestion.fromJson,
    cancelToken: cancelToken,
  );

  Future<EditSuggestion> addSuggestion({
    required String storyId,
    required String originalText,
    required String suggestedText,
    String? blockId,
    String? rationale,
  }) => _api.post(
    ApiPaths.storySuggestions(storyId),
    body: <String, Object?>{
      'originalText': originalText,
      'suggestedText': suggestedText,
      'blockId': ?blockId,
      'rationale': ?rationale,
    },
    decode: EditSuggestion.fromJson,
  );

  Future<EditSuggestion> acceptSuggestion(String suggestionId) => _api.post(
    ApiPaths.suggestionAccept(suggestionId),
    decode: EditSuggestion.fromJson,
  );

  Future<EditSuggestion> rejectSuggestion(String suggestionId) => _api.post(
    ApiPaths.suggestionReject(suggestionId),
    decode: EditSuggestion.fromJson,
  );

  Future<EditSuggestion> withdrawSuggestion(String suggestionId) => _api.post(
    ApiPaths.suggestionWithdraw(suggestionId),
    decode: EditSuggestion.fromJson,
  );

  // ── Activity + presence ──────────────────────────────────────────────────────
  Future<List<CollaborationActivityEntry>> activity(
    String storyId, {
    CancelToken? cancelToken,
  }) => _api.getList(
    ApiPaths.storyActivity(storyId),
    decodeItem: CollaborationActivityEntry.fromJson,
    cancelToken: cancelToken,
  );

  Future<List<PresenceEntry>> presence(
    String storyId, {
    CancelToken? cancelToken,
  }) => _api.getList(
    ApiPaths.storyPresence(storyId),
    decodeItem: PresenceEntry.fromJson,
    cancelToken: cancelToken,
  );

  /// A heartbeat is a POST that records the caller's presence; the roster is then
  /// re-read via [presence] (ApiClient has no POST-returns-list verb).
  Future<void> heartbeat({
    required String storyId,
    required String state,
    String? blockId,
  }) => _api.postVoid(
    ApiPaths.storyPresence(storyId),
    body: <String, Object?>{'state': state, 'blockId': ?blockId},
  );
}
