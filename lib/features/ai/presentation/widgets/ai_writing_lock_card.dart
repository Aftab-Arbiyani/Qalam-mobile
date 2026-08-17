/// The AI-writing lock (D3) — what an AF2 panel shows a writer whose plan does not include
/// AI writing (`platfrom/docs/45` §4 row D3, `docs/48` §6.13).
///
/// ⚠️ A deliberate behaviour REGRESSION for existing free writers, flagged before the owner's
/// decision and accepted.
///
/// **Why this rather than monetization's [FeatureLockCard].** That card composes its copy from
/// the server's `reason` for ANY premium code, which is right for the credit dashboard and
/// wrong here: it would say "AI writing assistant needs a paid plan" while the mid-flight 402
/// on the very same surface said something else. This renders [AiErrorCopy.aiWritingLocked] —
/// the exact copy the streaming path shows — so a writer walled on open and a writer walled
/// between opening and generating are told the same thing. One remedy, one wording, one place
/// to change it.
library;

import 'package:flutter/material.dart';

import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/buttons/q_button.dart';
import '../support/ai_error_copy.dart';
import '../support/ai_plans_link.dart';

class AiWritingLockCard extends StatelessWidget {
  const AiWritingLockCard({super.key});

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    const AiErrorCopy copy = AiErrorCopy.aiWritingLocked;

    return Semantics(
      label: copy.title,
      child: Padding(
        padding: QSpacing.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.lock_outline, size: 40),
            Gap.v2,
            Text(
              copy.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Gap.v1,
            Text(
              copy.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: tokens.colors.textSecondary,
              ),
            ),
            Gap.v3,
            QButton(
              label: 'See plans',
              variant: QButtonVariant.primary,
              icon: Icons.workspace_premium_outlined,
              // Pops the sheet before navigating — see `openPlansFromSheet`, which exists
              // because getting that order backwards fails at runtime, not at compile time.
              onPressed: () => openPlansFromSheet(context),
            ),
          ],
        ),
      ),
    );
  }
}
