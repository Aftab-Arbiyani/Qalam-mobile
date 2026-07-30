/// Restricted-state screen (AF6) — the account-standing wall the app renders when the
/// current user's trust status carries a restriction (read-only / muted / suspended).
/// Reads the server-authoritative trust summary; when in good standing it shows a calm
/// "good standing" state instead. Copy is honest and non-blaming (docs/41 §33).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../shared/domain/error_codes.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/cards/q_card.dart';
import '../../../../shared/widgets/states/q_empty_state.dart';
import '../../../../shared/widgets/states/q_error_view.dart';
import '../../domain/entities/trust_summary.dart';
import '../domain_labels.dart';
import '../providers/collaboration_providers.dart';

class RestrictedStateScreen extends ConsumerWidget {
  const RestrictedStateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<TrustSummary> async = ref.watch(trustSummaryProvider);
    return Scaffold(
      appBar: const QAppBar(title: 'Account standing'),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => QErrorView(
          failure: _failureOf(error),
          onRetry: () => ref.invalidate(trustSummaryProvider),
        ),
        data: (TrustSummary trust) => trust.isRestricted
            ? _RestrictedBody(trust: trust)
            : const QEmptyState(
                icon: Icons.verified_user_outlined,
                title: 'Your account is in good standing',
                message:
                    'You have full access to writing, commenting, and publishing.',
              ),
      ),
    );
  }
}

class _RestrictedBody extends StatelessWidget {
  const _RestrictedBody({required this.trust});

  final TrustSummary trust;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final (IconData icon, String title, String message) = _copy(trust);
    return ListView(
      padding: QSpacing.pagePadding,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(QSpacing.s5),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: <Widget>[
              Icon(icon, size: 40, color: theme.colorScheme.onErrorContainer),
              Gap.v2,
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
              Gap.v1,
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ],
          ),
        ),
        Gap.v3,
        QCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Status', style: theme.textTheme.labelMedium),
              Gap.v1,
              Text(
                trustStatusLabel(trust.status),
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ),
        if (trust.activeRestrictions.isNotEmpty) ...<Widget>[
          Gap.v3,
          Text('Active restrictions', style: theme.textTheme.titleMedium),
          Gap.v2,
          for (final UserRestriction restriction
              in trust.activeRestrictions) ...<Widget>[
            QCard(
              padding: QCardPadding.md,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          restrictionTypeLabel(restriction.type),
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      if (restriction.isPermanent)
                        const Chip(
                          label: Text('Permanent'),
                          visualDensity: VisualDensity.compact,
                        )
                      else if (restriction.expiresAt != null)
                        Chip(
                          label: Text(
                            'Until ${formatCollaborationDate(restriction.expiresAt!)}',
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                  if (restriction.reason.isNotEmpty) ...<Widget>[
                    Gap.v1,
                    Text(restriction.reason, style: theme.textTheme.bodySmall),
                  ],
                ],
              ),
            ),
            Gap.v2,
          ],
        ],
      ],
    );
  }

  (IconData, String, String) _copy(TrustSummary trust) {
    if (trust.isSuspended) {
      return (
        Icons.gpp_bad_outlined,
        'Your account is suspended',
        'You cannot write, comment, or publish while your account is suspended.',
      );
    }
    if (trust.isReadOnly) {
      return (
        Icons.lock_outline,
        'Your account is read-only',
        'You can read, but writing, commenting, and publishing are paused.',
      );
    }
    if (trust.isMuted) {
      return (
        Icons.volume_off_outlined,
        'Your account is muted',
        'Your comments and posts are limited in visibility right now.',
      );
    }
    return (
      Icons.shield_outlined,
      'Your account is limited',
      'Some actions are temporarily restricted.',
    );
  }
}

Failure _failureOf(Object error) => error is Failure
    ? error
    : Failure.unexpected(code: ErrorCodes.apiUnexpected, message: '$error');
