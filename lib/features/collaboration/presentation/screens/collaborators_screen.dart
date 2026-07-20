/// Collaborators screen (AF6) — the membership home for a story. Lists collaborators
/// with their role, drives capability-gated management (change role / remove / invite),
/// shows a live presence bar, and surfaces outstanding invitations. Every management
/// affordance is wrapped in a [CapabilityGate] on the policy action; the server
/// re-checks on the action itself.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/error/failure.dart';
import '../../../../shared/domain/error_codes.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/cards/q_card.dart';
import '../../../../shared/widgets/media/q_avatar.dart';
import '../../../../shared/widgets/states/q_empty_state.dart';
import '../../../../shared/widgets/states/q_error_view.dart';
import '../../domain/entities/collaboration_enums.dart';
import '../../domain/entities/story_invitation.dart';
import '../../domain/entities/story_member.dart';
import '../controllers/collaboration_controller.dart';
import '../domain_labels.dart';
import '../providers/collaboration_providers.dart';
import '../widgets/capability_gate.dart';
import '../widgets/presence_bar.dart';
import '../widgets/role_badge.dart';

class CollaboratorsScreen extends ConsumerWidget {
  const CollaboratorsScreen({required this.storyId, super.key});

  final String storyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool enabled = ref.watch(appConfigProvider).enableCollaboration;
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
                tooltip: 'Invite',
                onPressed: () => _showInviteSheet(context, ref),
              ),
            ),
        ],
      ),
      body: enabled
          ? _body(context, ref)
          : const QEmptyState(
              icon: Icons.group_outlined,
              title: 'Collaboration is off',
              message:
                  'Enable collaboration to co-write and review with others.',
            ),
    );
  }

  Widget _body(BuildContext context, WidgetRef ref) {
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
            ..invalidate(storyPresenceProvider(storyId));
        },
        child: ListView(
          children: <Widget>[
            PresenceBar(storyId: storyId),
            Padding(
              padding: QSpacing.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (members.isEmpty)
                    const _SectionHeader('No collaborators yet')
                  else ...<Widget>[
                    const _SectionHeader('Members'),
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

  Future<void> _showInviteSheet(BuildContext context, WidgetRef ref) async {
    final TextEditingController emailController = TextEditingController();
    String role = StoryRole.editor;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setState) => Padding(
            padding: QSpacing.cardPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Invite a collaborator',
                  style: Theme.of(ctx).textTheme.titleLarge,
                ),
                Gap.v3,
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'name@example.com',
                  ),
                ),
                Gap.v3,
                DropdownButtonFormField<String>(
                  initialValue: role,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: <DropdownMenuItem<String>>[
                    for (final String r in StoryRole.ordered)
                      if (r != StoryRole.owner)
                        DropdownMenuItem<String>(
                          value: r,
                          child: Text(roleLabel(r)),
                        ),
                  ],
                  onChanged: (String? value) =>
                      setState(() => role = value ?? role),
                ),
                Gap.v4,
                FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    final String email = emailController.text.trim();
    emailController.dispose();
    if (email.isEmpty || !context.mounted) return;
    final StoryInvitation? invite = await ref
        .read(collaborationControllerProvider.notifier)
        .invite(storyId: storyId, role: role, email: email);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          invite == null ? _errorMessage(ref) : 'Invitation sent to $email.',
        ),
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
          QAvatar(name: member.label, size: 40),
          Gap.h3,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  member.label,
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
    if (action == 'remove') {
      final bool ok = await controller.removeMember(
        storyId: storyId,
        userId: member.userId,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? '${member.label} removed.' : _errorMessage(ref)),
        ),
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
                : '${member.label} is now ${roleLabel(role)}.',
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
                          Text(
                            invite.inviteeEmail ??
                                invite.inviteeUserId ??
                                'Invited user',
                          ),
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
