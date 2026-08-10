/// Collaborators screen (AF6) — the membership home for a story. Lists collaborators
/// with their role, drives capability-gated management (change role / remove / invite),
/// shows a live presence bar, and surfaces outstanding invitations. Every management
/// affordance is wrapped in a [CapabilityGate] on the policy action; the server
/// re-checks on the action itself.
library;

import 'dart:async';

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
import '../../../profile/presentation/widgets/actor_identity.dart';
import '../../domain/entities/collaboration_enums.dart';
import '../../domain/entities/collaborator_limit.dart';
import '../../domain/entities/invitee_candidate.dart';
import '../../domain/entities/story_invitation.dart';
import '../../domain/entities/story_member.dart';
import '../controllers/collaboration_controller.dart';
import '../domain_labels.dart';
import '../providers/collaboration_providers.dart';
import '../widgets/capability_gate.dart';
import '../widgets/collaborator_seat_notice.dart';
import '../widgets/presence_bar.dart';
import '../widgets/role_badge.dart';

class CollaboratorsScreen extends ConsumerWidget {
  const CollaboratorsScreen({required this.storyId, super.key});

  final String storyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool enabled = ref.watch(appConfigProvider).enableCollaboration;
    // B6 seats (`platfrom/docs/45` §4.11). Read only while collaboration is on — a kill
    // switch that still talks to the server is not a kill switch. The provider never
    // throws, so a 403 (this route is `story.invite`-authorized) cannot break the screen.
    final CollaboratorLimit allowance = enabled
        ? ref.watch(storyCollaboratorLimitProvider(storyId)).asData?.value ??
              CollaboratorLimit.unknown
        : CollaboratorLimit.unknown;
    return Scaffold(
      appBar: QAppBar(
        title: 'Collaborators',
        actions: <Widget>[
          if (enabled)
            CapabilityGate(
              storyId: storyId,
              action: PolicyAction.storyInvite,
              child: IconButton(
                icon: const Icon(Icons.person_add_alt_1_outlined),
                tooltip: allowance.canInvite
                    ? 'Invite'
                    : 'Invite — no collaborator seats left on this plan',
                /*
                 * Disabled, never hidden. A free author must be able to SEE that
                 * collaboration exists and what it costs — hiding the affordance is the C-1
                 * defect (docs/48) and must not repeat here, while leaving it live to 402 is
                 * W3c-1. The tooltip carries the reason, so the disabled state explains
                 * itself to a screen reader instead of just going quiet.
                 */
                onPressed: allowance.canInvite
                    ? () => _showInviteSheet(context, ref)
                    : null,
              ),
            ),
        ],
      ),
      body: enabled
          ? _body(context, ref, allowance)
          : const QEmptyState(
              icon: Icons.group_outlined,
              title: 'Collaboration is off',
              message:
                  'Enable collaboration to co-write and review with others.',
            ),
    );
  }

  Widget _body(
    BuildContext context,
    WidgetRef ref,
    CollaboratorLimit allowance,
  ) {
    final AsyncValue<List<StoryMember>> async = ref.watch(
      storyMembersProvider(storyId),
    );
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace _) => QErrorView(
        failure: _failureOf(error),
        onRetry: () => ref.invalidate(storyMembersProvider(storyId)),
      ),
      data: (List<StoryMember> members) => RefreshIndicator(
        onRefresh: () async {
          ref
            ..invalidate(storyMembersProvider(storyId))
            ..invalidate(storyInvitationsProvider(storyId))
            ..invalidate(storyPresenceProvider(storyId))
            // The seat count moves with the roster, so it refreshes with it.
            ..invalidate(storyCollaboratorLimitProvider(storyId));
        },
        child: ListView(
          children: <Widget>[
            PresenceBar(storyId: storyId),
            Padding(
              padding: QSpacing.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // The upsell / limit notice sits ABOVE the roster, where the writer is
                  // already looking, and only for someone who could actually spend a seat.
                  CapabilityGate(
                    storyId: storyId,
                    action: PolicyAction.storyInvite,
                    child: CollaboratorSeatNotice(allowance: allowance),
                  ),
                  if (members.isEmpty)
                    const _SectionHeader('No collaborators yet')
                  else ...<Widget>[
                    Row(
                      children: <Widget>[
                        const Expanded(child: _SectionHeader('Members')),
                        // "2 of 3 collaborators" — the count BEFORE the wall.
                        CapabilityGate(
                          storyId: storyId,
                          action: PolicyAction.storyInvite,
                          child: CollaboratorSeatCount(allowance: allowance),
                        ),
                      ],
                    ),
                    Gap.v2,
                    for (final StoryMember member in members) ...<Widget>[
                      _MemberTile(storyId: storyId, member: member),
                      Gap.v2,
                    ],
                  ],
                  Gap.v3,
                  _PendingInvitations(storyId: storyId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The invite sheet (defect **M-1**, `platfrom/docs/48` §3.1).
  ///
  /// It asks for a **handle**, not an email: `POST /stories/{id}/invitations` takes an `inviteeId`
  /// and the backend has no invite-by-email path, so the old email field could never work. The
  /// handle is resolved to a real person first, the sheet shows who that is, and **Send** stays
  /// disabled until it resolves — so the writer confirms the target before anything is sent.
  Future<void> _showInviteSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _InviteSheet(storyId: storyId),
      ),
    );
  }
}

/// Handle → person → invitation. Stateful because it owns the resolve-as-you-type lifecycle.
class _InviteSheet extends ConsumerStatefulWidget {
  const _InviteSheet({required this.storyId});

  final String storyId;

  @override
  ConsumerState<_InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends ConsumerState<_InviteSheet> {
  final TextEditingController _handle = TextEditingController();
  Timer? _debounce;
  String _role = StoryRole.editor;
  InviteeCandidate? _resolved;
  bool _resolving = false;
  bool _notFound = false;
  bool _sending = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _handle.dispose();
    super.dispose();
  }

  /// Resolve after the typing settles — one lookup per handle, not one per keystroke.
  void _onHandleChanged(String raw) {
    _debounce?.cancel();
    final String username = raw.trim().replaceFirst(RegExp(r'^@+'), '');
    setState(() {
      _resolved = null;
      _notFound = false;
    });
    if (username.isEmpty) return;
    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => _resolve(username),
    );
  }

  Future<void> _resolve(String username) async {
    setState(() => _resolving = true);
    final InviteeCandidate? candidate = await ref
        .read(collaborationControllerProvider.notifier)
        .resolveInvitee(username);
    if (!mounted) return;
    setState(() {
      _resolving = false;
      _resolved = candidate;
      // A typo is the common case, so say so rather than failing at send time.
      _notFound = candidate == null;
    });
  }

  Future<void> _send() async {
    final InviteeCandidate? invitee = _resolved;
    if (invitee == null) return;
    setState(() => _sending = true);
    final StoryInvitation? invite = await ref
        .read(collaborationControllerProvider.notifier)
        .invite(storyId: widget.storyId, inviteeId: invitee.id, role: _role);
    if (!mounted) return;
    setState(() => _sending = false);
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    if (invite != null) navigator.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          invite == null
              ? _errorMessage(ref)
              : 'Invitation sent to ${invitee.label}.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: QSpacing.cardPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Invite a collaborator',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Gap.v3,
          TextField(
            controller: _handle,
            autocorrect: false,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: 'Handle',
              hintText: '@handle',
              errorText: _notFound ? 'No writer with that handle.' : null,
            ),
            onChanged: _onHandleChanged,
          ),
          Gap.v2,
          // Who is about to be invited — the confirmation the email field never gave.
          Text(
            _resolving
                ? 'Looking up…'
                : _resolved != null
                ? 'Inviting ${_resolved!.label} (@${_resolved!.username})'
                : 'Enter a handle to continue.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Gap.v3,
          DropdownButtonFormField<String>(
            initialValue: _role,
            decoration: const InputDecoration(labelText: 'Role'),
            items: <DropdownMenuItem<String>>[
              for (final String r in StoryRole.ordered)
                if (r != StoryRole.owner)
                  DropdownMenuItem<String>(value: r, child: Text(roleLabel(r))),
            ],
            onChanged: (String? value) =>
                setState(() => _role = value ?? _role),
          ),
          Gap.v4,
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              Gap.h3,
              Expanded(
                child: FilledButton(
                  // Disabled until a real person is resolved.
                  onPressed: (_resolved == null || _sending) ? null : _send,
                  child: const Text('Send invitation'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MemberTile extends ConsumerWidget {
  const _MemberTile({required this.storyId, required this.member});

  final String storyId;
  final StoryMember member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return QCard(
      padding: QCardPadding.md,
      child: Row(
        children: <Widget>[
          ActorAvatar(userId: member.userId, size: 40),
          Gap.h3,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ActorName(
                  userId: member.userId,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Gap.v1,
                RoleBadge(role: member.role),
              ],
            ),
          ),
          if (!member.isOwner)
            CapabilityGate(
              storyId: storyId,
              action: PolicyAction.storyManageMembers,
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (String value) => _onAction(context, ref, value),
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'role',
                    child: Text('Change role'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'remove',
                    child: Text('Remove'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _onAction(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    final CollaborationController controller = ref.read(
      collaborationControllerProvider.notifier,
    );
    // Resolved once, before the await: the row is on screen, so B3's lookup has
    // already landed and both messages name a person rather than an id.
    final String name = readActorDisplayName(ref, member.userId);
    if (action == 'remove') {
      final bool ok = await controller.removeMember(
        storyId: storyId,
        userId: member.userId,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? '$name removed.' : _errorMessage(ref))),
      );
    } else if (action == 'role') {
      final String? role = await _pickRole(context, member.role);
      if (role == null || !context.mounted) return;
      final StoryMember? updated = await controller.changeRole(
        storyId: storyId,
        userId: member.userId,
        role: role,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updated == null
                ? _errorMessage(ref)
                : '$name is now ${roleLabel(role)}.',
          ),
        ),
      );
    }
  }

  Future<String?> _pickRole(BuildContext context, String current) =>
      showModalBottomSheet<String>(
        context: context,
        builder: (BuildContext ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final String role in StoryRole.ordered)
                if (role != StoryRole.owner)
                  ListTile(
                    title: Text(roleLabel(role)),
                    trailing: role == current ? const Icon(Icons.check) : null,
                    onTap: () => Navigator.pop(ctx, role),
                  ),
            ],
          ),
        ),
      );
}

class _PendingInvitations extends ConsumerWidget {
  const _PendingInvitations({required this.storyId});

  final String storyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<StoryInvitation>> async = ref.watch(
      storyInvitationsProvider(storyId),
    );
    return async.maybeWhen(
      orElse: () => const SizedBox.shrink(),
      data: (List<StoryInvitation> invites) {
        final List<StoryInvitation> pending = invites
            .where((StoryInvitation i) => i.isPending)
            .toList(growable: false);
        if (pending.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const _SectionHeader('Pending invitations'),
            Gap.v2,
            for (final StoryInvitation invite in pending) ...<Widget>[
              QCard(
                padding: QCardPadding.md,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Ids are all `InvitationDto` gives for an invitee;
                          // B3's by-id lookup turns one into a real name.
                          ActorName(userId: invite.inviteeId),
                          Gap.v1,
                          RoleBadge(role: invite.role),
                        ],
                      ),
                    ),
                    CapabilityGate(
                      storyId: storyId,
                      action: PolicyAction.storyInvite,
                      child: TextButton(
                        onPressed: () async {
                          final bool ok = await ref
                              .read(collaborationControllerProvider.notifier)
                              .revokeInvitation(invite.id);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                ok ? 'Invitation revoked.' : _errorMessage(ref),
                              ),
                            ),
                          );
                        },
                        child: const Text('Revoke'),
                      ),
                    ),
                  ],
                ),
              ),
              Gap.v2,
            ],
          ],
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
  );
}

Failure _failureOf(Object error) => error is Failure
    ? error
    : Failure.unexpected(code: ErrorCodes.apiUnexpected, message: '$error');

String _errorMessage(WidgetRef ref) {
  final Object? err = ref.read(collaborationControllerProvider).error;
  return err is Failure ? err.message : 'Something went wrong.';
}
