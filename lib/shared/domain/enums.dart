/// Domain enums — a faithful Dart mirror of `@qalam/shared` `enums.ts`.
///
/// The wire value (`wire`) is the exact string the frozen `v1` API returns and
/// accepts; it is the single source of truth. `fromWire` is tolerant of unknown
/// values (additive-only compatibility, docs/40 §18.2): an unrecognized string
/// resolves to the provided fallback rather than throwing, so a new server enum
/// member never crashes an older client.
library;

/// Lifecycle of a written piece.
enum PieceStatus {
  draft('draft'),
  scheduled('scheduled'),
  published('published'),
  archived('archived');

  const PieceStatus(this.wire);
  final String wire;

  static PieceStatus fromWire(
    String? value, {
    PieceStatus fallback = PieceStatus.draft,
  }) => values.firstWhere((e) => e.wire == value, orElse: () => fallback);
}

/// Who can see a published piece.
enum Visibility {
  public('public'),
  unlisted('unlisted'),
  private('private');

  const Visibility(this.wire);
  final String wire;

  static Visibility fromWire(
    String? value, {
    Visibility fallback = Visibility.public,
  }) => values.firstWhere((e) => e.wire == value, orElse: () => fallback);
}

/// RBAC ladder (`user < moderator < admin < super_admin`). The client reads this
/// from the JWT as a UX hint only — the server is authoritative (docs/40 §11.4).
enum Role {
  user('user', 0),
  moderator('moderator', 50),
  admin('admin', 80),
  superAdmin('super_admin', 100);

  const Role(this.wire, this.rank);
  final String wire;
  final int rank;

  static Role fromWire(String? value, {Role fallback = Role.user}) =>
      values.firstWhere((e) => e.wire == value, orElse: () => fallback);

  bool satisfies(Role minimum) => rank >= minimum.rank;
}

/// Account lifecycle.
enum UserStatus {
  active('active'),
  suspended('suspended'),
  deactivated('deactivated');

  const UserStatus(this.wire);
  final String wire;

  static UserStatus fromWire(
    String? value, {
    UserStatus fallback = UserStatus.active,
  }) => values.firstWhere((e) => e.wire == value, orElse: () => fallback);
}

/// Feed sort orders (`?sort=`).
enum FeedSort {
  latest('latest'),
  trending('trending'),
  mostClapped('most_clapped'),
  mostDiscussed('most_discussed');

  const FeedSort(this.wire);
  final String wire;

  static FeedSort fromWire(
    String? value, {
    FeedSort fallback = FeedSort.latest,
  }) => values.firstWhere((e) => e.wire == value, orElse: () => fallback);
}

/// Search scope (`?type=`).
enum SearchType {
  all('all'),
  pieces('pieces'),
  writers('writers'),
  tags('tags'),
  genres('genres'),
  languages('languages');

  const SearchType(this.wire);
  final String wire;

  static SearchType fromWire(
    String? value, {
    SearchType fallback = SearchType.all,
  }) => values.firstWhere((e) => e.wire == value, orElse: () => fallback);
}

/// Piece-search ordering (`?sort=`).
enum SearchSort {
  relevance('relevance'),
  latest('latest'),
  trending('trending'),
  mostClapped('most_clapped'),
  mostCommented('most_commented');

  const SearchSort(this.wire);
  final String wire;

  static SearchSort fromWire(
    String? value, {
    SearchSort fallback = SearchSort.relevance,
  }) => values.firstWhere((e) => e.wire == value, orElse: () => fallback);
}

/// Notification lifecycle filter (`?status=`).
enum NotificationStatus {
  unread('unread'),
  read('read'),
  archived('archived');

  const NotificationStatus(this.wire);
  final String wire;

  static NotificationStatus fromWire(
    String? value, {
    NotificationStatus fallback = NotificationStatus.unread,
  }) => values.firstWhere((e) => e.wire == value, orElse: () => fallback);
}

/// In-app notification kinds. Open catalogue on the wire — `unknown` absorbs any
/// server-added kind an older client hasn't shipped a renderer for.
enum NotificationType {
  follow('follow'),
  followRequest('follow_request'),
  followAccepted('follow_accepted'),
  comment('comment'),
  commentReply('comment_reply'),
  like('like'),
  clap('clap'),
  response('response'),
  mention('mention'),
  repost('repost'),
  featured('featured'),
  collectionFollow('collection_follow'),
  system('system'),
  unknown('__unknown__');

  const NotificationType(this.wire);
  final String wire;

  static NotificationType fromWire(String? value) => values.firstWhere(
    (e) => e.wire == value,
    orElse: () => NotificationType.unknown,
  );
}

