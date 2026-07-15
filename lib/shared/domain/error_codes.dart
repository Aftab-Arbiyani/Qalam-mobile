/// Error-code catalogue — a Dart mirror of `@qalam/shared` `error-codes.ts`
/// (the frozen `v1` `error.code` half of the envelope). Clients branch on these
/// stable strings, NEVER on `error.message` (docs/40 §21).
///
/// This list is append-only on the backend, so a value never disappears; a new
/// server code simply isn't matched here yet and maps to a generic failure.
library;

/// The named server error codes plus the client-synthesized transport codes.
abstract final class ErrorCodes {
  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String authInvalidCredentials = 'AUTH_INVALID_CREDENTIALS';
  static const String authTokenExpired = 'AUTH_TOKEN_EXPIRED';
  static const String authTokenInvalid = 'AUTH_TOKEN_INVALID';
  static const String authRefreshReused = 'AUTH_REFRESH_REUSED';
  static const String authSessionRevoked = 'AUTH_SESSION_REVOKED';
  static const String authEmailTaken = 'AUTH_EMAIL_TAKEN';
  static const String authEmailUnverified = 'AUTH_EMAIL_UNVERIFIED';
  static const String authVerificationInvalid = 'AUTH_VERIFICATION_INVALID';
  static const String authEmailAlreadyVerified = 'AUTH_EMAIL_ALREADY_VERIFIED';
  static const String authResetInvalid = 'AUTH_RESET_INVALID';
  static const String authPasswordWeak = 'AUTH_PASSWORD_WEAK';
  static const String authCurrentPasswordInvalid =
      'AUTH_CURRENT_PASSWORD_INVALID';
  static const String authOauthFailed = 'AUTH_OAUTH_FAILED';
  static const String authOauthStateInvalid = 'AUTH_OAUTH_STATE_INVALID';
  static const String authAccountSuspended = 'AUTH_ACCOUNT_SUSPENDED';
  static const String authPermissionDenied = 'AUTH_PERMISSION_DENIED';

  // ── Users / profiles ────────────────────────────────────────────────────
  static const String userNotFound = 'USER_NOT_FOUND';
  static const String userUsernameTaken = 'USER_USERNAME_TAKEN';
  static const String userUsernameImmutable = 'USER_USERNAME_IMMUTABLE';
  static const String userPrivateAccount = 'USER_PRIVATE_ACCOUNT';
  static const String userCannotFollowSelf = 'USER_CANNOT_FOLLOW_SELF';
  static const String profileForbidden = 'PROFILE_FORBIDDEN';
  static const String languageInvalid = 'LANGUAGE_INVALID';
  static const String genreInvalid = 'GENRE_INVALID';

  // ── Follow graph ──────────────────────────────────────────────────────────
  static const String followAlreadyExists = 'FOLLOW_ALREADY_EXISTS';
  static const String followRequestPending = 'FOLLOW_REQUEST_PENDING';
  static const String followNotFound = 'FOLLOW_NOT_FOUND';
  static const String followRequestNotFound = 'FOLLOW_REQUEST_NOT_FOUND';

  // ── Pieces ────────────────────────────────────────────────────────────────
  static const String pieceNotFound = 'PIECE_NOT_FOUND';
  static const String pieceForbidden = 'PIECE_FORBIDDEN';
  static const String pieceScheduleInPast = 'PIECE_SCHEDULE_IN_PAST';
  static const String pieceAlreadyPublished = 'PIECE_ALREADY_PUBLISHED';
  static const String pieceNotPublished = 'PIECE_NOT_PUBLISHED';
  static const String pieceInvalidTransition = 'PIECE_INVALID_TRANSITION';
  static const String pieceIncomplete = 'PIECE_INCOMPLETE';
  static const String pieceContentInvalid = 'PIECE_CONTENT_INVALID';
  static const String pieceTagLimitExceeded = 'PIECE_TAG_LIMIT_EXCEEDED';

