/// Copy for the plan piece cap (B4, docs/45 §4.9) — the mobile twin of the web's
/// `features/writing/lib/piece-allowance.ts`, kept wording-for-wording so the two clients
/// say the same thing to the same writer (parity, docs/48).
///
/// **It never offers a reset, and that is the point.** The same split
/// [AiErrorCopy](../../../ai/presentation/support/ai_error_copy.dart) makes between a spent
/// allowance and a denied entitlement applies here with only one side available: a piece cap
/// is a stock, so waiting is never a remedy, and the two that are — delete a piece, change
/// plan — are the two this copy names. Telling a blocked writer to wait for a reset that
/// never comes is the W4 defect (docs/48 §3.6).
library;

import '../../domain/entities/piece_allowance.dart';

class PieceLimitCopy {
  const PieceLimitCopy({
    required this.countLabel,
    required this.blocked,
    required this.overLimit,
    this.headline,
    this.message,
  });

  /// "24 of 25 pieces" — shown beside the create action. Null on an unlimited plan,
  /// where a count that never approaches anything is noise rather than information.
  final String? countLabel;

  final bool blocked;

  /// The downgrade case: more pieces held than the plan includes.
  final bool overLimit;

  /// Heading for the blocked notice; null when not blocked.
  final String? headline;

  /// Body for the blocked notice — states both remedies; null when not blocked.
  final String? message;

  /// [allowance] is null while the read is in flight or after it failed: nothing is
  /// shown and nothing is blocked, because the server still checks every create.
  static PieceLimitCopy of(PieceAllowance? allowance) {
    if (allowance == null || allowance.unlimited) {
      return const PieceLimitCopy(
        countLabel: null,
        blocked: false,
        overLimit: false,
      );
    }

    final String count = '${allowance.used} of ${allowance.limit} pieces';
    if (!allowance.isBlocked) {
      return PieceLimitCopy(
        countLabel: count,
        blocked: false,
        overLimit: false,
      );
    }

    return PieceLimitCopy(
      countLabel: count,
      blocked: true,
      overLimit: allowance.isOverLimit,
      headline: allowance.isOverLimit
          ? 'You have ${allowance.used} pieces and your plan includes ${allowance.limit}.'
          : 'You’ve used all ${allowance.limit} pieces on your plan.',
      message:
          'Everything you’ve written stays exactly where it is — published, readable '
          'and editable. To start something new, delete a piece to free a slot, or '
          'move to a larger plan.',
    );
  }
}
