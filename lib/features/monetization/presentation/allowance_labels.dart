/// How an allowance is put into words (**D5**). Presentation only, pure.
///
/// Two jobs, and they are deliberately separate:
///
/// 1. [allowanceLine] phrases what a writer has left — "12 of 30 today".
/// 2. [planLimitSpec] decides which plan limits a **plan card** may show at all.
///
/// The second is an **allowlist, not a formatter**, and that is the point. `PlanLimits`
/// is an open map of server keys, and the tempting implementation — render every entry,
/// prettify the key — is how "aiMonthlyTokens: 250000" ends up on a plan card. D5 exists
/// to stop a writer being sold a token budget, so a key nobody has decided how to
/// present is simply not shown. Adding a limit to the card is a deliberate act.
///
/// **Sentinels differ per key and are not guessable.** `0` means unlimited almost
/// everywhere, but `maxCollaborators` is inverted — `-1` is unlimited and `0` is none —
/// which is exactly why each key states its own reading rather than sharing one rule.
library;

import 'package:flutter/material.dart';

import '../domain/entities/usage_summary.dart';

/// The tool an allowance belongs to, in a reader's words.
///
/// The server sends its own `label` and that wins; this is the fallback for a row that
/// arrives without one, so an unlabelled quota still reads as something rather than as
/// a camelCase key.
String allowanceNoun(FeatureAllowance allowance) {
  if (allowance.label.trim().isNotEmpty) return allowance.label;
  return switch (allowance.key) {
    'polishActionsPerDay' => 'Polish',
    'feedbackReportsPerDay' => 'Manuscript feedback',
    'storyAnalysesPerMonth' => 'Story analyses',
    _ => allowance.key,
  };
}

/// "today" / "this month" — the window as a writer would say it.
String allowanceWindow(String window) => switch (window) {
  'daily' => 'today',
  'monthly' => 'this month',
  _ => '',
};

/// "12 of 30 today" · "Unlimited".
String allowanceLine(FeatureAllowance allowance) {
  if (allowance.isUnlimited) return 'Unlimited';
  final String when = allowanceWindow(allowance.window);
  final String count = '${allowance.used} of ${allowance.limit}';
  return when.isEmpty ? count : '$count $when';
}

/// What a spent allowance says, and what it does NOT say.
///
/// It never offers a plan: an exhausted allowance resets on its own, and pointing at
/// the plans page sells someone something they do not need (docs/48 §5.2,
/// consequence 2). That distinction is the whole reason quota and entitlement stay
/// separate remedies.
String allowanceExhaustedLine(FeatureAllowance allowance) {
  final String when = allowanceWindow(allowance.window);
  return when == 'this month'
      ? 'You’ve used this month’s allowance.'
      : 'You’ve used today’s allowance.';
}

/// How one `PlanLimits` key is rendered on a plan card, or `null` to omit it.
class PlanLimitSpec {
  const PlanLimitSpec({
    required this.noun,
    required this.suffix,
    required this.unlimitedAt,
    this.noneAt,
  });

  /// "Polish actions", "Collaborators".
  final String noun;

  /// "a day", "a month", or '' for a plain count.
  final String suffix;

  /// The value that means "no ceiling" for THIS key.
  final int unlimitedAt;

  /// The value that means "none at all", when the key has one.
  final int? noneAt;

  String describe(int value) {
    if (value == unlimitedAt) return 'Unlimited ${noun.toLowerCase()}';
    if (noneAt != null && value == noneAt) return 'No ${noun.toLowerCase()}';
    return suffix.isEmpty
        ? '$value ${noun.toLowerCase()}'
        : '$value ${noun.toLowerCase()} $suffix';
  }
}

/// The allowlist. A key absent from here is NOT rendered — see the library note.
PlanLimitSpec? planLimitSpec(String key) => switch (key) {
  'polishActionsPerDay' => const PlanLimitSpec(
    noun: 'Polish actions',
    suffix: 'a day',
    unlimitedAt: 0,
  ),
  'feedbackReportsPerDay' => const PlanLimitSpec(
    noun: 'Feedback reports',
    suffix: 'a day',
    unlimitedAt: 0,
  ),
  'storyAnalysesPerMonth' => const PlanLimitSpec(
    noun: 'Story analyses',
    suffix: 'a month',
    unlimitedAt: 0,
  ),
  'maxPieces' => const PlanLimitSpec(
    noun: 'Pieces',
    suffix: '',
    unlimitedAt: 0,
  ),
  // The one inverted key in the whole catalogue: -1 is unlimited and 0 is none, the
  // opposite of every other row here. Sharing a sentinel rule across keys would have
  // rendered "Unlimited collaborators" for a plan that allows none.
  'maxCollaborators' => const PlanLimitSpec(
    noun: 'Collaborators',
    suffix: '',
    unlimitedAt: -1,
    noneAt: 0,
  ),
  'maxSnapshotHistory' => const PlanLimitSpec(
    noun: 'Saved versions',
    suffix: '',
    unlimitedAt: 0,
  ),
  _ => null,
};

/// Every plan-card line for a plan's limits, in allowlist order so two plans compare
/// row by row. Silently drops keys with no spec.
List<String> planLimitLines(Map<String, int> limits) {
  const List<String> order = <String>[
    'polishActionsPerDay',
    'feedbackReportsPerDay',
    'storyAnalysesPerMonth',
    'maxPieces',
    'maxCollaborators',
    'maxSnapshotHistory',
  ];
  return <String>[
    for (final String key in order)
      if (limits[key] case final int value)
        if (planLimitSpec(key) case final PlanLimitSpec spec)
          spec.describe(value),
  ];
}

/// The icon for a tool's allowance card. No sparkles (D5 decision 9).
IconData allowanceIcon(String key) => switch (key) {
  'polishActionsPerDay' => Icons.brush_outlined,
  'feedbackReportsPerDay' => Icons.rate_review_outlined,
  'storyAnalysesPerMonth' => Icons.hub_outlined,
  _ => Icons.tune,
};
