/// Collaboration repository implementation (AF6). Wraps every remote call in
/// [guardResult] / [guardUnit] (ApiException → Failure) so error translation lives in
/// one place; holds no local state (collaboration is inherently live).
library;

import '../../../../core/error/result_guard.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/typedefs.dart';
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
import '../../domain/repositories/collaboration_repository.dart';
import '../datasources/collaboration_remote_data_source.dart';

class CollaborationRepositoryImpl implements CollaborationRepository {
  CollaborationRepositoryImpl(this._remote);

  final CollaborationRemoteDataSource _remote;

  @override
  Future<Result<List<StoryMember>>> members(String storyId) =>
      guardResult(() => _remote.members(storyId));

  @override
  Future<Result<StoryMember>> addMember({
    required String storyId,
    required String userId,
    required String role,
  }) => guardResult(
    () => _remote.addMember(storyId: storyId, userId: userId, role: role),
  );

  @override
  Future<Result<StoryMember>> changeRole({
    required String storyId,
    required String userId,
    required String role,
  }) => guardResult(
    () => _remote.changeRole(storyId: storyId, userId: userId, role: role),
  );

  @override
  Future<Result<Unit>> removeMember({
    required String storyId,
    required String userId,
  }) => guardUnit(() => _remote.removeMember(storyId: storyId, userId: userId));

  @override
  Future<Result<Unit>> leave(String storyId) =>
      guardUnit(() => _remote.leave(storyId));

  @override
  Future<Result<CollaboratorLimit>> collaboratorLimit(String storyId) =>
      guardResult(() => _remote.collaboratorLimit(storyId));

  @override
  Future<Result<StoryCapabilities>> capabilities(String storyId) =>
      guardResult(() => _remote.capabilities(storyId));

  @override
  Future<Result<InviteeCandidate>> resolveInvitee(String username) =>
      guardResult(() => _remote.resolveInvitee(username));

  @override
  Future<Result<InviteeCandidate>> me() => guardResult(_remote.me);

  @override
  Future<Result<StoryInvitation>> invite({
    required String storyId,
    required String inviteeId,
    required String role,
  }) => guardResult(
    () => _remote.invite(storyId: storyId, inviteeId: inviteeId, role: role),
  );

  @override
  Future<Result<List<StoryInvitation>>> storyInvitations(String storyId) =>
      guardResult(() => _remote.storyInvitations(storyId));

  @override
  Future<Result<List<StoryInvitation>>> myInvitations() =>
      guardResult(_remote.myInvitations);

  @override
  Future<Result<StoryMember>> acceptInvitation(String invitationId) =>
      guardResult(() => _remote.acceptInvitation(invitationId));

  @override
  Future<Result<StoryInvitation>> declineInvitation(String invitationId) =>
      guardResult(() => _remote.declineInvitation(invitationId));

  @override
  Future<Result<Unit>> revokeInvitation(String invitationId) =>
      guardUnit(() => _remote.revokeInvitation(invitationId));

  @override
  Future<Result<CursorPage<CollaborationComment>>> comments(
    String storyId, {
    String? cursor,
    int? limit,
    String? status,
  }) => guardResult(
    () =>
        _remote.comments(storyId, cursor: cursor, limit: limit, status: status),
  );

  @override
  Future<Result<CommentThread>> commentThread(String commentId) =>
      guardResult(() => _remote.commentThread(commentId));

  @override
  Future<Result<CollaborationComment>> addComment({
    required String storyId,
    required String body,
    required String kind,
    TextAnchor? anchor,
    List<String> mentions = const <String>[],
  }) => guardResult(
    () => _remote.addComment(
      storyId: storyId,
      body: body,
      kind: kind,
      anchor: anchor,
      mentions: mentions,
    ),
  );

  @override
  Future<Result<CollaborationComment>> replyToComment({
    required String commentId,
    required String body,
    List<String> mentions = const <String>[],
  }) => guardResult(
    () => _remote.replyToComment(
      commentId: commentId,
      body: body,
      mentions: mentions,
    ),
  );

  @override
  Future<Result<CollaborationComment>> resolveComment(String commentId) =>
      guardResult(() => _remote.resolveComment(commentId));

  @override
  Future<Result<Unit>> deleteComment(String commentId) =>
      guardUnit(() => _remote.deleteComment(commentId));

  @override
  Future<Result<CursorPage<EditSuggestion>>> suggestions(
    String storyId, {
    String? cursor,
    int? limit,
    String? status,
  }) => guardResult(
    () => _remote.suggestions(
      storyId,
      cursor: cursor,
      limit: limit,
      status: status,
    ),
  );

  @override
  Future<Result<EditSuggestion>> addSuggestion({
    required String storyId,
    required TextAnchor anchor,
    required String originalText,
    required String suggestedText,
  }) => guardResult(
    () => _remote.addSuggestion(
      storyId: storyId,
      anchor: anchor,
      originalText: originalText,
      suggestedText: suggestedText,
    ),
  );

  @override
  Future<Result<EditSuggestion>> acceptSuggestion(String suggestionId) =>
      guardResult(() => _remote.acceptSuggestion(suggestionId));

  @override
  Future<Result<EditSuggestion>> rejectSuggestion(String suggestionId) =>
      guardResult(() => _remote.rejectSuggestion(suggestionId));

  @override
  Future<Result<EditSuggestion>> withdrawSuggestion(String suggestionId) =>
      guardResult(() => _remote.withdrawSuggestion(suggestionId));

  @override
  Future<Result<CursorPage<CollaborationActivityEntry>>> activity(
    String storyId, {
    String? cursor,
    int? limit,
  }) => guardResult(
    () => _remote.activity(storyId, cursor: cursor, limit: limit),
  );

  @override
  Future<Result<List<PresenceEntry>>> presence(String storyId) =>
      guardResult(() => _remote.presence(storyId));

  @override
  Future<Result<Unit>> heartbeat({
    required String storyId,
    required String state,
  }) => guardUnit(() => _remote.heartbeat(storyId: storyId, state: state));
}
