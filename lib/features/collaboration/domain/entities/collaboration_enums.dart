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

/// The concrete restriction placed on an account.
abstract final class RestrictionType {
  static const String readOnly = 'read_only';
  static const String muted = 'muted';
  static const String restricted = 'restricted';
  static const String shadow = 'shadow';
  static const String suspended = 'suspended';
}

/// Policy actions the capability map keys on (`GET /stories/{id}/capabilities`).
abstract final class PolicyAction {
  static const String storyView = 'story.view';
  static const String storyEdit = 'story.edit';
  static const String storyComment = 'story.comment';
  static const String storySuggest = 'story.suggest';
  static const String storyInvite = 'story.invite';
  static const String storyManageMembers = 'story.manage_members';
  static const String commentResolve = 'comment.resolve';
  static const String suggestionResolve = 'suggestion.resolve';
  static const String publicationPublish = 'publication.publish';
  static const String reviewApprove = 'review.approve';

  static const List<String> all = <String>[
    storyView,
    storyEdit,
    storyComment,
    storySuggest,
    storyInvite,
    storyManageMembers,
    commentResolve,
    suggestionResolve,
    publicationPublish,
    reviewApprove,
  ];
}

/// Story publication visibility. Not in the core policy vocab; a client HINT for the
/// publish/visibility controls — the server validates the effective value.
abstract final class StoryVisibility {
  static const String private = 'private';
  static const String unlisted = 'unlisted';
  static const String followers = 'followers';
  static const String public = 'public';

  static const List<String> ordered = <String>[
    private,
    unlisted,
    followers,
    public,
  ];
}
