/// The synchronization status sheet (docs/40 §23) — the "Queue Status" +
/// "Synchronization History" surface. Shows the live [SyncStatus], the queued
/// operations (pending / failed / conflict) with per-item retry / discard / resolve
/// actions, a "Sync now" + "Retry all" control, and the durable history log. Reads
/// everything from the unified engine's providers; mutations go through the engine.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/sync/sync_engine.dart';
import '../../../core/sync/sync_history.dart';
import '../../../core/sync/sync_operation.dart';
import '../../../core/sync/sync_providers.dart';
import '../../../core/sync/sync_status.dart';
import '../../theme/q_tokens.dart';
import '../../theme/tokens/radius_tokens.dart';
import '../../theme/tokens/spacing_tokens.dart';
import '../../util/relative_time.dart';
import 'conflict_resolution_dialog.dart';

Future<void> showSyncStatusSheet(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (BuildContext context) => const _SyncStatusSheet(),
);

class _SyncStatusSheet extends ConsumerWidget {
  const _SyncStatusSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SyncStatus status = ref.watch(syncStatusProvider);
    final List<SyncOperation> ops = ref.watch(syncOperationsProvider);
    final List<SyncHistoryEntry> history = ref.watch(syncHistoryProvider);
    final SyncEngine engine = ref.read(syncEngineProvider);
    final ThemeData theme = Theme.of(context);
    final QTokens tokens = QTokens.of(context);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            QSpacing.s5,
            0,
            QSpacing.s5,
            QSpacing.s5,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Synchronization', style: theme.textTheme.titleLarge),
              Gap.v1,
              Text(
                _summary(status),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: tokens.colors.textSecondary,
                ),
              ),
              Gap.v4,
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: status.isOffline
                          ? null
                          : () => engine.sync(respectBackoff: false),
                      icon: const Icon(Icons.sync, size: 18),
                      label: const Text('Sync now'),
                    ),
                  ),
                  if (status.failed > 0) ...<Widget>[
                    Gap.h2,
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: engine.retryFailed,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Retry all'),
                      ),
                    ),
                  ],
                ],
              ),
              if (ops.isNotEmpty) ...<Widget>[
                Gap.v5,
                Text('Queue', style: theme.textTheme.titleSmall),
                Gap.v2,
                for (final SyncOperation op in ops)
                  _OperationTile(op: op, engine: engine),
              ],
              if (history.isNotEmpty) ...<Widget>[
                Gap.v5,
                Text('History', style: theme.textTheme.titleSmall),
                Gap.v2,
                for (final SyncHistoryEntry entry in history.take(20))
                  _HistoryTile(entry: entry),
              ],
              if (ops.isEmpty && history.isEmpty) ...<Widget>[
                Gap.v6,
                Center(
                  child: Text(
                    'Nothing to sync. You’re all caught up.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: tokens.colors.textSecondary,
                    ),
                  ),
                ),
                Gap.v6,
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _summary(SyncStatus status) {
    if (status.isOffline) {
      return 'You’re offline. ${status.outstanding} change(s) will sync when you reconnect.';
    }
    if (status.isSyncing) return 'Syncing ${status.outstanding} change(s)…';
    if (status.needsAttention) {
      return '${status.failed} failed, ${status.conflicts} need resolving.';
    }
    if (status.pending > 0) return '${status.pending} change(s) pending.';
    return 'All changes are synced.';
  }
}

class _OperationTile extends StatelessWidget {
  const _OperationTile({required this.op, required this.engine});

  final SyncOperation op;
  final SyncEngine engine;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final QTokens tokens = QTokens.of(context);
    final (IconData icon, Color color, String state) = switch (op.status) {
      SyncOpStatus.conflict => (
        Icons.merge_type,
        tokens.colors.warning,
        'Conflict',
      ),
      SyncOpStatus.failed => (
        Icons.error_outline,
        tokens.colors.danger,
        'Failed',
      ),
      SyncOpStatus.inFlight => (Icons.sync, tokens.colors.info, 'Syncing'),
      SyncOpStatus.pending => (
        Icons.schedule,
        tokens.colors.textMuted,
        'Pending',
      ),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: QSpacing.s1),
      child: Container(
        padding: const EdgeInsets.all(QSpacing.s3),
        decoration: BoxDecoration(
          color: tokens.colors.bgRaised,
          borderRadius: QRadii.controlRadius,
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 18, color: color),
            Gap.h3,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    op.label ?? _prettyType(op.type),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    state,
                    style: theme.textTheme.labelSmall?.copyWith(color: color),
                  ),
                ],
              ),
            ),
            if (op.status == SyncOpStatus.conflict)
              TextButton(
                onPressed: () async {
                  final ConflictResolution? choice =
                      await showConflictResolutionDialog(context, op);
                  if (choice != null) {
                    await engine.resolveConflict(op.storageKey, choice);
                  }
                },
                child: const Text('Resolve'),
              )
            else if (op.status == SyncOpStatus.failed) ...<Widget>[
              IconButton(
                tooltip: 'Retry',
                onPressed: () => engine.retry(op.storageKey),
                icon: const Icon(Icons.refresh, size: 18),
              ),
              IconButton(
                tooltip: 'Discard',
                onPressed: () => engine.discard(op.storageKey),
                icon: const Icon(Icons.delete_outline, size: 18),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _prettyType(String type) =>
      type.replaceAll('.', ' · ').replaceAll('_', ' ');
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry});

  final SyncHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final QTokens tokens = QTokens.of(context);
    final (IconData icon, Color color) = switch (entry.result) {
      SyncHistoryResult.synced => (Icons.check_circle_outline, tokens.colors.success),
      SyncHistoryResult.dropped => (Icons.remove_circle_outline, tokens.colors.textMuted),
      SyncHistoryResult.failed => (Icons.error_outline, tokens.colors.danger),
      SyncHistoryResult.conflict => (Icons.merge_type, tokens.colors.warning),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 16, color: color),
          Gap.h2,
          Expanded(
            child: Text(
              entry.label ?? entry.type.replaceAll('.', ' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
          ),
          Text(
            relativeTime(entry.at),
            style: theme.textTheme.labelSmall?.copyWith(
              color: tokens.colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
