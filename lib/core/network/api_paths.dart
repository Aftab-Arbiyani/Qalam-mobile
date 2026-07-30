/// Endpoint path constants for the frozen `v1` API (docs/40 §9, §14.1).
///
/// These are PATHS ONLY — never DTOs or request/response bodies (those are
/// generated from `openapi.json`, docs/40 §18). Paths are relative to
/// `AppConfig.apiBaseUrl` (`{apiUrl}/api/v1`). M1 uses only the auth-refresh and
/// health paths; the rest are declared so M2–M10 reference constants, not
/// stringly-typed literals.
library;

abstract final class ApiPaths {
  // Auth.
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';
  static const String authLogoutAll = '/auth/logout-all';
  static const String authVerifyEmail = '/auth/verify-email';
  static const String authResendVerification = '/auth/resend-verification';
  static const String authForgotPassword = '/auth/forgot-password';
  static const String authResetPassword = '/auth/reset-password';
  static const String authChangePassword = '/auth/change-password';
  static const String authGoogle = '/auth/google';
  static const String authGoogleExchange = '/auth/google/exchange';

  // Identity / profiles.
  static const String me = '/me';
  static String userByUsername(String username) => '/users/$username';

  // Profile media uploads (M5, docs/40 §34.3). Dedicated multipart endpoints on
  // the profiles controller — distinct from the piece-cover upload; the server
  // re-encodes (avatar → 512² WebP, cover → 1500×500 WebP) and returns `{ key }`.
  static const String profileAvatar = '/profile/avatar';
  static const String profileCover = '/profile/cover';

  // Pieces.
  static const String pieces = '/pieces';
  static String pieceById(String id) => '/pieces/$id';

  // AI platform (AF1, Phase 2). Additive `/ai/*` surface; the client never calls
  // a provider directly (docs/34). Streaming completion is SSE.
  static const String aiFeatures = '/ai/features';
  static const String aiModels = '/ai/models';
  static const String aiConfig = '/ai/config';
  static const String aiUsageMe = '/ai/usage/me';
  static const String aiCompletions = '/ai/completions';
  static const String aiCompletionsStream = '/ai/completions/stream';
  static const String aiConversations = '/ai/conversations';
  static String aiConversationById(String id) => '/ai/conversations/$id';
  static String aiConversationExport(String id) =>
      '/ai/conversations/$id/export';

  // AI discovery / search / recommendation (AF4). Additive `/ai/*` surface consumed by
  // the discovery/search/ask/explorer/recommendation screens (docs 36).
  static const String aiSearch = '/ai/search';
  static const String aiSearchSuggestions = '/ai/search/suggestions';
  static const String aiSearchSaved = '/ai/search/saved';
  static String aiSearchSavedById(String id) => '/ai/search/saved/$id';
  static const String aiAsk = '/ai/ask';
  static const String aiAskStream = '/ai/ask/stream';
  static String aiExplorer(String storyId, String view) =>
      '/ai/explorer/$storyId/$view';
  static const String aiRecommendations = '/ai/recommendations';

  // Monetization (AF5, Phase 2). Additive `/monetization/*` surface: entitlements
  // (the server-authoritative premium-access source of truth the client gates on),
  // subscription lifecycle, usage/credits, billing history, purchases, coupons.
  static const String monetizationPlans = '/monetization/plans';
  static const String monetizationEntitlements = '/monetization/entitlements';
  static String monetizationEntitlement(String feature) =>
      '/monetization/entitlements/$feature';
  static const String monetizationSubscription = '/monetization/subscription';
  static const String monetizationSubscriptionChange =
      '/monetization/subscription/change';
  static const String monetizationSubscriptionCancel =
      '/monetization/subscription/cancel';
  static const String monetizationSubscriptionReactivate =
      '/monetization/subscription/reactivate';
  static const String monetizationSubscriptionPause =
      '/monetization/subscription/pause';
  static const String monetizationSubscriptionResume =
      '/monetization/subscription/resume';
  static const String monetizationSubscriptionHistory =
      '/monetization/subscription/history';
  static const String monetizationUsage = '/monetization/usage';
  static const String monetizationCredits = '/monetization/credits';
  static const String monetizationCreditTransactions =
      '/monetization/credits/transactions';
  static const String monetizationCreditPurchase =
      '/monetization/credits/purchase';
  static const String monetizationInvoices = '/monetization/invoices';
  static const String monetizationPayments = '/monetization/payments';
  static const String monetizationPurchases = '/monetization/purchases';
  static const String monetizationPurchasesRestore =
      '/monetization/purchases/restore';
  static const String monetizationCouponsValidate =
      '/monetization/coupons/validate';

