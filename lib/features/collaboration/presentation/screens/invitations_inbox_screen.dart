/// Invitations inbox screen (AF6) — the current user's inbound collaboration
/// invitations (`GET /me/invitations`). Drives accept / decline; the server resolves
/// the invitation and, on accept, adds the user as a member.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/error/failure.dart';
import '../../../../shared/domain/error_codes.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/cards/q_card.dart';
import '../../../../shared/widgets/states/q_empty_state.dart';
import '../../../../shared/widgets/states/q_error_view.dart';
import '../../domain/entities/story_invitation.dart';
import '../controllers/collaboration_controller.dart';
import '../domain_labels.dart';
import '../providers/collaboration_providers.dart';
import '../widgets/role_badge.dart';

class InvitationsInboxScreen extends ConsumerWidget {
  const InvitationsInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool enabled = ref.watch(appConfigProvider).enableCollaboration;
    return Scaffold(
      appBar: const QAppBar(title: 'Invitations'),
      body: enabled
          ? _body(context, ref)
          : const QEmptyState(
              icon: Icons.mail_outline,
              title: 'Collaboration is off',
              message: 'Enable collaboration to receive story invitations.',
            ),
    );
  }

  Widget _body(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<StoryInvitation>> async = ref.watch(
      myInvitationsProvider,
    );
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace _) => QErrorView(
        failure: _failureOf(error),
        onRetry: () => ref.invalidate(myInvitationsProvider),
      ),
      data: (List<StoryInvitation> invites) {
        final List<StoryInvitation> pending = invites
            .where((StoryInvitation i) => i.isPending)
            .toList(growable: false);
        if (pending.isEmpty) {
          return const QEmptyState(
            icon: Icons.mark_email_read_outlined,
            title: 'No pending invitations',
            message: 'When someone invites you to collaborate, it lands here.',
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(myInvitationsProvider),
          child: ListView.separated(
            padding: QSpacing.pagePadding,
            itemCount: pending.length,
            separatorBuilder: (_, _) => Gap.v3,
            itemBuilder: (BuildContext context, int index) =>
                _InvitationCard(invitation: pending[index]),
          ),
        );
      },
    );
  }
}

class _InvitationCard extends ConsumerWidget {
  const _InvitationCard({required this.invitation});

  final StoryInvitation invitation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final bool busy = ref.watch(collaborationControllerProvider).isLoading;
    return QCard(
      padding: QCardPadding.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            invitation.storyTitle ?? 'A story',
            style: theme.textTheme.titleMedium,
          ),
          Gap.v1,
          Row(
            children: <Widget>[
              RoleBadge(role: invitation.role),
              if (invitation.invitedByName != null) ...<Widget>[
                Gap.h2,
                Expanded(
                  child: Text(
                    'from ${invitation.invitedByName}',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ],
          ),
          if (invitation.expiresAt != null) ...<Widget>[
            Gap.v1,
            Text(
              'Expires ${formatCollaborationDate(invitation.expiresAt!)}',
              style: theme.textTheme.labelSmall,
            ),
          ],
          Gap.v3,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                onPressed: busy
                    ? null
                    : () => _respond(
                        context,
                        ref,
                        () => ref
                            .read(collaborationControllerProvider.notifier)
                            .declineInvitation(invitation.id),
                        'Invitation declined.',
                      ),
                child: const Text('Decline'),
              ),
              Gap.h2,
              FilledButton(
                onPressed: busy
                    ? null
                    : () => _respond(
                        context,
                        ref,
                        () => ref
                            .read(collaborationControllerProvider.notifier)
                            .acceptInvitation(invitation.id),
                        'Invitation accepted.',
                      ),
                child: const Text('Accept'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _respond(
    BuildContext context,
    WidgetRef ref,
    Future<StoryInvitation?> Function() op,
    String okMessage,
  ) async {
    final StoryInvitation? result = await op();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result == null ? _errorMessage(ref) : okMessage)),
    );
  }
}

Failure _failureOf(Object error) => error is Failure
    ? error
    : Failure.unexpected(code: ErrorCodes.apiUnexpected, message: '$error');

String _errorMessage(WidgetRef ref) {
  final Object? err = ref.read(collaborationControllerProvider).error;
  return err is Failure ? err.message : 'Something went wrong.';
}
