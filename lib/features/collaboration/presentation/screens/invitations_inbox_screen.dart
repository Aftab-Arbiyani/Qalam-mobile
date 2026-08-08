/// Invitations inbox screen (AF6) — the current user's inbound collaboration
/// invitations (`GET /me/invitations`). Drives accept / decline; the server resolves
/// the invitation and, on accept, adds the user as a member.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/error/failure.dart';
import '../../../../shared/domain/error_codes.dart';
import '../../../../shared/theme/q_tokens.dart';
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

/// Stateful only to hold [_refusal] — B6's accept-side message belongs to the row the viewer
/// pressed, and the controller carries one error for the whole screen. Reading that shared
/// error in every card would paint the refusal across every pending invitation in the inbox.
class _InvitationCard extends ConsumerStatefulWidget {
  const _InvitationCard({required this.invitation});

  final StoryInvitation invitation;

  @override
  ConsumerState<_InvitationCard> createState() => _InvitationCardState();
}

class _InvitationCardState extends ConsumerState<_InvitationCard> {
  String? _refusal;

  StoryInvitation get invitation => widget.invitation;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final QTokens tokens = QTokens.of(context);
    final bool busy = ref.watch(collaborationControllerProvider).isLoading;
    final String? refusal = _refusal;
    return QCard(
      padding: QCardPadding.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // The invitation payload carries no story title — only `storyId`. Naming the story
          // would need a second fetch per row; the role + inviter below are what the decision
          // actually rests on.
          Text('A story invitation', style: theme.textTheme.titleMedium),
          Gap.v1,
          Row(
            children: <Widget>[
              RoleBadge(role: invitation.role),
              if (invitation.inviterId != null) ...<Widget>[
                Gap.h2,
                Expanded(
                  child: Text(
                    // The wire identifies the inviter by id only.
                    'from ${shortActorId(invitation.inviterId)}',
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
          if (refusal != null) ...<Widget>[
            Gap.v2,
            /*
             * B6's accept-side refusal (`platfrom/docs/45` §4.11), in the invitee's own
             * terms. The invitation was valid when it was sent; the owner has since
             * downgraded or filled the story. **No upsell and no "See plans"** — the reader
             * of this line cannot buy a seat on someone else's plan, and pointing them at
             * pricing would bill the wrong person for someone else's problem. The invitation
             * stays pending server-side, so "accept once they free one" is real advice.
             */
            Semantics(
              liveRegion: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    Icons.group_off_outlined,
                    size: 16,
                    color: tokens.colors.warningText,
                  ),
                  Gap.h2,
                  Expanded(
                    child: Text(
                      refusal,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: tokens.colors.warningText,
                      ),
                    ),
                  ),
                ],
              ),
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

  /// Accept and decline answer with different entities — a `MemberDto` and an `InvitationDto`
  /// respectively — and this only needs to know whether the call succeeded, so it takes the
  /// loosest type that says that.
  Future<void> _respond(
    Future<Object?> Function() op,
    String okMessage,
  ) async {
    final Object? result = await op();
    if (!mounted) return;
    /*
     * B6's seat refusal gets a persistent state on the card rather than only a snack bar
     * (`platfrom/docs/45` §4.11): it is not a transient failure the viewer should retry
     * blindly, it is a fact about the story that stays true until the owner acts. A message
     * that vanishes in four seconds cannot say "your invitation is still valid" usefully.
     */
    setState(() => _refusal = result == null ? _seatRefusal(ref) : null);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result == null ? _errorMessage(ref) : okMessage)),
    );
  }
}

/// B6's accept-side refusal copy, or null when the failure was something else
/// (`platfrom/docs/45` §4.11).
///
/// Keyed on the error CODE, not on the server's message: the two are separate contracts and
/// only the code is stable. Returns null for every other failure, which keeps those on the
/// snack bar where they were — this state is reserved for the one refusal the viewer cannot
/// act on themselves.
String? _seatRefusal(WidgetRef ref) {
  final Object? err = ref.read(collaborationControllerProvider).error;
  if (err is! Failure) return null;
  if (err.code != ErrorCodes.collaboratorSeatsUnavailable) return null;
  return 'This story is full — the owner’s plan has no collaborator seats left. Your '
      'invitation is still valid, so you can accept once they free one.';
}

Failure _failureOf(Object error) => error is Failure
    ? error
    : Failure.unexpected(code: ErrorCodes.apiUnexpected, message: '$error');

String _errorMessage(WidgetRef ref) {
  final Object? err = ref.read(collaborationControllerProvider).error;
  return err is Failure ? err.message : 'Something went wrong.';
}