  // Collaboration / Publishing / Trust (AF6, Phase 2). Additive story-scoped surface:
  // membership + the server-authoritative capability map the client gates affordances
  // on, invitations, threaded comments + edit suggestions, presence + activity, the
  // publish/review workflow + snapshots, and the caller's trust standing + blocks.
  static String storyMembers(String id) => '/stories/$id/members';
  static String storyMember(String id, String userId) =>
      '/stories/$id/members/$userId';
  static String storyLeave(String id) => '/stories/$id/leave';
  static String storyCapabilities(String id) => '/stories/$id/capabilities';
  static String storyInvitations(String id) => '/stories/$id/invitations';
  static const String meInvitations = '/me/invitations';
  static String invitationAccept(String id) => '/invitations/$id/accept';
  static String invitationDecline(String id) => '/invitations/$id/decline';
  static String invitation(String id) => '/invitations/$id';
  static String storyComments(String id) => '/stories/$id/comments';
  static String collaborationCommentReplies(String id) =>
      '/comments/$id/replies';
  static String collaborationCommentThread(String id) => '/comments/$id/thread';
  static String collaborationCommentResolve(String id) =>
      '/comments/$id/resolve';
  static String collaborationComment(String id) => '/comments/$id';
  static String storySuggestions(String id) => '/stories/$id/suggestions';
  static String suggestionAccept(String id) => '/suggestions/$id/accept';
  static String suggestionReject(String id) => '/suggestions/$id/reject';
  static String suggestionWithdraw(String id) => '/suggestions/$id/withdraw';
  static String storyActivity(String id) => '/stories/$id/activity';
  static String storyPresence(String id) => '/stories/$id/presence';
  // Publishing.
  static String storyPublish(String id) => '/stories/$id/publish';
  static String storyUnpublish(String id) => '/stories/$id/unpublish';
  static String storySchedule(String id) => '/stories/$id/schedule';
  static String storyVisibility(String id) => '/stories/$id/visibility';
  static String storyReview(String id) => '/stories/$id/review';
  static String storyReviewApprove(String id) => '/stories/$id/review/approve';
  static String storyReviewChanges(String id) => '/stories/$id/review/changes';
  static String storySnapshots(String id) => '/stories/$id/snapshots';
  static String snapshot(String id) => '/snapshots/$id';
  static String storySnapshotRevert(String id, String snapshotId) =>
      '/stories/$id/snapshots/$snapshotId/revert';
  static String storyPublicationHistory(String id) =>
      '/stories/$id/publication-history';
  // Trust & safety.
  static const String meTrust = '/me/trust';
  static const String meBlocks = '/me/blocks';
  static String userBlock(String id) => '/users/$id/block';
  static String userMute(String id) => '/users/$id/mute';

  // Authoring / drafts (M4, docs/40 §47 M6). Lifecycle is driven by dedicated
  // action endpoints — `status`/`slug`/`scheduledAt` are never writable fields.
  static const String meDrafts = '/me/drafts';
  static const String mePieces = '/me/pieces';
  static String piecePublish(String id) => '/pieces/$id/publish';
  static String pieceSchedule(String id) => '/pieces/$id/schedule';
  static String pieceCover(String id) => '/pieces/$id/cover';

  // Reading engagement (docs/40 §21.4). Counts + viewer flags, like/bookmark,
  // share, responses.
  static String pieceEngagement(String id) => '/pieces/$id/engagement';
  static String pieceLikes(String id) => '/pieces/$id/likes';
  static String pieceBookmarks(String id) => '/pieces/$id/bookmarks';
  static String pieceShares(String id) => '/pieces/$id/shares';
  static String pieceResponses(String id) => '/pieces/$id/responses';
  static const String meBookmarks = '/me/bookmarks';

