/// Google OAuth callback screen (docs/40 §12, §14.4). Lands from
/// `/auth/callback?code=…` (the server-mediated redirect target), completes the
/// token exchange, and — on success — lets the router redirect to the destination.
/// A missing code or a failed exchange surfaces an honest error with a route back
/// to login.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/error/failure.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/domain/error_codes.dart';
import '../../../../shared/widgets/buttons/q_button.dart';
import '../../../../shared/widgets/loading/q_loading_indicator.dart';
import '../../../../shared/widgets/states/q_error_view.dart';
import '../../domain/entities/social_provider.dart';
import '../controllers/social_auth_controller.dart';
import '../widgets/auth_scaffold.dart';

class GoogleCallbackScreen extends ConsumerStatefulWidget {
  const GoogleCallbackScreen({this.code, this.returnTo, super.key});

  final String? code;
  final String? returnTo;

  @override
  ConsumerState<GoogleCallbackScreen> createState() =>
      _GoogleCallbackScreenState();
}

class _GoogleCallbackScreenState extends ConsumerState<GoogleCallbackScreen> {
  @override
  void initState() {
    super.initState();
    final String? code = widget.code;
    if (code != null && code.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(socialAuthControllerProvider.notifier)
            .completeWithCode(provider: SocialProvider.google, code: code);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final SocialAuthState state = ref.watch(socialAuthControllerProvider);

    ref.listen(
      socialAuthControllerProvider.select((SocialAuthState s) => s.status),
      (_, SocialAuthStatus status) {
        if (status == SocialAuthStatus.success) {
          context.go(Routes.safeReturnTo(widget.returnTo));
        }
      },
    );

    final bool missingCode = widget.code == null || widget.code!.isEmpty;
    if (missingCode || state.status == SocialAuthStatus.failure) {
      final Failure failure =
          state.error ?? const Failure.auth(code: ErrorCodes.authOauthFailed);
      return AuthScaffold(
        title: l10n.authLoginTitle,
        children: <Widget>[
          QErrorView(failure: failure),
          QButton(
            label: l10n.authBackToLogin,
            block: true,
            onPressed: () => context.go(Routes.login),
          ),
        ],
      );
    }

    return AuthScaffold(
      title: l10n.authLoginTitle,
      children: <Widget>[QLoadingIndicator(label: l10n.loadingLabel)],
    );
  }
}
