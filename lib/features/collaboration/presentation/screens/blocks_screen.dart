/// Safety settings (`/settings/blocks`, AF6) — the people the viewer has blocked or
/// muted, plus their own account standing.
///
/// **The data layer for this shipped with AF6 and reached nothing.** `TrustRepository`
/// has had `myBlocks` / `block` / `unblock` / `mute` / `unmute` since then and
/// `myBlocksProvider` had zero consumers, so a mobile reader could not see who they had
/// blocked, let alone undo it (docs/48 §3.3, M-4). Web built the surface first in W3c;
/// this is the port.
///
/// Standing lives here rather than on a page of its own: `GET /me/trust` is
/// account-scoped like the block list and the two are read together. The detailed
/// restricted wall keeps its own route (`/restricted`, reached from the restricted
/// banner) — this states the standing in one line and links to it.
///
/// In good standing that line is reassuring rather than a warning: most viewers will see
/// it, and a safety screen that looks alarming by default trains people to ignore it.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/di/providers.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/cards/q_card.dart';
import '../../../../shared/widgets/feedback/q_dialog.dart';
import '../../../../shared/widgets/states/q_empty_state.dart';
import '../../../profile/presentation/widgets/actor_identity.dart';
import '../../domain/entities/block_entry.dart';
import '../../domain/entities/trust_summary.dart';
import '../controllers/trust_controller.dart';
import '../domain_labels.dart';
import '../providers/collaboration_providers.dart';

class BlocksScreen extends ConsumerWidget {
  const BlocksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(appConfigProvider).enableCollaboration) {
      return const Scaffold(
        appBar: QAppBar(title: 'Safety'),
        body: QEmptyState(
          icon: Icons.shield_outlined,
          title: 'Blocking isn’t available yet',
          message: 'Blocking and muting arrive with collaboration.',
        ),
      );
    }

    return Scaffold(
      appBar: const QAppBar(title: 'Safety'),
      body: RefreshIndicator(
        onRefresh: () async {
          ref
            ..invalidate(trustSummaryProvider)
            ..invalidate(myBlocksProvider);
        },
        child: ListView(
          padding: QSpacing.pagePadding,
          children: <Widget>[
            Text(
              'Who you’ve blocked or muted, and how your account stands.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Gap.v4,
            Text(
              'Account standing',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Gap.v2,
            const _StandingCard(),
            Gap.v4,
            Text(
              'Blocked and muted',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Gap.v1,
            Text(
              'Blocking stops interaction both ways. Muting only hides someone '
              'from you, and they aren’t told.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Gap.v2,
            const _BlockList(),
          ],
        ),
      ),
    );
  }
}

/// The viewer's own standing, one line plus any active restrictions.
class _StandingCard extends ConsumerWidget {
  const _StandingCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<TrustSummary> async = ref.watch(trustSummaryProvider);
    return QCard(
      child: async.when(
        loading: () => const Text('Loading…'),
        // Fails open, like every other trust read: an unavailable standing must not
        // read as a bad one. The server enforces regardless.
        error: (_, _) => const Text('Your standing isn’t available right now.'),
        data: (TrustSummary trust) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  trust.isRestricted
                      ? Icons.gpp_maybe_outlined
                      : Icons.verified_user_outlined,
                  size: 20,
                ),
                const SizedBox(width: QSpacing.s2),
                Expanded(
                  child: Text(
                    trustStatusLabel(trust.status),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            Gap.v1,
            Text(
              trust.isRestricted
                  ? 'Some actions are limited on your account.'
                  : 'You have full access to writing, commenting and publishing.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            for (final UserRestriction restriction
                in trust.activeRestrictions) ...<Widget>[
              Gap.v2,
              Text(
                '${restrictionTypeLabel(restriction.type)} · '
                '${restrictionScopeLabel(restriction.scope)}'
                '${restriction.reason.isEmpty ? '' : ' — ${restriction.reason}'}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (trust.isRestricted) ...<Widget>[
              Gap.v2,
              InkWell(
                onTap: () => context.push(Routes.trustRestricted),
                child: Text(
                  'See what this means',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Both kinds in one list, because one endpoint returns both, distinguished by `kind`.
/// They are genuinely different promises — a block severs interaction both ways, a mute
/// only hides someone from the viewer — so each row says which it is and removal calls
/// the matching route.
class _BlockList extends ConsumerWidget {
  const _BlockList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<BlockEntry>> async = ref.watch(myBlocksProvider);
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: QSpacing.s4),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const Text('Couldn’t load your blocked list.'),
      data: (List<BlockEntry> entries) => entries.isEmpty
          ? Text(
              'You haven’t blocked or muted anyone. You can block someone from '
              'their profile.',
              style: Theme.of(context).textTheme.bodySmall,
            )
          : Column(
              children: <Widget>[
                for (final BlockEntry entry in entries) _BlockRow(entry: entry),
              ],
            ),
    );
  }
}

class _BlockRow extends ConsumerWidget {
  const _BlockRow({required this.entry});

  final BlockEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool busy = ref.watch(trustControllerProvider).isLoading;
    final bool mute = entry.isMute;
    return QCard(
      padding: QCardPadding.md,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // `BlockDto` carries ids only — no username, no display name — so
                // the blocked person is resolved by id (B3).
                ActorName(
                  userId: entry.blockedId,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Gap.v1,
                Text(
                  entry.createdAt == null
                      ? (mute ? 'Muted' : 'Blocked')
                      : '${mute ? 'Muted' : 'Blocked'} · '
                            '${formatCollaborationDate(entry.createdAt!)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: busy ? null : () => _remove(context, ref),
            child: Text(mute ? 'Unmute' : 'Unblock'),
          ),
        ],
      ),
    );
  }

  Future<void> _remove(BuildContext context, WidgetRef ref) async {
    final bool mute = entry.isMute;
    final bool confirmed = await QDialog.confirm(
      context,
      title: mute ? 'Unmute this person?' : 'Unblock this person?',
      message: mute
          ? 'Their writing will appear in your feed again.'
          : 'You will both be able to see and interact with each other again.',
      confirmLabel: mute ? 'Unmute' : 'Unblock',
    );
    if (!confirmed) return;

    final TrustController controller = ref.read(
      trustControllerProvider.notifier,
    );
    // `blockedId` — the USER. `entry.id` is the block relationship's own id, and
    // passing it is defect T-1: the route reaches the service with the wrong UUID and
    // 404s `BLOCK_NOT_FOUND`, so unblocking silently never works.
    final bool ok = mute
        ? await controller.unmute(entry.blockedId)
        : await controller.unblock(entry.blockedId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? (mute ? 'Unmuted.' : 'Unblocked.')
              : 'That didn’t work. Please try again.',
        ),
      ),
    );
  }
}
