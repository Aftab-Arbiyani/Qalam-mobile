/// Collaboration repository implementation (AF6). Wraps every remote call in
/// [guardResult] / [guardUnit] (ApiException → Failure) so error translation lives in
/// one place; holds no local state (collaboration is inherently live).
library;

import '../../../../core/error/result_guard.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/collaboration_activity_entry.dart';
import '../../domain/entities/collaboration_comment.dart';
import '../../domain/entities/edit_suggestion.dart';
import '../../domain/entities/policy_capability.dart';
import '../../domain/entities/presence_entry.dart';
import '../../domain/entities/story_invitation.dart';
import '../../domain/entities/story_member.dart';
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
  Future<Result<StoryCapabilities>> capabilities(String storyId) =>
      guardResult(() => _remote.capabilities(storyId));

  @override
  Future<Result<StoryInvitation>> invite({
    required String storyId,
    required String role,
    String? email,
    String? userId,
  }) => guardResult(
    () => _remote.invite(
      storyId: storyId,
      role: role,
      email: email,
      userId: userId,
    ),
  );

  @override
  Future<Result<List<StoryInvitation>>> storyInvitations(String storyId) =>
      guardResult(() => _remote.storyInvitations(storyId));

  @override
  Future<Result<List<StoryInvitation>>> myInvitations() =>
      guardResult(_remote.myInvitations);

  @override
  Future<Result<StoryInvitation>> acceptInvitation(String invitationId) =>
      guardResult(() => _remote.acceptInvitation(invitationId));

  @override
  Future<Result<StoryInvitation>> declineInvitation(String invitationId) =>
      guardResult(() => _remote.declineInvitation(invitationId));

  @override
  Future<Result<Unit>> revokeInvitation(String invitationId) =>
      guardUnit(() => _remote.revokeInvitation(invitationId));

  @override
  Future<Result<List<CollaborationComment>>> comments(String storyId) =>
      guardResult(() => _remote.comments(storyId));

  @override
  Future<Result<CollaborationComment>> addComment({
    required String storyId,
    required String body,
    required String kind,
    CommentAnchor? anchor,
    List<String> mentions = const <String>[],
    String? parentId,
  }) => guardResult(
    () => _remote.addComment(
      storyId: storyId,
      body: body,
      kind: kind,
      anchor: anchor,
      mentions: mentions,
      parentId: parentId,
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
  Future<Result<List<EditSuggestion>>> suggestions(String storyId) =>
      guardResult(() => _remote.suggestions(storyId));

  @override
  Future<Result<EditSuggestion>> addSuggestion({
    required String storyId,
    required String originalText,
    required String suggestedText,
    String? blockId,
    String? rationale,
  }) => guardResult(
    () => _remote.addSuggestion(
      storyId: storyId,
      originalText: originalText,
      suggestedText: suggestedText,
      blockId: blockId,
      rationale: rationale,
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
  Future<Result<List<CollaborationActivityEntry>>> activity(String storyId) =>
      guardResult(() => _remote.activity(storyId));

  @override
  Future<Result<List<PresenceEntry>>> presence(String storyId) =>
      guardResult(() => _remote.presence(storyId));

  @override
  Future<Result<Unit>> heartbeat({
    required String storyId,
    required String state,
    String? blockId,
  }) => guardUnit(
    () => _remote.heartbeat(storyId: storyId, state: state, blockId: blockId),
  );
}
