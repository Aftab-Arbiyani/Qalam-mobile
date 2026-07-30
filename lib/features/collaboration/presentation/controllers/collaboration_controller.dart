/// Collaboration write-side controller (AF6). Each action drives the repository,
/// reflects a busy/error state via [AsyncValue], and invalidates the affected read
/// providers on success so members / comments / suggestions / invitations refresh
/// immediately. The policy engine is authoritative — a denied action still fails
/// server-side even when the client optimistically showed the affordance.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/collaboration_comment.dart';
import '../../domain/entities/collaboration_enums.dart';
import '../../domain/entities/edit_suggestion.dart';
import '../../domain/entities/invitee_candidate.dart';
import '../../domain/entities/story_invitation.dart';
import '../../domain/entities/story_member.dart';
import '../../domain/entities/text_anchor.dart';
import '../../domain/repositories/collaboration_repository.dart';
import '../providers/collaboration_providers.dart';

part 'collaboration_controller.g.dart';

@riverpod
class CollaborationController extends _$CollaborationController {
  @override
  Future<void> build() async {}

  CollaborationRepository get _repo =>
      ref.read(collaborationRepositoryProvider);

  // ── Members ────────────────────────────────────────────────────────────────
  Future<StoryMember?> addMember({
    required String storyId,
    required String userId,
    required String role,
  }) => _run(
    () => _repo.addMember(storyId: storyId, userId: userId, role: role),
    _refreshMembers,
  );

  Future<StoryMember?> changeRole({
    required String storyId,
    required String userId,
    required String role,
  }) => _run(
    () => _repo.changeRole(storyId: storyId, userId: userId, role: role),
    _refreshMembers,
  );

  Future<bool> removeMember({
    required String storyId,
    required String userId,
  }) => _mutate(
    () => _repo.removeMember(storyId: storyId, userId: userId),
    _refreshMembers,
  );

  Future<bool> leave(String storyId) =>
      _mutate(() => _repo.leave(storyId), _refreshMembers);

  // ── Invitations ──────────────────────────────────────────────────────────────
  /// Resolve a typed `@handle` to the person behind it, so the sheet can confirm *who* is being
  /// invited and hand the contract the `inviteeId` it requires (defect M-1).
  Future<InviteeCandidate?> resolveInvitee(String username) =>
      _run(() => _repo.resolveInvitee(username), null);

  /// Invite by **user id**. The old signature took an `email`, which the contract cannot accept.
  Future<StoryInvitation?> invite({
    required String storyId,
    required String inviteeId,
    required String role,
  }) => _run(
    () => _repo.invite(storyId: storyId, inviteeId: inviteeId, role: role),
    () => ref.invalidate(storyInvitationsProvider),
  );

  /// Accepting yields the new **member** (the endpoint returns `MemberDto`). Refreshes the
  /// invitation list *and* the story's members, since the viewer just joined.
  Future<StoryMember?> acceptInvitation(String invitationId) =>
      _run(() => _repo.acceptInvitation(invitationId), () {
        _refreshInvitations();
        // The viewer just became a collaborator, so the roster moved too.
        _refreshMembers();
      });

  Future<StoryInvitation?> declineInvitation(String invitationId) =>
      _run(() => _repo.declineInvitation(invitationId), _refreshInvitations);

  Future<bool> revokeInvitation(String invitationId) =>
      _mutate(() => _repo.revokeInvitation(invitationId), _refreshInvitations);

  // ── Comments ──────────────────────────────────────────────────────────────────
  Future<CollaborationComment?> addComment({
    required String storyId,
    required String body,
    String kind = CommentKind.general,
    TextAnchor? anchor,
    List<String> mentions = const <String>[],
  }) => _run(
    () => _repo.addComment(
      storyId: storyId,
      body: body,
      kind: kind,
      anchor: anchor,
      mentions: mentions,
    ),
    () => ref.invalidate(storyCommentsProvider),
  );

