/// B6 seat surfaces (`platfrom/docs/45` §4.11) — how the collaborators screen says how many
/// collaborator seats a story has, and what to do when it has none left.
///
/// **Why this is not [PremiumGate] / [FeatureLockCard].** Those gate on a `PremiumFeature`
/// CODE and explain an `EntitlementDecision`; B6 is a `PlanLimits` NUMBER with its own
/// endpoint and its own two error codes. There is no `collaboration` decision to hand a
/// lock card — the `collaboration` feature code exists in the catalogue and no plan grants
/// it and no route asserts it (docs/48 §5.2), so gating on it would be exactly the dead UI
/// `premium_gate.dart` warns about. This follows [FeatureLockCard]'s SHAPE — icon, title,
/// message, one "See plans" action — without borrowing its input, and a feature may not
/// import another feature's widgets in any case (docs/folder-structure).
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/buttons/q_button.dart';
import '../../domain/entities/collaborator_limit.dart';

/// "2 of 3 collaborators" — the count BEFORE the wall, which is the whole point of
/// surfacing it.
///
/// Renders nothing on an unlimited plan (no number worth counting down) and nothing for a
/// free story, where "0 of 0" counts down from nothing and the notice below says it better.
/// The pending part is called out separately because it explains a discrepancy the roster
/// cannot: a story showing two collaborators is full if a third invitation is unanswered.
class CollaboratorSeatCount extends StatelessWidget {
  const CollaboratorSeatCount({required this.allowance, super.key});

  final CollaboratorLimit allowance;

  @override
  Widget build(BuildContext context) {
    if (allowance.unlimited || allowance.isFreeTier) {
      return const SizedBox.shrink();
    }
    final ThemeData theme = Theme.of(context);
    final QTokens tokens = QTokens.of(context);
    final String seats = allowance.limit == 1
        ? 'collaborator'
        : 'collaborators';
    final String pending = allowance.pendingInvitations == 0
        ? ''
        : ' · ${allowance.pendingInvitations} '
              '${allowance.pendingInvitations == 1 ? 'invitation' : 'invitations'} pending';
    return Semantics(
      // Read as one phrase rather than three fragments a screen reader has to reassemble.
      label:
          '${allowance.used} of ${allowance.limit} $seats used on this story$pending',
      child: ExcludeSemantics(
        child: Text(
          '${allowance.used} of ${allowance.limit} $seats$pending',
          style: theme.textTheme.labelMedium?.copyWith(
            color: allowance.canInvite
                ? tokens.colors.textMuted
                : tokens.colors.warningText,
          ),
        ),
      ),
    );
  }
}

/// The story has no collaborator seat left on its owner's plan.
///
/// **Rendered beside an invite control that stays visible and is plainly disabled.** A
/// control that silently disappears is the C-1 defect (`platfrom/docs/48`) and it must not
/// repeat here; one that stays live and 402s is W3c-1. This is the third option: still
/// there, off, and explained — and for a free author the explanation is what collaboration
/// IS, since they have never been able to see it work.
///
/// Three states, because the honest sentence differs: an offer (free), a downgrade (over
/// the limit, nobody removed), and simply full. None of them says "try again later" — no
/// seat frees itself, so a reset remedy would be a lie (the W4 defect, docs/48 §3.6).
class CollaboratorSeatNotice extends StatelessWidget {
  const CollaboratorSeatNotice({required this.allowance, super.key});

  final CollaboratorLimit allowance;

  @override
  Widget build(BuildContext context) {
    if (allowance.unlimited || allowance.canInvite) {
      return const SizedBox.shrink();
    }
    final ThemeData theme = Theme.of(context);
    final bool free = allowance.isFreeTier;
    final bool overLimit = !free && allowance.used > allowance.limit;
    final String seats = allowance.limit == 1
        ? 'collaborator'
        : 'collaborators';

    final String title = free
        ? 'Collaboration isn’t included in your plan'
        : overLimit
        ? 'This story has more collaborators than your plan includes'
        : 'You’ve used all ${allowance.limit} $seats on this story';

    final String message = free
        ? 'Invite a co-author, editor, or beta reader to write, comment, and suggest '
              'edits with you on this story. Plus includes 3 collaborators per story; '
              'Pro has no limit.'
        : overLimit
        ? 'Everyone keeps the access they have. To invite someone new, remove a '
              'collaborator or move to a larger plan.'
        : 'Remove a collaborator to free a seat, or move to a larger plan. Invitations '
              'that haven’t been answered hold a seat too — revoking one frees it.';

    // The tint differs by state on purpose: an offer reads as an offer, a limit reads as a
    // limit. Both are `QTokens` pairs, so each carries its own contrast in light AND dark
    // rather than a hand-picked colour that only works in one of them.
    final QTokens tokens = QTokens.of(context);
    final Color tint = free ? tokens.colors.infoBg : tokens.colors.warningBg;
    final Color onTint = free
        ? tokens.colors.infoText
        : tokens.colors.warningText;

    // A tinted Container rather than a QCard: QCard paints `bgSurface` and takes no colour
    // override, and adding one to a shared widget for this row is scope this row does not own.
    // `RestrictedBanner` tints the same way, from the same tokens.
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
              Icon(
                free ? Icons.auto_awesome_outlined : Icons.lock_outline,
                size: 20,
                color: onTint,
              ),
              Gap.h2,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: onTint,
                      ),
                    ),
                    Gap.v1,
                    Text(
                      message,
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
