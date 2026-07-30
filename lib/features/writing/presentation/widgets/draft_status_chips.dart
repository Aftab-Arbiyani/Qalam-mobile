/// Small status affordances for the editor + drafts list (M4): the autosave
/// indicator, the sync-state chip, the piece-status chip, and the offline chip.
/// Presentation-only; they read state passed in or from providers and render.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/connectivity/connectivity_providers.dart';
import '../../../../shared/domain/enums.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/radius_tokens.dart';
import '../../domain/entities/draft_sync.dart';

/// "Saving…" / "Saved" — the debounced-autosave indicator (docs/40 §UX).
class AutosaveIndicator extends StatelessWidget {
  const AutosaveIndicator({
    required this.autosaving,
    required this.saved,
    super.key,
  });

  final bool autosaving;
  final bool saved;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final (IconData icon, String label) = autosaving
        ? (Icons.sync, 'Saving…')
        : (Icons.check, saved ? 'Saved' : 'Draft');
    return Semantics(
      liveRegion: true,
      label: label,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: tokens.colors.textMuted),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: tokens.colors.textMuted),
          ),
        ],
      ),
    );
  }
}

/// A chip for a draft's sync state (drives the "synchronization status" surface).
class SyncStateChip extends StatelessWidget {
  const SyncStateChip({required this.state, super.key});

  final DraftSyncState state;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final (IconData icon, String label, Color color) = switch (state) {
      DraftSyncState.synced => (
        Icons.cloud_done_outlined,
        'Synced',
        tokens.colors.successText,
      ),
      DraftSyncState.pending => (
        Icons.cloud_queue_outlined,
        'Not synced',
        tokens.colors.textMuted,
      ),
      DraftSyncState.syncing => (Icons.sync, 'Syncing…', tokens.colors.info),
      DraftSyncState.failed => (
        Icons.error_outline,
        'Sync failed',
        tokens.colors.danger,
      ),
      DraftSyncState.conflict => (
        Icons.merge_type,
        'Conflict',
        tokens.colors.warningText,
      ),
    };
    return Semantics(
      label: 'Sync status: $label',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}

/// A chip for a piece's lifecycle status (Draft / Scheduled / Published / Archived).
class PieceStatusChip extends StatelessWidget {
  const PieceStatusChip({required this.status, super.key});

  final PieceStatus status;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final (String label, Color bg, Color fg) = switch (status) {
      PieceStatus.draft => (
        'Draft',
        tokens.colors.bgRaised,
        tokens.colors.textSecondary,
      ),
      PieceStatus.scheduled => (
        'Scheduled',
        tokens.colors.infoBg,
        tokens.colors.infoText,
      ),
      PieceStatus.published => (
        'Published',
        tokens.colors.successBg,
        tokens.colors.successText,
      ),
      PieceStatus.archived => (
        'Archived',
        tokens.colors.bgRaised,
        tokens.colors.textMuted,
      ),
    };
    return DecoratedBox(
      decoration: BoxDecoration(color: bg, borderRadius: QRadii.controlRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: fg,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// A compact offline chip, hidden while online.
class OfflineChip extends ConsumerWidget {
  const OfflineChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool online = ref
        .watch(connectivityStatusProvider)
        .maybeWhen(data: (bool value) => value, orElse: () => true);
    if (online) return const SizedBox.shrink();
    final QTokens tokens = QTokens.of(context);
    return Semantics(
      label: 'Offline',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.cloud_off, size: 14, color: tokens.colors.warningText),
          const SizedBox(width: 4),
          Text(
            'Offline',
            style: TextStyle(fontSize: 12, color: tokens.colors.warningText),
          ),
        ],
      ),
    );
  }
}