  // Comments & replies (E7). Top-level comments live under a piece; replies and
  // edit/delete key on the comment id.
  static String pieceComments(String id) => '/pieces/$id/comments';
  static String commentReplies(String id) => '/comments/$id/replies';
  static String comment(String id) => '/comments/$id';

  // Collections & reading lists (E7). Owner-only in Phase 1.
  static const String collections = '/collections';
  static String collection(String id) => '/collections/$id';
  static String collectionPieces(String id) => '/collections/$id/pieces';
  static String collectionPiece(String id, String pieceId) =>
      '/collections/$id/pieces/$pieceId';

  // Follow graph (follow/unfollow key on the target USER UUID; lists key on the
  // username; requests key on the follow-edge id, docs §follows).
  static String userFollow(String userId) => '/users/$userId/follow';
  static String userFollowers(String username) => '/users/$username/followers';
  static String userFollowing(String username) => '/users/$username/following';
  static const String meFollowRequests = '/me/follow-requests';
  static String followRequestAccept(String id) => '/follow-requests/$id/accept';
  static String followRequestReject(String id) => '/follow-requests/$id/reject';

  // Moderation.
  static const String reports = '/reports';

  // Reading analytics beacons (fire-and-forget, docs/40 §30.1).
  static String analyticsView(String id) => '/analytics/pieces/$id/view';
  static String analyticsRead(String id) => '/analytics/pieces/$id/read';

  // Feed / discover. Feeds are route-per-tab: /feed/{following,latest,trending,
  // discover}. `following` requires JWT; the rest are public.
  static String feed(String tab) => '/feed/$tab';
  static const String discoverPieces = '/discover/pieces';
  static const String discoverWriters = '/discover/writers';
  static const String discoverTags = '/discover/tags';
  static const String discoverGenres = '/discover/genres';
  static const String discoverLanguages = '/discover/languages';

  // Search (E8). Grouped preview, per-type paginated searches, autocomplete,
  // trending, and recent-search management.
  static const String search = '/search';
  static const String searchPieces = '/search/pieces';
  static const String searchWriters = '/search/writers';
  static const String searchTags = '/search/tags';
  static const String searchGenres = '/search/genres';
  static const String searchLanguages = '/search/languages';
  static const String searchAutocomplete = '/search/autocomplete';
  static const String searchTrending = '/search/trending';
  static const String searchRecent = '/search/recent';
  static String searchRecentById(String id) => '/search/recent/$id';

  // Notifications (M8, docs/40 §32). Inbox is cursor-paginated; per-item actions
  // key on the notification UUID. Read/read-all/archive are PATCH→204; delete is
  // a DELETE→204 soft-delete. Preferences is a single non-paginated object with a
  // partial PATCH (no PUT). Push/FCM device-token registration is a Phase-2 seam
  // with no backend endpoint yet (docs/40 §32.2), so no path is declared for it.
  static const String notifications = '/notifications';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static const String notificationsReadAll = '/notifications/read-all';
  static String notificationRead(String id) => '/notifications/$id/read';
  static String notificationArchive(String id) => '/notifications/$id/archive';
  static String notification(String id) => '/notifications/$id';
  static const String notificationPreferences = '/notification-preferences';

  // Analytics (M9). Self-scoped creator + reader aggregates and the growth series.
  // `me` and `readers/me` are LIFETIME (no range param); the growth series is the
  // only range knob a creator has (`?period=&points=`, docs/40 §30).
  static const String analyticsDashboard = '/analytics/dashboard';
  static const String analyticsMe = '/analytics/me';
  static const String analyticsMeGrowth = '/analytics/me/growth';
  static const String analyticsReadersMe = '/analytics/readers/me';
  static String analyticsPiece(String id) => '/analytics/pieces/$id';

  /// Auth-corridor prefix — requests under it are exempt from the 401→refresh
  /// interceptor (a failed login/refresh is the caller's to handle, docs/40 §15).
  static const String authPrefix = '/auth/';
}
