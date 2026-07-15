/// Social sign-in buttons (docs/40 §14.4, docs/41 §11.1). Provider-agnostic:
/// renders one "Continue with …" button per [SocialProvider], driven by the shared
/// [SocialAuthController]. Google is wired through the exchange pipeline; the native
/// launch is a seam (§39.2), so in this build both providers resolve to an honest
/// "not available yet" note rather than a fake flow. On a real success the caller's
/// [onSuccess] navigates.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/buttons/q_button.dart';
import '../../domain/entities/social_provider.dart';
import '../controllers/social_auth_controller.dart';
import 'auth_error_banner.dart';

class SocialAuthButtons extends ConsumerWidget {
  const SocialAuthButtons({required this.onSuccess, super.key});

  final VoidCallback onSuccess;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);
    final SocialAuthState state = ref.watch(socialAuthControllerProvider);

    ref.listen(socialAuthControllerProvider, (_, SocialAuthState next) {
      if (next.status == SocialAuthStatus.success) onSuccess();
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: Divider(color: tokens.colors.border)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: QSpacing.s3),
              child: Text(
                l10n.authOrDivider,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: tokens.colors.textSecondary,
                ),
              ),
            ),
            Expanded(child: Divider(color: tokens.colors.border)),
          ],
        ),
        Gap.v4,
        for (final SocialProvider provider
            in SocialProvider.values) ...<Widget>[
          QButton(
            label: l10n.authContinueWith(provider.label),
            icon: provider == SocialProvider.apple ? Icons.apple : Icons.login,
            block: true,
            loading: state.isBusy && state.provider == provider,
            onPressed: state.isBusy
                ? null
                : () => ref
                      .read(socialAuthControllerProvider.notifier)
                      .signIn(provider),
          ),
          Gap.v3,
        ],
        if (state.status == SocialAuthStatus.unsupported &&
            state.provider != null)
          Padding(
            padding: const EdgeInsets.only(top: QSpacing.s1),
            child: Text(
              l10n.authSocialUnavailable(state.provider!.label),
              style: theme.textTheme.bodySmall?.copyWith(
                color: tokens.colors.textSecondary,
              ),
            ),
          ),
        if (state.status == SocialAuthStatus.failure && state.error != null)
          Padding(
            padding: const EdgeInsets.only(top: QSpacing.s1),
            child: AuthErrorBanner(failure: state.error!),
          ),
      ],
    );
  }
}
