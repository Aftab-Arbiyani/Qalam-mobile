/// Collaboration remote data source (AF6) — the only place the collaboration
/// `/stories/{id}/*`, `/invitations/*`, `/comments/*`, and `/suggestions/*` endpoints
/// + `ApiClient` are touched. Maps envelope payloads to typed entities; the client
/// sends only declared params and never trusts a local authorization decision (the
/// policy engine owns capabilities).
library;

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_paths.dart';
import '../../../../shared/api/api_envelope.dart';
import '../../domain/entities/collaboration_activity_entry.dart';
import '../../domain/entities/collaboration_comment.dart';
import '../../domain/entities/collaborator_limit.dart';
import '../../domain/entities/edit_suggestion.dart';
import '../../domain/entities/invitee_candidate.dart';
import '../../domain/entities/policy_capability.dart';
import '../../domain/entities/presence_entry.dart';
import '../../domain/entities/story_invitation.dart';
import '../../domain/entities/story_member.dart';
import '../../domain/entities/text_anchor.dart';

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

  /// B6 — the story's collaborator seat allowance. Authorized as `story.invite`, so a
  /// viewer who could not spend a seat gets a 403 rather than a number.
  Future<CollaboratorLimit> collaboratorLimit(
    String storyId, {
    CancelToken? cancelToken,
  }) => _api.get(
    ApiPaths.storyCollaboratorLimit(storyId),
    decode: CollaboratorLimit.fromJson,
    cancelToken: cancelToken,
  );

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

  /// The viewer's own id (`GET /me` → `ProfileResponseDto.id`).
  ///
  /// Needed because `SessionState` carries only a role, and some affordances are
  /// self-service: the Policy Engine authorizes withdrawing a suggestion through its
  /// self-service rule (`resource.ownerId == suggestion.authorId`), which the
  /// story-level capability map cannot express — `suggestion.resolve` there is
  /// evaluated against the STORY, not one suggestion. So "may I withdraw this?" is
  /// "did I write it?" (defect **C-12**, `docs/56` §2.1).
  ///
  /// Read here rather than through the profile feature for the same reason as
  /// [resolveInvitee]: a feature may not import another feature.
  Future<InviteeCandidate> me({CancelToken? cancelToken}) => _api.get(
    ApiPaths.me,
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

  /// Root comments, one cursor page at a time. The endpoint is cursor-paginated with
  /// an optional open/resolved filter; mobile used to call it with a plain list read
  /// and no query, which discarded `meta.pagination` and capped the screen at the
  /// first 20 rows with no way to filter (defect **C-10**, `docs/56` §2.1).
  Future<CursorPage<CollaborationComment>> comments(
    String storyId, {
    String? cursor,
    int? limit,
    String? status,
    CancelToken? cancelToken,
  }) => _api.getPage(
    ApiPaths.storyComments(storyId),
    query: <String, Object?>{
      'cursor': ?cursor,
      'limit': ?limit,
      'status': ?status,
    },
    decodeItem: CollaborationComment.fromJson,
    cancelToken: cancelToken,
  );

  /// A root comment plus its replies (`CommentThreadDto`). `CommentDto` carries no
  /// `replies`, so this is the ONLY way to read a thread — and mobile never called
  /// it, which is why the threaded screen showed no replies (**C-5**).
  Future<CommentThread> commentThread(
    String commentId, {
    CancelToken? cancelToken,
  }) => _api.get(
    ApiPaths.collaborationCommentThread(commentId),
    decode: CommentThread.fromJson,
    cancelToken: cancelToken,
  );

  /// Create a story-level or inline comment.
  ///
  /// `CreateCommentDto` accepts exactly `{body, kind?, anchor?, mentions?}`. There is
  /// no `parentId`: a reply goes to `POST /comments/:id/replies`, and sending it here
  /// was a `forbidNonWhitelisted` 400 waiting to happen (**C-7**). The anchor is
  /// `{from, to, quote?}`, not `{blockId, start, end}` (**C-6**).
  Future<CollaborationComment> addComment({
    required String storyId,
    required String body,
    required String kind,
    TextAnchor? anchor,
    List<String> mentions = const <String>[],
  }) => _api.post(
    ApiPaths.storyComments(storyId),
    body: <String, Object?>{
      'body': body,
      'kind': kind,
      'anchor': ?anchor?.toCommentJson(),
      if (mentions.isNotEmpty) 'mentions': mentions,
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

  /// Suggestions, one cursor page at a time (see [comments] on **C-10**).
  Future<CursorPage<EditSuggestion>> suggestions(
    String storyId, {
    String? cursor,
    int? limit,
    String? status,
    CancelToken? cancelToken,
  }) => _api.getPage(
    ApiPaths.storySuggestions(storyId),
    query: <String, Object?>{
      'cursor': ?cursor,
      'limit': ?limit,
      'status': ?status,
    },
    decodeItem: EditSuggestion.fromJson,
    cancelToken: cancelToken,
  );

  /// Propose an edit.
  ///
  /// `CreateSuggestionDto` is exactly `{anchor: {from, to}, originalText,
  /// suggestedText}` with `anchor` **required**. The old body sent
  /// `{originalText, suggestedText, blockId?, rationale?}` — no anchor plus two
  /// undeclared keys — so every call returned `400 VALIDATION_FAILED` (defect
  /// **C-3**, `docs/56` §2.1). There is no `rationale` field in the contract; a
  /// reviewer explains a change in a comment, not on the suggestion.
  Future<EditSuggestion> addSuggestion({
    required String storyId,
    required TextAnchor anchor,
    required String originalText,
    required String suggestedText,
  }) => _api.post(
    ApiPaths.storySuggestions(storyId),
    body: <String, Object?>{
      'anchor': anchor.toSuggestionJson(),
      'originalText': originalText,
      'suggestedText': suggestedText,
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

  /// The story's activity feed, cursor-paginated (see [comments] on **C-10**).
  Future<CursorPage<CollaborationActivityEntry>> activity(
    String storyId, {
    String? cursor,
    int? limit,
    CancelToken? cancelToken,
  }) => _api.getPage(
    ApiPaths.storyActivity(storyId),
    query: <String, Object?>{'cursor': ?cursor, 'limit': ?limit},
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
  ///
  /// `PresenceHeartbeatDto` accepts **only** `state`. The `blockId` mobile used to
  /// send would have been a `forbidNonWhitelisted` 400 the moment anything set it
  /// (defect **C-8**, `docs/56` §2.1).
  Future<void> heartbeat({required String storyId, required String state}) =>
      _api.postVoid(
        ApiPaths.storyPresence(storyId),
        body: <String, Object?>{'state': state},
      );
}