  // ── Engagement ────────────────────────────────────────────────────────────
  static const String clapLimitReached = 'CLAP_LIMIT_REACHED';
  static const String commentNotFound = 'COMMENT_NOT_FOUND';
  static const String commentForbidden = 'COMMENT_FORBIDDEN';
  static const String commentDepthExceeded = 'COMMENT_DEPTH_EXCEEDED';
  static const String commentDeleted = 'COMMENT_DELETED';
  static const String collectionNotFound = 'COLLECTION_NOT_FOUND';
  static const String collectionNameTaken = 'COLLECTION_NAME_TAKEN';
  static const String collectionPieceExists = 'COLLECTION_PIECE_EXISTS';
  static const String collectionPieceNotFound = 'COLLECTION_PIECE_NOT_FOUND';
  static const String collectionDefaultImmutable =
      'COLLECTION_DEFAULT_IMMUTABLE';
  static const String responseToSelf = 'RESPONSE_TO_SELF';
  static const String responseAlreadyExists = 'RESPONSE_ALREADY_EXISTS';

  // ── Feeds / search ──────────────────────────────────────────────────────
  static const String feedInvalidCursor = 'FEED_INVALID_CURSOR';
  static const String searchQueryTooShort = 'SEARCH_QUERY_TOO_SHORT';
  static const String searchUnavailable = 'SEARCH_UNAVAILABLE';
  static const String searchRecentNotFound = 'SEARCH_RECENT_NOT_FOUND';

  // ── Notifications ─────────────────────────────────────────────────────────
  static const String notificationNotFound = 'NOTIFICATION_NOT_FOUND';
  static const String systemNotificationNotFound =
      'SYSTEM_NOTIFICATION_NOT_FOUND';

  // ── Moderation ────────────────────────────────────────────────────────────
  static const String reportNotFound = 'REPORT_NOT_FOUND';
  static const String reportAlreadyResolved = 'REPORT_ALREADY_RESOLVED';
  static const String reportTargetNotFound = 'REPORT_TARGET_NOT_FOUND';
  static const String reportSelf = 'REPORT_SELF';
  static const String reportDuplicate = 'REPORT_DUPLICATE';
  static const String reportInvalidResolution = 'REPORT_INVALID_RESOLUTION';
  static const String appealNotAllowed = 'APPEAL_NOT_ALLOWED';
  static const String appealNotFound = 'APPEAL_NOT_FOUND';
  static const String appealAlreadyExists = 'APPEAL_ALREADY_EXISTS';
  static const String appealAlreadyReviewed = 'APPEAL_ALREADY_REVIEWED';

  // ── Media ───────────────────────────────────────────────────────────────
  static const String mediaTypeUnsupported = 'MEDIA_TYPE_UNSUPPORTED';
  static const String mediaTooLarge = 'MEDIA_TOO_LARGE';

  // ── System settings / flags ───────────────────────────────────────────────
  static const String settingNotFound = 'SETTING_NOT_FOUND';
  static const String settingNotEditable = 'SETTING_NOT_EDITABLE';
  static const String settingInvalidValue = 'SETTING_INVALID_VALUE';
  static const String featureFlagNotFound = 'FEATURE_FLAG_NOT_FOUND';
  static const String featureFlagAlreadyExists = 'FEATURE_FLAG_ALREADY_EXISTS';

  // ── Infra / admin ─────────────────────────────────────────────────────────
  static const String queueNotFound = 'QUEUE_NOT_FOUND';
  static const String jobNotFound = 'JOB_NOT_FOUND';
  static const String jobNotRetryable = 'JOB_NOT_RETRYABLE';

  // ── Cross-cutting ─────────────────────────────────────────────────────────
  static const String rateLimited = 'RATE_LIMITED';
  static const String validationFailed = 'VALIDATION_FAILED';
  static const String unauthorized = 'UNAUTHORIZED';
  static const String forbidden = 'FORBIDDEN';
  static const String notFound = 'NOT_FOUND';
  static const String conflict = 'CONFLICT';
  static const String internalServerError = 'INTERNAL_SERVER_ERROR';

  // ── Client-synthesized transport codes (never from the server) ──────────────
  static const String apiTimeout = 'API_TIMEOUT';
  static const String apiOffline = 'API_OFFLINE';
  static const String apiNetworkError = 'API_NETWORK_ERROR';
  static const String apiMalformedResponse = 'API_MALFORMED_RESPONSE';
  static const String apiCancelled = 'API_CANCELLED';
  static const String apiUnexpected = 'API_UNEXPECTED_ERROR';
}
