/// The plan piece cap, on the writer's own surfaces (B4, docs/45 §4.9).
///
/// Follows the shape AF5 established for a premium refusal — say what happened, then offer
/// the action that actually helps — but is built here from shared widgets and a ROUTE push
/// rather than by reaching for monetization's `FeatureLockCard`, which would make one
/// feature import another (docs/26 §4). The same reason `ai_plans_link.dart` navigates by
/// route instead of importing the billing UI.
///
/// **The create affordance stays visible and is plainly disabled, never hidden.** An
/// affordance that quietly disappears is defect C-1 (`docs/56` §2.1); one that stays live
/// and 402s is W3c-1. This is the third option, and the notice is what makes it honest.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/radius_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/buttons/q_button.dart';
import '../support/piece_limit_copy.dart';

/// "24 of 25 pieces" — the count BEFORE it bites. Renders nothing on an unlimited plan.
class PieceAllowanceCount extends StatelessWidget {
  const PieceAllowanceCount({required this.copy, super.key});

  final PieceLimitCopy copy;

  @override
  Widget build(BuildContext context) {
    final String? label = copy.countLabel;
    if (label == null) return const SizedBox.shrink();
    final QTokens tokens = QTokens.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        QSpacing.s4,
        QSpacing.s2,
        QSpacing.s4,
        0,
      ),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: copy.blocked
                ? tokens.colors.warningText
                : tokens.colors.textMuted,
          ),
        ),
      ),
    );
  }
}

/// The explanatory notice shown once the writer is out of slots, with the one action that
/// helps them. Renders nothing while they still have room.
class PieceLimitNotice extends StatelessWidget {
  const PieceLimitNotice({required this.copy, super.key});

  final PieceLimitCopy copy;

  @override
  Widget build(BuildContext context) {
    if (!copy.blocked) return const SizedBox.shrink();
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        QSpacing.s4,
        QSpacing.s3,
        QSpacing.s4,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.all(QSpacing.s3),
        decoration: BoxDecoration(
          color: tokens.colors.warningBg,
          borderRadius: QRadii.cardRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.lock_outline,
                  size: 18,
                  color: tokens.colors.warningText,
                ),
                const SizedBox(width: QSpacing.s2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        copy.headline!,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: tokens.colors.warningText,
                        ),
                      ),
                      const SizedBox(height: QSpacing.s1),
                      Text(
                        copy.message!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: tokens.colors.warningText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: QSpacing.s3),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: QButton(
                label: 'See plans',
                icon: Icons.workspace_premium_outlined,
                onPressed: () => context.push(Routes.billingPlans),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
