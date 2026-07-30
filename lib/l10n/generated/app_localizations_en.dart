// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Qalam';

  @override
  String get navFeed => 'Feed';

  @override
  String get navSearch => 'Search';

  @override
  String get navWrite => 'Write';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navProfile => 'Profile';

  @override
  String get actionRetry => 'Try again';

  @override
  String get actionDismiss => 'Dismiss';

  @override
  String get actionClose => 'Close';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionOk => 'OK';

  @override
  String get actionContinue => 'Continue';

  @override
  String get connectivityOffline => 'You\'re offline — showing saved content.';

  @override
  String get connectivityRestored => 'Back online.';

  @override
  String get loadingLabel => 'Loading…';

  @override
  String get errorGenericTitle => 'Something went wrong.';

  @override
  String get errorGenericBody =>
      'We couldn\'t complete that just now. Please try again.';

  @override
  String get errorOfflineTitle => 'You\'re offline.';

  @override
  String get errorOfflineBody => 'Check your connection and try again.';

  @override
  String get errorNotFoundTitle => 'Not found.';

  @override
  String get errorNotFoundBody => 'That page has wandered off.';

  @override
  String get errorUnauthorizedTitle => 'Please sign in.';

  @override
  String get errorUnauthorizedBody => 'You need to be signed in to see that.';

  @override
  String get errorForbiddenTitle => 'Not allowed.';

  @override
  String get errorForbiddenBody => 'You don\'t have access to that.';

  @override
  String errorRequestIdLabel(String requestId) {
    return 'Reference: $requestId';
  }

  @override
  String get emptyGenericTitle => 'Nothing here yet.';

  @override
  String get emptyGenericBody =>
      'When there\'s something to show, it\'ll appear here.';

  @override
  String get unknownRouteTitle => 'Lost the thread.';

  @override
  String get unknownRouteBody => 'This page doesn\'t exist.';

  @override
  String get comingSoonLabel => 'Coming in a later chapter.';

  @override
  String get placeholderFeedBody => 'Your feed will live here.';

  @override
  String get placeholderSearchBody => 'Search will live here.';

  @override
  String get placeholderWriteBody => 'The editor will live here.';

  @override
  String get placeholderNotificationsBody => 'Notifications will live here.';

  @override
  String get placeholderProfileBody => 'Your profile will live here.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsBody =>
      'A protected surface — settings arrive in a later chapter.';

  @override
  String get galleryTitle => 'Design gallery';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get onboardingWelcomeTitle => 'A place for your words';

  @override
  String get onboardingWelcomeBody =>
      'Qalam is a quiet writing sanctuary — warm paper and ink, for Hindi and Urdu writers first.';

  @override
  String get onboardingFeaturesTitle => 'Read and write, beautifully';

  @override
  String get onboardingFeaturesBody =>
      'Follow writers you love, save what moves you, and publish prose that reads the way it should.';

  @override
  String get onboardingPrivacyTitle => 'Your words, your control';

  @override
  String get onboardingPrivacyBody =>
      'You decide what you share. We keep only what we need, and never sell your writing.';

  @override
  String get authLoginTitle => 'Welcome back';

  @override
  String get authLoginSubtitle => 'Sign in to continue writing.';

  @override
  String get authRegisterTitle => 'Create your account';

  @override
  String get authRegisterSubtitle => 'Join a sanctuary for writers.';

  @override
  String get authForgotTitle => 'Reset your password';

  @override
  String get authForgotSubtitle => 'We\'ll send a link to set a new one.';

  @override
  String get authResetTitle => 'Choose a new password';

  @override
  String get authResetSubtitle => 'Set a strong password you\'ll remember.';

  @override
  String get authVerifyTitle => 'Verify your email';

  @override
  String get fieldEmailLabel => 'Email';

  @override
  String get fieldPasswordLabel => 'Password';

  @override
  String get fieldUsernameLabel => 'Username';

  @override
  String get fieldNewPasswordLabel => 'New password';

  @override
  String get fieldConfirmPasswordLabel => 'Confirm password';

  @override
  String get fieldEmailHint => 'you@example.com';

  @override
  String get authUsernameHint => 'Lowercase letters, numbers, and underscores.';

  @override
  String get authUsernamePermanent =>
      'Your username is permanent — choose it with care.';

  @override
  String get actionSignIn => 'Sign in';

  @override
  String get actionCreateAccount => 'Create account';

  @override
  String get actionSendResetLink => 'Send reset link';

  @override
  String get actionResetPassword => 'Reset password';

  @override
  String get actionResend => 'Resend email';

  @override
  String get actionForgotPassword => 'Forgot password?';

  @override
  String get actionSignOut => 'Log out';

  @override
  String get actionSignOutEverywhere => 'Sign out everywhere';

  @override
  String get actionShowPassword => 'Show password';

  @override
  String get actionHidePassword => 'Hide password';

  @override
  String get authRememberMe => 'Keep me signed in';

  @override
  String get authNoAccount => 'New to Qalam?';

  @override
  String get authCreateOne => 'Create an account';

  @override
  String get authHaveAccount => 'Already have an account?';

  @override
  String get authSignInLink => 'Sign in';

  @override
  String get authBackToLogin => 'Back to sign in';

  @override
  String get authOrDivider => 'or';

  @override
  String authContinueWith(String provider) {
    return 'Continue with $provider';
  }

  @override
  String authSocialUnavailable(String provider) {
    return '$provider sign-in isn\'t available in this build yet.';
  }

  @override
  String pwStrengthLabel(String level) {
    return 'Password strength: $level';
  }

  @override
  String get pwStrengthWeak => 'weak';

  @override
  String get pwStrengthFair => 'fair';

  @override
  String get pwStrengthGood => 'good';

  @override
  String get pwStrengthStrong => 'strong';

  @override
  String get validationRequired => 'This field is required.';

  @override
  String get validationEmailInvalid => 'Enter a valid email address.';

  @override
  String get validationUsernameFormat =>
      'Use only lowercase letters, numbers, and underscores.';

  @override
  String get validationUsernameLength => 'Username must be 3–30 characters.';

  @override
  String get validationPasswordTooShort => 'Use at least 10 characters.';

  @override
  String get validationPasswordTooLong =>
      'That\'s too long — 128 characters at most.';

  @override
  String get validationPasswordsMismatch => 'Those passwords don\'t match.';

  @override
  String get validationEmailTaken => 'That email is already registered.';

  @override
  String get validationUsernameTaken => 'That username is already taken.';

  @override
  String get validationPasswordWeak => 'Please choose a stronger password.';

  @override
  String get validationTokenInvalid => 'This link is invalid or has expired.';

  @override
  String get authForgotSentTitle => 'Check your inbox';

  @override
  String authForgotSentBody(String email) {
    return 'If an account exists for $email, a reset link is on its way.';
  }

  @override
  String get authResetDoneTitle => 'Password updated';

  @override
  String get authResetDoneBody => 'Sign in with your new password.';

  @override
  String get authVerifyingLabel => 'Verifying your email…';

  @override
  String get authVerifiedTitle => 'Email verified';

  @override
  String get authVerifiedBody => 'Thank you — your email is confirmed.';

  @override
  String authVerifySentToBody(String email) {
    return 'We sent a verification link to $email. Open it to confirm your account.';
  }

  @override
  String get authVerifyGenericBody =>
      'We sent a verification link to your email. Open it to confirm your account.';

  @override
  String get authVerifyWhyBody =>
      'You can keep using Qalam — some actions need a verified email.';

  @override
  String get authResentBody => 'Sent. Check your inbox again.';

  @override
  String accountSignedInAs(String username) {
    return 'Signed in as @$username';
  }

  @override
  String get accountSignedIn => 'You\'re signed in.';

  @override
  String get accountEmailUnverified => 'Your email isn\'t verified yet.';

  @override
  String get verifyBannerText => 'Verify your email to unlock everything.';

  @override
  String get verifyBannerAction => 'Verify';

  @override
  String get signOutConfirmTitle => 'Sign out everywhere?';

  @override
  String get signOutConfirmBody =>
      'This ends every active session on all your devices.';

  @override
  String get searchHint => 'Search writers, pieces, tags…';

  @override
  String get searchClearTooltip => 'Clear search';

  @override
  String searchTooShortHint(int min) {
    return 'Type at least $min letters to search.';
  }

  @override
  String get searchTabAll => 'All';

  @override
  String get searchTabPieces => 'Pieces';

  @override
  String get searchTabWriters => 'Writers';

  @override
  String get searchTabTags => 'Tags';

  @override
  String get searchTabGenres => 'Genres';

  @override
  String get searchTabLanguages => 'Languages';

  @override
  String get searchSeeAll => 'See all';

  @override
  String get searchEmptyTitle => 'Nothing matched.';

  @override
  String get searchEmptyBody => 'Try a different word, or loosen your filters.';

  @override
  String get searchOfflineResultsBody =>
      'Showing your last results — you\'re offline.';

  @override
  String get searchRecentTitle => 'Recent searches';

  @override
  String get searchRecentClear => 'Clear all';

  @override
  String get searchClearHistoryTitle => 'Clear search history?';

  @override
  String get searchClearHistoryBody =>
      'This removes every recent search on this device.';

  @override
  String get searchTrendingTitle => 'Trending searches';

  @override
  String get searchTrendingTags => 'Trending tags';

  @override
  String get searchSuggestWriters => 'Writers';

  @override
  String get searchSuggestTags => 'Tags';

  @override
  String get searchSuggestGenres => 'Genres';

  @override
  String get searchSuggestPieces => 'Pieces';

  @override
  String get searchFiltersTitle => 'Filters';

  @override
  String get searchFiltersButton => 'Filters';

  @override
  String get searchFilterReset => 'Reset';

  @override
  String get searchFilterApply => 'Show results';

  @override
  String get searchFilterSortLabel => 'Sort by';

  @override
  String get searchFilterLanguageLabel => 'Language';

  @override
  String get searchFilterGenreLabel => 'Genre';

  @override
  String get searchFilterTagLabel => 'Tag';

  @override
  String get searchFilterReadingTimeLabel => 'Reading time';

  @override
  String get searchSortRelevance => 'Most relevant';

  @override
  String get searchSortLatest => 'Newest';

  @override
  String get searchSortTrending => 'Trending';

  @override
  String get searchSortMostClapped => 'Most clapped';

  @override
  String get searchSortMostCommented => 'Most discussed';

  @override
  String get searchReadingAny => 'Any length';

  @override
  String get searchReadingShort => 'Under 5 min';

  @override
  String get searchReadingMedium => '5–15 min';

  @override
  String get searchReadingLong => 'Over 15 min';

  @override
  String get searchDiscoverFeatured => 'Featured';

  @override
  String get searchDiscoverRecent => 'Recently published';

  @override
  String get searchDiscoverPopularWriters => 'Popular writers';

  @override
  String get searchDiscoverPopularGenres => 'Popular genres';

  @override
  String get searchDiscoverContinue => 'Continue discovering';

  @override
  String get searchDiscoverEmptyTitle => 'A quiet beginning.';

  @override
  String get searchDiscoverEmptyBody =>
      'Search above, or come back as the community publishes.';

  @override
  String get searchWriterPrivate => 'Private account';

  @override
  String searchPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pieces',
      one: '1 piece',
      zero: 'No pieces',
    );
    return '$_temp0';
  }

  @override
  String searchFollowerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count followers',
      one: '1 follower',
      zero: 'No followers',
    );
    return '$_temp0';
  }

  @override
  String get followFollow => 'Follow';

  @override
  String get followFollowing => 'Following';

  @override
  String get followRequested => 'Requested';

  @override
  String get followSignInPrompt => 'Sign in to follow writers.';

  @override
  String get socialActionFailed => 'That didn\'t go through. Please try again.';

  @override
  String get socialQueuedOffline =>
      'You\'re offline — we\'ll sync this when you reconnect.';

  @override
  String socialPendingSync(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes waiting to sync',
      one: '1 change waiting to sync',
    );
    return '$_temp0';
  }

  @override
  String get followersTitle => 'Followers';

  @override
  String get followingTitle => 'Following';

  @override
  String get followRequestsTitle => 'Follow requests';

  @override
  String get followRequestsEmptyTitle => 'No pending requests.';

  @override
  String get followRequestsEmptyBody =>
      'When someone asks to follow you, they\'ll appear here.';

  @override
  String get followRequestAccept => 'Accept';

  @override
  String get followRequestReject => 'Decline';

  @override
  String get followersEmptyTitle => 'No followers yet.';

  @override
  String get followersEmptyBody => 'Followers will appear here.';

  @override
  String get followingEmptyTitle => 'Not following anyone yet.';

  @override
  String get followingEmptyBody =>
      'Writers this reader follows will appear here.';

  @override
  String get commentsTitle => 'Comments';

  @override
  String commentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comments',
      one: '1 comment',
      zero: 'No comments',
    );
    return '$_temp0';
  }

  @override
  String get commentComposerHint => 'Add a comment…';

  @override
  String get commentReplyHint => 'Write a reply…';

  @override
  String get commentSend => 'Post';

  @override
  String get commentReply => 'Reply';

  @override
  String get commentEdit => 'Edit';

  @override
  String get commentDelete => 'Delete';

  @override
  String get commentEdited => 'edited';

  @override
  String get commentDeletedTombstone => 'This comment has been deleted.';

  @override
  String commentViewReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'View $count replies',
      one: 'View 1 reply',
    );
    return '$_temp0';
  }

  @override
  String get commentHideReplies => 'Hide replies';

  @override
  String get commentsEmptyTitle => 'No comments yet.';

  @override
  String get commentsEmptyBody => 'Be the first to share a thought.';

  @override
  String get commentSignInPrompt => 'Sign in to join the conversation.';

  @override
  String get commentDeleteConfirmTitle => 'Delete comment?';

  @override
  String get commentDeleteConfirmBody =>
      'This can\'t be undone. Replies stay visible.';

  @override
  String get commentSortNewest => 'Newest';

  @override
  String get commentSortOldest => 'Oldest';

  @override
  String get responsesTitle => 'Responses';

  @override
  String responsesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count responses',
      one: '1 response',
      zero: 'No responses',
    );
    return '$_temp0';
  }

  @override
  String get responseWrite => 'Write a response';

  @override
  String get responsesEmptyTitle => 'No responses yet.';

  @override
  String get responsesEmptyBody =>
      'Start the conversation with your own piece.';

  @override
  String get responseSignInPrompt => 'Sign in to write a response.';

  @override
  String get collectionsTitle => 'Collections';

  @override
  String get collectionsEmptyTitle => 'No collections yet.';

  @override
  String get collectionsEmptyBody =>
      'Create a collection to gather pieces you love.';

  @override
  String get collectionCreate => 'New collection';

  @override
  String get collectionCreateTitle => 'New collection';

  @override
  String get collectionRename => 'Rename';

  @override
  String get collectionDelete => 'Delete';

  @override
  String get collectionNameLabel => 'Name';

  @override
  String get collectionNameHint => 'e.g. Rainy-day ghazals';

  @override
  String get collectionDescriptionLabel => 'Description (optional)';

  @override
  String get collectionMakePrivate => 'Private';

  @override
  String get collectionSave => 'Save';

  @override
  String get collectionDeleteConfirmTitle => 'Delete collection?';

  @override
  String get collectionDeleteConfirmBody =>
      'The pieces stay published — only this collection is removed.';

  @override
  String get collectionEmptyPiecesTitle => 'Nothing saved yet.';

  @override
  String get collectionEmptyPiecesBody =>
      'Pieces you add to this collection will appear here.';

  @override
  String collectionPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pieces',
      one: '1 piece',
      zero: 'Empty',
    );
    return '$_temp0';
  }

  @override
  String get collectionRemovePiece => 'Remove';

  @override
  String get collectionPrivateLabel => 'Private';

  @override
  String get saveToCollectionTitle => 'Save to collection';

  @override
  String saveToCollectionAdded(String name) {
    return 'Saved to $name.';
  }

  @override
  String get saveAction => 'Save';

  @override
  String get reportTitle => 'Report';

  @override
  String get reportPieceTitle => 'Report this piece';

  @override
  String get reportCommentTitle => 'Report this comment';

  @override
  String get reportUserTitle => 'Report this account';

  @override
  String get reportResponseTitle => 'Report this response';

  @override
  String get reportReasonPrompt => 'Why are you reporting this?';

  @override
  String get reportDetailsHint => 'Add any details (optional)';

  @override
  String get reportSubmit => 'Submit report';

  @override
  String get reportSubmitted => 'Thanks — our team will take a look.';

  @override
  String get reportReasonSpam => 'Spam';

  @override
  String get reportReasonHarassment => 'Harassment';

  @override
  String get reportReasonHateSpeech => 'Hate speech';

  @override
  String get reportReasonViolence => 'Violence';

  @override
  String get reportReasonSexualContent => 'Sexual content';

  @override
  String get reportReasonSelfHarm => 'Self-harm';

  @override
  String get reportReasonMisinformation => 'Misinformation';

  @override
  String get reportReasonCopyright => 'Copyright';

  @override
  String get reportReasonImpersonation => 'Impersonation';

  @override
  String get reportReasonOther => 'Something else';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsSettingsTooltip => 'Notification settings';

  @override
  String get notificationsMarkAllRead => 'Mark all read';

  @override
  String get notificationsFilterAll => 'All';

  @override
  String get notificationsFilterUnread => 'Unread';

  @override
  String get notificationsFilterRead => 'Read';

  @override
  String get notificationsFilterArchived => 'Archived';

  @override
  String get notificationsEmptyTitle => 'You\'re all caught up';

  @override
  String get notificationsEmptyBody =>
      'New activity on your writing will appear here.';

  @override
  String get notificationsUnreadEmptyTitle => 'Nothing unread';

  @override
  String get notificationsUnreadEmptyBody => 'You\'ve seen everything for now.';

  @override
  String get notificationsReadEmptyTitle => 'Nothing read yet';

  @override
  String get notificationsReadEmptyBody =>
      'Notifications you\'ve opened will rest here.';

  @override
  String get notificationsArchivedEmptyTitle => 'Your archive is empty';

  @override
  String get notificationsArchivedEmptyBody =>
      'Archived notifications will rest here.';

  @override
  String get notificationsStaleNotice =>
      'Showing saved notifications — you\'re offline.';

  @override
  String notificationsUnreadBadge(int count) {
    return '$count unread notifications';
  }

  @override
  String get notificationActionMarkRead => 'Mark read';

  @override
  String get notificationActionArchive => 'Archive';

  @override
  String get notificationActionDelete => 'Delete';

  @override
  String get notificationDeleted => 'Notification deleted';

  @override
  String get notificationUndo => 'Undo';

  @override
  String get notificationQueuedOffline =>
      'You\'re offline — we\'ll sync this when you\'re back.';

  @override
  String get notificationSectionToday => 'Today';

  @override
  String get notificationSectionYesterday => 'Yesterday';

  @override
  String get notificationSectionEarlier => 'Earlier';

  @override
  String notificationFollow(String name) {
    return '$name started following you.';
  }

  @override
  String notificationFollowRequest(String name) {
    return '$name asked to follow you.';
  }

  @override
  String notificationFollowAccepted(String name) {
    return '$name accepted your follow request.';
  }

  @override
  String notificationLike(String name) {
    return '$name appreciated your piece.';
  }

  @override
  String notificationClap(String name) {
    return '$name applauded your piece.';
  }

  @override
  String notificationComment(String name) {
    return '$name commented on your piece.';
  }

  @override
  String notificationCommentReply(String name) {
    return '$name replied to your comment.';
  }

  @override
  String notificationResponse(String name) {
    return '$name wrote a response to your piece.';
  }

  @override
  String notificationMention(String name) {
    return '$name mentioned you.';
  }

  @override
  String notificationRepost(String name) {
    return '$name shared your piece.';
  }

  @override
  String notificationCollectionFollow(String name) {
    return '$name followed your collection.';
  }

  @override
  String get notificationFeatured => 'Your piece was featured.';

  @override
  String get notificationSystem => 'Announcement';

  @override
  String get notificationGeneric => 'New activity.';

  @override
  String get notificationPrefsTitle => 'Notification preferences';

  @override
  String get notificationPrefsSubtitle => 'Choose what you\'re notified about.';

  @override
  String get notificationPrefFollow => 'Follows';

  @override
  String get notificationPrefFollowDesc => 'New followers and follow requests.';

  @override
  String get notificationPrefComment => 'Comments';

  @override
  String get notificationPrefCommentDesc => 'Comments on your pieces.';

  @override
  String get notificationPrefReply => 'Replies';

  @override
  String get notificationPrefReplyDesc => 'Replies to your comments.';

  @override
  String get notificationPrefReaction => 'Reactions';

  @override
  String get notificationPrefReactionDesc =>
      'Appreciation and applause on your pieces.';

  @override
  String get notificationPrefMention => 'Mentions';

  @override
  String get notificationPrefMentionDesc => 'When someone mentions you.';

  @override
  String get notificationPrefResponse => 'Responses';

  @override
  String get notificationPrefResponseDesc =>
      'Responses written to your pieces.';

  @override
  String get notificationPrefSystem => 'Announcements';

  @override
  String get notificationPrefSystemDesc => 'Service and account updates.';

  @override
  String get settingsNotifications => 'Notifications';
}
