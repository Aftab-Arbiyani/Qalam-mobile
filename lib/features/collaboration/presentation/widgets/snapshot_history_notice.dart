/// B7 version-history surfaces (`platfrom/docs/45` §4.12) — how the publishing screen says how
/// many versions a story really has, and what to do about the ones it is not showing.
///
/// **Why this is not [PremiumGate] / [FeatureLockCard].** Those gate on a `PremiumFeature` CODE
/// and explain an `EntitlementDecision`; B7 is a `PlanLimits` NUMBER carried on the history
/// response itself, so there is no decision to hand a lock card — the same reasoning B6's
/// [CollaboratorSeatNotice] records, and this follows that widget's shape (icon, title, message,
/// one "See plans" action) for consistency between the two plan-limit surfaces in this feature.
///
/// **This is an offer, never a refusal.** The hidden versions exist; B7 clamps the READ and
/// deletes nothing, so upgrading brings them back retroactively — and capture is never blocked, so
/// the author keeps making new ones the whole time. Copy that said "you have lost" or "wait" would
/// both be false (the W4 remedy-conflation defect, docs/48 §3.6).
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/buttons/q_button.dart';
import '../../domain/entities/story_snapshot_history.dart';

/// "5 of 32 versions" — the count read from the TRUE total, beside the section heading.
///
/// Renders nothing when nothing is being withheld: on an unlimited plan there is no number to
/// count against, and "3 of 3 versions" is noise beside a list that already shows three rows.
class SnapshotHistoryCount extends StatelessWidget {
  const SnapshotHistoryCount({required this.history, super.key});

  final StorySnapshotHistory history;

  @override
  Widget build(BuildContext context) {
    if (!history.isLimited) return const SizedBox.shrink();
    final ThemeData theme = Theme.of(context);
    final QTokens tokens = QTokens.of(context);
    // `total`, never `items.length` — the list is the clamped number and would say "5 versions"
    // for a story that has thirty-two.
    final String versions = history.total == 1 ? 'version' : 'versions';
    return Semantics(
      // One phrase, not three fragments a screen reader has to reassemble.
      label:
          '${history.visible} of ${history.total} $versions shown on this plan',
      child: ExcludeSemantics(
        child: Text(
          '${history.visible} of ${history.total} $versions',
          style: theme.textTheme.labelMedium?.copyWith(
            color: tokens.colors.textMuted,
          ),
        ),
      ),
    );
  }
}

/// The offer that stands where the hidden versions would be — the end of the list, since the list
/// is newest-first.
///
/// A dead row reading "29 more" would be worse than no row at all: it names a thing and offers no
/// way to reach it. This says what they are (saved, not deleted), why they are not shown, and the
/// one action that shows them.
class SnapshotHistoryNotice extends StatelessWidget {
  const SnapshotHistoryNotice({required this.history, super.key});

  final StorySnapshotHistory history;

  @override
  Widget build(BuildContext context) {
    if (!history.isLimited) return const SizedBox.shrink();
    final ThemeData theme = Theme.of(context);
    final QTokens tokens = QTokens.of(context);

    final String older = history.hidden == 1
        ? '1 older version is'
        : '${history.hidden} older versions are';

    // An offer tint, not a warning one: nothing has gone wrong and nothing was taken away. Both
    // halves are `QTokens` pairs, so each carries its own contrast in light AND dark rather than a
    // hand-picked colour that only works in one of them.
    final Color tint = tokens.colors.infoBg;
    final Color onTint = tokens.colors.infoText;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.history_toggle_off, size: 20, color: onTint),
              Gap.h2,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '$older saved but not shown.',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: onTint,
                      ),
                    ),
                    Gap.v1,
                    Text(
                      'Your plan shows the ${history.limit} most recent versions of a story. '
                      'Nothing was deleted — the older ones come back, and stay revertible, '
                      'the moment you move to a larger plan.',
                      style: theme.textTheme.bodySmall?.copyWith(color: onTint),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Gap.v3,
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: QButton(
              label: 'See plans',
              variant: QButtonVariant.primary,
              icon: Icons.workspace_premium_outlined,
              onPressed: () => context.push(Routes.billingPlans),
            ),
          ),
        ],
      ),
    );
  }
}
