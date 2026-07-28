/// Collaboration / Publishing / Trust vocabulary (AF6) — a Dart mirror of the
/// `@qalam/shared` collaboration wire strings (values the API returns/accepts).
/// Clients branch on these stable values, never on message text. Server-authoritative:
/// the client uses them to render a HINT (role, lock, restricted state) and always
/// defers to a fresh server response — the policy engine re-checks every action.
library;

/// A collaborator's role on a story (descending capability via [roleRank]).
abstract final class StoryRole {
  static const String owner = 'owner';
  static const String coAuthor = 'co_author';
  static const String editor = 'editor';
  static const String reviewer = 'reviewer';
  static const String betaReader = 'beta_reader';

  /// Most- to least-privileged (owner first).
  static const List<String> ordered = <String>[
    owner,
    coAuthor,
    editor,
    reviewer,
    betaReader,
  ];
}

/// Descending rank of a role (owner = highest; unknown → lowest).
int roleRank(String role) {
  final int i = StoryRole.ordered.indexOf(role);
  return i < 0 ? StoryRole.ordered.length : i;
}

/// Invitation lifecycle state.
abstract final class InvitationStatus {
  static const String pending = 'pending';
  static const String accepted = 'accepted';
  static const String declined = 'declined';
  static const String revoked = 'revoked';
  static const String expired = 'expired';
}

/// Whether a comment is anchored to a passage (inline) or free-standing (general).
abstract final class CommentKind {
  static const String general = 'general';
  static const String inline = 'inline';
}

/// Comment thread resolution state.
abstract final class CommentStatus {
  static const String open = 'open';
  static const String resolved = 'resolved';
}

/// Edit-suggestion lifecycle state.
abstract final class SuggestionStatus {
  static const String pending = 'pending';
  static const String accepted = 'accepted';
  static const String rejected = 'rejected';
  static const String withdrawn = 'withdrawn';
}

/// A collaborator's live presence state.
abstract final class PresenceState {
  static const String active = 'active';
  static const String idle = 'idle';
  static const String typing = 'typing';
}

/// Publication review workflow state.
abstract final class ReviewState {
  static const String draft = 'draft';
  static const String inReview = 'in_review';
  static const String changesRequested = 'changes_requested';
  static const String approved = 'approved';
  static const String published = 'published';
}

/// The effect a policy decision resolves to (what a capability gate reads).
abstract final class PolicyEffect {
  static const String allow = 'allow';
  static const String deny = 'deny';
  static const String conditionalAccess = 'conditional_access';
  static const String requiresReview = 'requires_review';
  static const String readOnly = 'read_only';
  static const String temporaryRestriction = 'temporary_restriction';
  static const String suspended = 'suspended';
  static const String blocked = 'blocked';
  static const String muted = 'muted';
}

/// The account's trust standing (the coarse gate the app renders restricted UX on).
abstract final class TrustStatus {
  static const String trusted = 'trusted';
  static const String normal = 'normal';
  static const String limited = 'limited';
  static const String readOnly = 'read_only';
  static const String muted = 'muted';
  static const String shadowed = 'shadowed';
  static const String suspended = 'suspended';
  static const String banned = 'banned';
}

/// The surface a restriction applies to (`RestrictionScope`). `global` covers all.
abstract final class RestrictionScope {
  static const String global = 'global';
  static const String publishing = 'publishing';
  static const String collaboration = 'collaboration';
  static const String comments = 'comments';
  static const String reporting = 'reporting';
}

/// The concrete restriction placed on an account.
abstract final class RestrictionType {
  static const String readOnly = 'read_only';
  static const String muted = 'muted';
  static const String restricted = 'restricted';
  static const String shadow = 'shadow';
  static const String suspended = 'suspended';
}

/// Policy actions the capability map keys on (`GET /stories/{id}/capabilities`).
///
/// The action set is chosen **by the server**: the endpoint takes only `:storyId`
/// (no query, no body) and `MembershipService.getCapabilities` passes the
/// module-local `COLLABORATION_CAPABILITY_ACTIONS` to `PolicyEngineService.explain`.
/// A client cannot ask for more actions than that constant lists — so these
/// strings are a *mirror for keying decisions*, never a request.
abstract final class PolicyAction {
  static const String storyView = 'story.view';
  static const String storyEdit = 'story.edit';
  static const String storyComment = 'story.comment';
  static const String storySuggest = 'story.suggest';
  static const String storyInvite = 'story.invite';
  static const String storyManageMembers = 'story.manage_members';
  static const String storyManageRoles = 'story.manage_roles';
  static const String commentResolve = 'comment.resolve';
  static const String commentDelete = 'comment.delete';
  static const String suggestionResolve = 'suggestion.resolve';
  static const String publicationPublish = 'publication.publish';
  static const String reviewApprove = 'review.approve';

  /// Exactly what `COLLABORATION_CAPABILITY_ACTIONS` explains today. Keep this in
  /// step with that constant — a gate keyed on anything absent here gets no
  /// decision and default-denies (`PolicyCapability.deny`, reason `no_policy`).
  static const List<String> serverExplained = <String>[
    storyView,
    storyComment,
    storySuggest,
    storyInvite,
    storyManageMembers,
    storyManageRoles,
    commentResolve,
    commentDelete,
    suggestionResolve,
  ];

  /// Real, rule-governed actions (`ACTION_MIN_STORY_ROLE` in `policy.constants.ts`)
  /// that the capabilities endpoint does **not** explain, so no client can gate on
  /// them yet. The publishing screen's five gates key on these three: they render
  /// nothing until `COLLABORATION_CAPABILITY_ACTIONS` grows to include them
  /// (defect **C-2**, `docs/56` §2.1 — a backend change, tracked there).
  static const List<String> notExplainedByServer = <String>[
    storyEdit,
    publicationPublish,
    reviewApprove,
  ];
}

/// Story publication visibility — a mirror of `Visibility` in
/// `packages/shared/src/enums.ts`, which is the complete set the server accepts
/// (`ChangeVisibilityDto` is `@IsIn(Object.values(Visibility))`).
///
/// There is no `followers` value. One used to be listed here and the publish card
/// rendered a chip per entry, so tapping "Followers" sent a visibility the enum does
/// not contain and got `400 VALIDATION_FAILED` (defect **P-3**, `docs/56` §2.2).
/// Followers-only visibility is a *profile* privacy setting, not a piece visibility.
abstract final class StoryVisibility {
  static const String private = 'private';
  static const String unlisted = 'unlisted';
  static const String public = 'public';

  static const List<String> ordered = <String>[private, unlisted, public];
}
