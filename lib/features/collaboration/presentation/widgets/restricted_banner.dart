/// Restricted-standing banner (AF6) — the way a restricted account learns it is
/// restricted, and the only entry point to `/restricted`.
///
/// The restricted-state wall is reached by **noticing**, not by browsing: there is
/// no menu item for "my account is limited". Router-level interception is not an
/// option — `guardRedirect` is a pure, synchronous function of the session tri-state
/// (docs/40 §11) and resolving trust needs an async server read, so a passive strip
/// on the writer surfaces is the honest mechanism. Mirrors `ConnectivityBanner`:
/// slim, never blocks content, and renders nothing in the common case.
///
/// Fails OPEN — a trust read that errors renders nothing rather than falsely
/// telling someone in good standing that they are limited. The server enforces
/// regardless (every write re-checks through the Policy Engine).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/di/providers.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../domain/entities/trust_summary.dart';
import '../providers/collaboration_providers.dart';

class RestrictedBanner extends ConsumerWidget {
  const RestrictedBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(appConfigProvider).enableCollaboration) {
      return const SizedBox.shrink();
    }
    final TrustSummary? trust = ref.watch(trustSummaryProvider).asData?.value;
    if (trust == null || !trust.isRestricted) return const SizedBox.shrink();

    final QTokens tokens = QTokens.of(context);
    return Semantics(
      button: true,
      label: 'Account limited — see what this means',
      child: InkWell(
        onTap: () => context.push(Routes.trustRestricted),
        child: Container(
          width: double.infinity,
          color: tokens.colors.warningBg,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.gpp_maybe_outlined,
                size: 16,
                color: tokens.colors.warningText,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _label(trust),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: tokens.colors.warningText,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: tokens.colors.warningText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Names the standing the server reported, so the strip says something specific
  /// rather than a generic warning. Falls back to the neutral wording for a
  /// restriction whose status the client does not have a phrase for.
  static String _label(TrustSummary trust) {
    if (trust.isSuspended) return 'Your account is suspended.';
    if (trust.isReadOnly) return 'Your account is read-only.';
    if (trust.isMuted) return 'Your account is muted.';
    return 'Your account is limited.';
  }
}
