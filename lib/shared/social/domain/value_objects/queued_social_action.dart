/// A social action queued while offline (docs/40 §23, §24) — a *desired terminal
/// state* for a toggle (liked / bookmarked / following) on a target, not an event
/// log. Modelling desired-state (rather than "like then unlike" events) makes the
/// queue idempotent and self-cancelling: toggling twice offline collapses to the
/// final intent, and a replay simply drives the server to that state. Keyed by
/// `category:targetId`, persisted as JSON.
library;

/// The toggle category an action reconciles.
enum SocialCategory {
  pieceLike('piece_like'),
  pieceBookmark('piece_bookmark'),
  userFollow('user_follow');

  const SocialCategory(this.wire);
  final String wire;

  static SocialCategory fromWire(String? value) => values.firstWhere(
    (SocialCategory c) => c.wire == value,
    orElse: () => SocialCategory.pieceLike,
  );
}

class QueuedSocialAction {
  const QueuedSocialAction({
    required this.category,
    required this.targetId,
    required this.desired,
    required this.createdAt,
  });

  factory QueuedSocialAction.fromJson(Map<String, dynamic> json) =>
      QueuedSocialAction(
        category: SocialCategory.fromWire(json['category'] as String?),
        targetId: (json['targetId'] as String?) ?? '',
        desired: (json['desired'] as bool?) ?? true,
        createdAt:
            DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      );

  final SocialCategory category;
  final String targetId;

  /// The intended end state — e.g. `true` = liked/bookmarked/following.
  final bool desired;
  final DateTime createdAt;

  /// Dedup identity — one pending action per (category, target).
  String get key => '${category.wire}:$targetId';

  Map<String, dynamic> toJson() => <String, dynamic>{
    'category': category.wire,
    'targetId': targetId,
    'desired': desired,
    'createdAt': createdAt.toUtc().toIso8601String(),
  };
}