/// The polymorphic subject a notification points at (docs/40 §12.4). Drives the
/// deep-link target; `unknown` absorbs any server-added kind so an older client
/// falls back gracefully instead of throwing.
enum NotificationEntityType {
  piece('piece'),
  comment('comment'),
  user('user'),
  collection('collection'),
  system('system'),
  unknown('__unknown__');

  const NotificationEntityType(this.wire);
  final String wire;

  static NotificationEntityType fromWire(String? value) => values.firstWhere(
    (e) => e.wire == value,
    orElse: () => NotificationEntityType.unknown,
  );
}

/// Content text direction — Urdu is RTL and a day-one requirement.
enum TextDirectionKind {
  ltr('ltr'),
  rtl('rtl');

  const TextDirectionKind(this.wire);
  final String wire;

  static TextDirectionKind fromWire(
    String? value, {
    TextDirectionKind fallback = TextDirectionKind.ltr,
  }) => values.firstWhere((e) => e.wire == value, orElse: () => fallback);
}

/// Why a piece/comment/user/response is being reported (`POST /reports`).
enum ReportReason {
  spam('spam'),
  harassment('harassment'),
  hateSpeech('hate_speech'),
  violence('violence'),
  sexualContent('sexual_content'),
  selfHarm('self_harm'),
  misinformation('misinformation'),
  copyright('copyright'),
  impersonation('impersonation'),
  other('other');

  const ReportReason(this.wire);
  final String wire;

  static ReportReason fromWire(
    String? value, {
    ReportReason fallback = ReportReason.other,
  }) => values.firstWhere((e) => e.wire == value, orElse: () => fallback);
}

/// What kind of entity a report targets.
enum ReportEntityType {
  piece('piece'),
  comment('comment'),
  user('user'),
  response('response');

  const ReportEntityType(this.wire);
  final String wire;

  static ReportEntityType fromWire(
    String? value, {
    ReportEntityType fallback = ReportEntityType.piece,
  }) => values.firstWhere((e) => e.wire == value, orElse: () => fallback);
}

/// Follow-edge state.
enum FollowStatus {
  pending('pending'),
  accepted('accepted');

  const FollowStatus(this.wire);
  final String wire;

  static FollowStatus fromWire(
    String? value, {
    FollowStatus fallback = FollowStatus.accepted,
  }) => values.firstWhere((e) => e.wire == value, orElse: () => fallback);
}

/// Server-persisted theme preference (synced; the client drives rendering).
enum ThemePreference {
  light('light'),
  dark('dark'),
  system('system');

  const ThemePreference(this.wire);
  final String wire;

  static ThemePreference fromWire(
    String? value, {
    ThemePreference fallback = ThemePreference.system,
  }) => values.firstWhere((e) => e.wire == value, orElse: () => fallback);
}

/// `GET /discover/writers?kind=`.
enum WriterKind {
  featured('featured'),
  popular('popular'),
  newcomer('new');

  const WriterKind(this.wire);
  final String wire;

  static WriterKind fromWire(
    String? value, {
    WriterKind fallback = WriterKind.featured,
  }) => values.firstWhere((e) => e.wire == value, orElse: () => fallback);
}

/// `GET /discover/pieces?kind=`.
enum DiscoverPieceKind {
  featured('featured'),
  recent('recent'),
  mostClapped('most_clapped'),
  mostDiscussed('most_discussed');

  const DiscoverPieceKind(this.wire);
  final String wire;

  static DiscoverPieceKind fromWire(
    String? value, {
    DiscoverPieceKind fallback = DiscoverPieceKind.featured,
  }) => values.firstWhere((e) => e.wire == value, orElse: () => fallback);
}

/// How a piece was shared.
enum ShareChannel {
  internal('internal'),
  external('external'),
  copyLink('copy_link');

  const ShareChannel(this.wire);
  final String wire;

  static ShareChannel fromWire(
    String? value, {
    ShareChannel fallback = ShareChannel.copyLink,
  }) => values.firstWhere((e) => e.wire == value, orElse: () => fallback);
}

/// Analytics snapshot / trend window.
enum AnalyticsPeriod {
  daily('daily'),
  weekly('weekly'),
  monthly('monthly');

  const AnalyticsPeriod(this.wire);
  final String wire;

  static AnalyticsPeriod fromWire(
    String? value, {
    AnalyticsPeriod fallback = AnalyticsPeriod.daily,
  }) => values.firstWhere((e) => e.wire == value, orElse: () => fallback);
}

/// `GET /analytics/trending?type=`.
enum TrendType {
  pieces('pieces'),
  writers('writers'),
  genres('genres'),
  tags('tags');

  const TrendType(this.wire);
  final String wire;

  static TrendType fromWire(
    String? value, {
    TrendType fallback = TrendType.pieces,
  }) => values.firstWhere((e) => e.wire == value, orElse: () => fallback);
}
