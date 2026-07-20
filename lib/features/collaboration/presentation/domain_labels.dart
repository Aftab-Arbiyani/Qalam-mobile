/// Human labels for collaboration enum values (AF6) — presentation only. Kept pure so
/// screens never branch on raw wire strings for display copy.
library;

import '../domain/entities/collaboration_enums.dart';

String roleLabel(String role) => switch (role) {
  StoryRole.owner => 'Owner',
  StoryRole.coAuthor => 'Co-author',
  StoryRole.editor => 'Editor',
  StoryRole.reviewer => 'Reviewer',
  StoryRole.betaReader => 'Beta reader',
  _ => role,
};

String invitationStatusLabel(String status) => switch (status) {
  InvitationStatus.pending => 'Pending',
  InvitationStatus.accepted => 'Accepted',
  InvitationStatus.declined => 'Declined',
  InvitationStatus.revoked => 'Revoked',
  InvitationStatus.expired => 'Expired',
  _ => status,
};

String commentKindLabel(String kind) => switch (kind) {
  CommentKind.general => 'Comment',
  CommentKind.inline => 'Inline note',
  _ => kind,
};

String suggestionStatusLabel(String status) => switch (status) {
  SuggestionStatus.pending => 'Pending',
  SuggestionStatus.accepted => 'Accepted',
  SuggestionStatus.rejected => 'Rejected',
  SuggestionStatus.withdrawn => 'Withdrawn',
  _ => status,
};

String presenceStateLabel(String state) => switch (state) {
  PresenceState.active => 'Active',
  PresenceState.idle => 'Idle',
  PresenceState.typing => 'Typing…',
  _ => state,
};

String reviewStateLabel(String state) => switch (state) {
  ReviewState.draft => 'Draft',
  ReviewState.inReview => 'In review',
  ReviewState.changesRequested => 'Changes requested',
  ReviewState.approved => 'Approved',
  ReviewState.published => 'Published',
  _ => state,
};

String policyEffectLabel(String effect) => switch (effect) {
  PolicyEffect.allow => 'Allowed',
  PolicyEffect.deny => 'Denied',
  PolicyEffect.conditionalAccess => 'Conditional',
  PolicyEffect.requiresReview => 'Requires review',
  PolicyEffect.readOnly => 'Read only',
  PolicyEffect.temporaryRestriction => 'Temporarily restricted',
  PolicyEffect.suspended => 'Suspended',
  PolicyEffect.blocked => 'Blocked',
  PolicyEffect.muted => 'Muted',
  _ => effect,
};

String policyActionLabel(String action) => switch (action) {
  PolicyAction.storyView => 'View story',
  PolicyAction.storyEdit => 'Edit story',
  PolicyAction.storyComment => 'Comment',
  PolicyAction.storySuggest => 'Suggest edits',
  PolicyAction.storyInvite => 'Invite collaborators',
  PolicyAction.storyManageMembers => 'Manage members',
  PolicyAction.commentResolve => 'Resolve comments',
  PolicyAction.suggestionResolve => 'Resolve suggestions',
  PolicyAction.publicationPublish => 'Publish',
  PolicyAction.reviewApprove => 'Approve review',
  _ => action,
};

String trustStatusLabel(String status) => switch (status) {
  TrustStatus.trusted => 'Trusted',
  TrustStatus.normal => 'Good standing',
  TrustStatus.limited => 'Limited',
  TrustStatus.readOnly => 'Read only',
  TrustStatus.muted => 'Muted',
  TrustStatus.shadowed => 'Restricted',
  TrustStatus.suspended => 'Suspended',
  TrustStatus.banned => 'Banned',
  _ => status,
};

String restrictionTypeLabel(String type) => switch (type) {
  RestrictionType.readOnly => 'Read-only',
  RestrictionType.muted => 'Muted',
  RestrictionType.restricted => 'Restricted',
  RestrictionType.shadow => 'Shadow-restricted',
  RestrictionType.suspended => 'Suspended',
  _ => type,
};

String visibilityLabel(String visibility) => switch (visibility) {
  StoryVisibility.private => 'Private',
  StoryVisibility.unlisted => 'Unlisted',
  StoryVisibility.followers => 'Followers',
  StoryVisibility.public => 'Public',
  _ => visibility,
};

/// A short yyyy-mm-dd for timestamps in collaboration surfaces.
String formatCollaborationDate(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