  Future<CollaborationComment?> replyToComment({
    required String commentId,
    required String body,
    List<String> mentions = const <String>[],
  }) => _run(
    () => _repo.replyToComment(
      commentId: commentId,
      body: body,
      mentions: mentions,
    ),
    () => ref.invalidate(storyCommentsProvider),
  );

  Future<CollaborationComment?> resolveComment(String commentId) => _run(
    () => _repo.resolveComment(commentId),
    () => ref.invalidate(storyCommentsProvider),
  );

  Future<bool> deleteComment(String commentId) => _mutate(
    () => _repo.deleteComment(commentId),
    () => ref.invalidate(storyCommentsProvider),
  );

  // ── Suggestions ────────────────────────────────────────────────────────────────
  /// Propose an edit. [anchor] is required: `CreateSuggestionDto.anchor` is, and
  /// omitting it was a guaranteed 400 (C-3).
  Future<EditSuggestion?> addSuggestion({
    required String storyId,
    required TextAnchor anchor,
    required String originalText,
    required String suggestedText,
  }) => _run(
    () => _repo.addSuggestion(
      storyId: storyId,
      anchor: anchor,
      originalText: originalText,
      suggestedText: suggestedText,
    ),
    () => ref.invalidate(storySuggestionsProvider),
  );

  Future<EditSuggestion?> acceptSuggestion(String suggestionId) =>
      _run(() => _repo.acceptSuggestion(suggestionId), _refreshSuggestions);

  Future<EditSuggestion?> rejectSuggestion(String suggestionId) =>
      _run(() => _repo.rejectSuggestion(suggestionId), _refreshSuggestions);

  Future<EditSuggestion?> withdrawSuggestion(String suggestionId) =>
      _run(() => _repo.withdrawSuggestion(suggestionId), _refreshSuggestions);

  // ── Presence ──────────────────────────────────────────────────────────────────
  Future<bool> heartbeat({
    required String storyId,
    String state = PresenceState.active,
  }) => _mutate(
    () => _repo.heartbeat(storyId: storyId, state: state),
    () => ref.invalidate(storyPresenceProvider),
  );

  // ── Internals ────────────────────────────────────────────────────────────────

  /// Run an action that returns a value; tracks busy/error state and refreshes reads
  /// on success. Returns the value, or null on failure (state carries the error).
  /// [onOk] is optional — a pure read (e.g. resolving a handle) has nothing to invalidate.
  Future<T?> _run<T>(
    Future<Result<T>> Function() op,
    void Function()? onOk,
  ) async {
    state = const AsyncValue<void>.loading();
    final Result<T> result = await op();
    switch (result) {
      case Ok<T>(:final T value):
        state = const AsyncValue<void>.data(null);
        onOk?.call();
        return value;
      case Err<T>(:final Failure failure):
        state = AsyncValue<void>.error(failure, StackTrace.current);
        return null;
    }
  }

  /// Run a void mutation; returns true on success.
  Future<bool> _mutate(
    Future<Result<Object?>> Function() op,
    void Function() onOk,
  ) async {
    state = const AsyncValue<void>.loading();
    final Result<Object?> result = await op();
    switch (result) {
      case Ok<Object?>():
        state = const AsyncValue<void>.data(null);
        onOk();
        return true;
      case Err<Object?>(:final Failure failure):
        state = AsyncValue<void>.error(failure, StackTrace.current);
        return false;
    }
  }

  void _refreshMembers() {
    ref.invalidate(storyMembersProvider);
    ref.invalidate(storyCapabilitiesProvider);
  }

  void _refreshInvitations() {
    ref.invalidate(myInvitationsProvider);
    ref.invalidate(storyInvitationsProvider);
    ref.invalidate(storyMembersProvider);
  }

  void _refreshSuggestions() {
    ref.invalidate(storySuggestionsProvider);
    ref.invalidate(storyCapabilitiesProvider);
  }
}
