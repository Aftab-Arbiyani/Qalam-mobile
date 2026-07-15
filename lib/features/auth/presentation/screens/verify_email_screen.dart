/// Verify-email screen (docs/40 §10.2, §11.5). A neutral corridor reachable both
/// signed-out (a deep-link `?token=…`) and freshly-registered-still-signed-in.
///
/// - With a token: auto-submits it and shows verifying → verified.
/// - Without a token: the "check your inbox" state, with resend (signed-in only,
///   since the endpoint operates on the current user) and a continue action.
///
/// Verification is a state, not a wall — "continue" is always offered.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/session/current_user.dart';
import '../../../../core/session/current_user_controller.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../core/session/session_state.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/buttons/q_button.dart';
import '../../../../shared/widgets/loading/q_loading_indicator.dart';
import '../controllers/verify_email_controller.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_scaffold.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({this.token, super.key});

  final String? token;

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  @override
  void initState() {
    super.initState();
    final String? token = widget.token;
    if (token != null && token.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(verifyEmailControllerProvider.notifier).verify(token);
      });
    }
  }

  void _continue() {
    final SessionState session = ref
        .read(sessionControllerProvider)
        .stateOrUnknown;
    context.go(session.isAuthenticated ? Routes.feed : Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);
    final VerifyEmailState state = ref.watch(verifyEmailControllerProvider);
    final VerifyEmailController controller = ref.read(
      verifyEmailControllerProvider.notifier,
    );
    final CurrentUser? user = ref.watch(currentUserControllerProvider);
    final bool authenticated = ref
        .watch(sessionControllerProvider)
        .stateOrUnknown
        .isAuthenticated;

    if (state.status == VerifyEmailStatus.verifying) {
      return AuthScaffold(
        title: l10n.authVerifyTitle,
        children: <Widget>[QLoadingIndicator(label: l10n.authVerifyingLabel)],
      );
    }

    if (state.status == VerifyEmailStatus.verified) {
      return AuthScaffold(
        title: l10n.authVerifiedTitle,
        subtitle: l10n.authVerifiedBody,
        children: <Widget>[
          Icon(
            Icons.check_circle_outline,
            size: 40,
            color: tokens.colors.success,
          ),
          Gap.v5,
          QButton(
            label: l10n.actionContinue,
            variant: QButtonVariant.primary,
            size: QButtonSize.lg,
            block: true,
            onPressed: _continue,
          ),
        ],
      );
    }

    final String body = user != null
        ? l10n.authVerifySentToBody(user.email)
        : l10n.authVerifyGenericBody;

    return AuthScaffold(
      title: l10n.authVerifyTitle,
      subtitle: body,
      children: <Widget>[
        if (state.error != null) ...<Widget>[
          AuthErrorBanner(failure: state.error!),
          Gap.v4,
        ],
        Text(
          l10n.authVerifyWhyBody,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: tokens.colors.textSecondary,
          ),
        ),
        Gap.v5,
        if (authenticated) ...<Widget>[
          QButton(
            label: l10n.actionResend,
            size: QButtonSize.lg,
            block: true,
            loading: state.status == VerifyEmailStatus.resending,
            onPressed: controller.resend,
          ),
          if (state.status == VerifyEmailStatus.resent) ...<Widget>[
            Gap.v2,
            Text(
              l10n.authResentBody,
              style: theme.textTheme.bodySmall?.copyWith(
                color: tokens.colors.successText,
              ),
            ),
          ],
          Gap.v3,
        ],
        QButton(
          label: authenticated ? l10n.actionContinue : l10n.actionSignIn,
          variant: QButtonVariant.primary,
          size: QButtonSize.lg,
          block: true,
          onPressed: _continue,
        ),
      ],
    );
  }
}
