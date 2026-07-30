/// Email-verification banner (docs/40 §11.5, docs/41 §31). A calm, dismissable-in-
/// spirit nudge shown while the signed-in user's email is known-unverified —
/// verification is a state, not a wall, so it never blocks the UI. Tapping "Verify"
/// opens the verify-email corridor. Renders nothing when verified or unknown (e.g.
/// after a cold-start restore, where the verified state isn't yet known).
///
/// A reusable widget so any surface (M3+) can place it; M2 mounts it on the account
/// surface.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../core/session/session_state.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/radius_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';

class EmailVerificationBanner extends ConsumerWidget {
  const EmailVerificationBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SessionState session = ref
        .watch(sessionControllerProvider)
        .stateOrUnknown;
    // Only when we positively know the email is unverified.
    if (!session.isAuthenticated || session.isEmailVerified != false) {
      return const SizedBox.shrink();
    }

    final AppLocalizations l10n = AppLocalizations.of(context);
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(QSpacing.s3),
        decoration: BoxDecoration(
          color: tokens.colors.warningBg,
          borderRadius: QRadii.cardRadius,
        ),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.mark_email_unread_outlined,
              size: 20,
              color: tokens.colors.warning,
            ),
            const SizedBox(width: QSpacing.s2),
            Expanded(
              child: Text(
                l10n.verifyBannerText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: tokens.colors.warningText,
                ),
              ),
            ),
            TextButton(
              onPressed: () => context.push(Routes.verifyEmail),
              child: Text(l10n.verifyBannerAction),
            ),
          ],
        ),
      ),
    );
  }
}
