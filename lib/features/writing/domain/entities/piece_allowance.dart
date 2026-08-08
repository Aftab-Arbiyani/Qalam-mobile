/// The author's plan piece allowance (B4, docs/45 §4.9) — `GET /me/pieces/limit`.
///
/// A **stock** cap on live pieces, not a flow quota: [used] counts pieces the author
/// currently holds (soft-deleted ones do not count, so deleting frees a slot), and
/// nothing about it resets with time. That is why the remedies it implies are "delete a
/// piece" and "see plans", never "wait".
///
/// Server-authoritative, like every entitlement read: [canCreate] is the server's own
/// verdict and the client renders it rather than recomputing it from [used] and [limit].
library;

class PieceAllowance {
  const PieceAllowance({
    required this.used,
    required this.limit,
    required this.unlimited,
    required this.canCreate,
    this.remaining,
  });

  /// Live (non-deleted) pieces the author holds. Responses count — they are pieces.
  final int used;

  /// The plan cap. `0` = unlimited, the `PlanLimits` convention.
  final int limit;

  /// Slots left, clamped at zero. Null when the plan is uncapped.
  final int? remaining;

  final bool unlimited;

  /// Whether the server will accept another create right now.
  final bool canCreate;

  /// True in the case a downgrade produces: more pieces held than the plan includes.
  bool get isOverLimit => !unlimited && used > limit;

  /// True when the author is out of slots — at the cap or past it.
  bool get isBlocked => !canCreate;
}
