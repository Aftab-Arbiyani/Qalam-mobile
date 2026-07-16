/// The one follow/unfollow control (docs/40 §21.4, E5) — used by the reader's
/// author card, a writer's profile header, and every followers/following row, so
/// follow UX lives in ONE place (docs/40 §44). Seeded with the initial relation,
/// it owns its optimistic button state: an immediate flip, an online call to the
/// shared [EngagementRepository], or (offline) an enqueue into the shared
/// [SocialSyncEngine]; a failure rolls the button back. [onChanged] lets the host
/// adjust a follower count optimistically. Hidden for self / signed-out viewers.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/session/session_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../domain/enums.dart';
import '../../social/domain/value_objects/queued_social_action.dart';
import '../../social/social_providers.dart';
import '../buttons/q_button.dart';
import '../feedback/q_snackbar.dart';
import '../haptics/q_haptics.dart';

class FollowButton extends ConsumerStatefulWidget {
  const FollowButton({
    required this.userId,
    required this.isPrivate,
    this.isSelf = false,
    this.initiallyFollowing = false,
    this.initiallyPending = false,
    this.size = QButtonSize.sm,
    this.onChanged,
    super.key,
  });

  final String userId;
  final bool isPrivate;
  final bool isSelf;
  final bool initiallyFollowing;
  final bool initiallyPending;
  final QButtonSize size;

  /// Called after an optimistic toggle with the new following state — the host
  /// adjusts its follower count. Called again with the reverted value on rollback.
  final ValueChanged<bool>? onChanged;

  @override
  ConsumerState<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends ConsumerState<FollowButton> {
  late bool _following = widget.initiallyFollowing;
  late bool _pending = widget.initiallyPending;
  bool _busy = false;

  bool get _active => _following || _pending;

  @override
  Widget build(BuildContext context) {
    if (widget.isSelf) return const SizedBox.shrink();
    final bool authed =
        ref.watch(sessionControllerProvider).stateOrUnknown.isAuthenticated;
    if (!authed) return const SizedBox.shrink();

    final AppLocalizations l10n = AppLocalizations.of(context);
    final String label = _pending
        ? l10n.followRequested
        : (_following ? l10n.followFollowing : l10n.followFollow);

    return QButton(
      label: label,
      size: widget.size,
      loading: _busy,
      variant: _active ? QButtonVariant.secondary : QButtonVariant.primary,
      onPressed: _busy ? null : _toggle,
    );
  }

  Future<void> _toggle() async {
    await QHaptics.selection();
    final bool wasFollowing = _following;
    final bool wasPending = _pending;

    // Optimistic flip.
    final bool nowFollowing;
    if (wasFollowing || wasPending) {
      nowFollowing = false;
      setState(() {
        _following = false;
        _pending = false;
      });
    } else {
      nowFollowing = !widget.isPrivate;
      setState(() {
        _following = !widget.isPrivate;
        _pending = widget.isPrivate;
      });
    }
    widget.onChanged?.call(nowFollowing);

    final bool desired = !(wasFollowing || wasPending);
    final bool online = ref.read(connectivityServiceProvider).isOnline;

    if (!online) {
      await ref
          .read(socialSyncEngineProvider)
          .enqueue(
            QueuedSocialAction(
              category: SocialCategory.userFollow,
              targetId: widget.userId,
              desired: desired,
              createdAt: DateTime.now(),
            ),
          );
      return;
    }

    setState(() => _busy = true);
    final repo = ref.read(engagementRepositoryProvider);
    final result = desired
        ? await repo.follow(widget.userId)
        : await repo.unfollow(widget.userId);
    if (!mounted) return;
    setState(() => _busy = false);

    if (result.isErr) {
      // Rollback.
      setState(() {
        _following = wasFollowing;
        _pending = wasPending;
      });
      widget.onChanged?.call(wasFollowing);
      QSnackbar.show(
        context,
        message: AppLocalizations.of(context).socialActionFailed,
        variant: QSnackbarVariant.danger,
      );
    } else if (desired) {
      // Reconcile pending vs accepted from the server status.
      final FollowStatus status =
          (result.valueOrNull as FollowStatus?) ?? FollowStatus.accepted;
      final bool accepted = status == FollowStatus.accepted;
      setState(() {
        _following = accepted;
        _pending = !accepted;
      });
    }
  }
}
