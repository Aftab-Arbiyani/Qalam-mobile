/// The synchronization indicator (docs/40 §23) — a compact app-bar control that
/// reflects the unified [SyncEngine]'s published [SyncStatus] and opens the sync
/// status sheet. It animates while syncing, badges outstanding work, and turns to
/// the warning colour when items need attention (failed / conflict). Fully
/// accessible: one semantics button whose label states the current sync state.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/sync/sync_providers.dart';
import '../../../core/sync/sync_status.dart';
import '../../theme/q_tokens.dart';
import 'sync_status_sheet.dart';

class SyncIndicator extends ConsumerWidget {
  const SyncIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SyncStatus status = ref.watch(syncStatusProvider);
    final QTokens tokens = QTokens.of(context);

    final (IconData icon, Color color, String label) = switch (status.phase) {
      SyncPhase.offline => (
        Icons.cloud_off_outlined,
        tokens.colors.textMuted,
        'Offline. ${status.outstanding} change(s) will sync when you reconnect.',
      ),
      SyncPhase.syncing => (
        Icons.sync,
        tokens.colors.info,
        'Syncing ${status.outstanding} change(s).',
      ),
      SyncPhase.error => (
        Icons.sync_problem_outlined,
        tokens.colors.warning,
        'Sync needs attention: ${status.failed} failed, ${status.conflicts} conflict(s).',
      ),
      SyncPhase.idle => (
        Icons.cloud_done_outlined,
        tokens.colors.textSecondary,
        status.hasWork
            ? '${status.pending} change(s) pending sync.'
            : 'All changes synced.',
      ),
    };

    return Semantics(
      button: true,
      label: label,
      child: IconButton(
        tooltip: 'Sync status',
        onPressed: () => showSyncStatusSheet(context),
        icon: _IndicatorGlyph(
          icon: icon,
          color: color,
          spinning: status.isSyncing,
          badge: status.outstanding,
          badgeColor: status.needsAttention
              ? tokens.colors.danger
              : tokens.colors.accent,
        ),
      ),
    );
  }
}

class _IndicatorGlyph extends StatefulWidget {
  const _IndicatorGlyph({
    required this.icon,
    required this.color,
    required this.spinning,
    required this.badge,
    required this.badgeColor,
  });

  final IconData icon;
  final Color color;
  final bool spinning;
  final int badge;
  final Color badgeColor;

  @override
  State<_IndicatorGlyph> createState() => _IndicatorGlyphState();
}

class _IndicatorGlyphState extends State<_IndicatorGlyph>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );

  @override
  void initState() {
    super.initState();
    if (widget.spinning) _controller.repeat();
  }

  @override
  void didUpdateWidget(_IndicatorGlyph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.spinning && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.spinning && _controller.isAnimating) {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget glyph = widget.spinning
        ? RotationTransition(
            turns: _controller,
            child: Icon(widget.icon, color: widget.color),
          )
        : Icon(widget.icon, color: widget.color);

    if (widget.badge <= 0) return glyph;

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        glyph,
        Positioned(
          right: -4,
          top: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            constraints: const BoxConstraints(minWidth: 16),
            decoration: BoxDecoration(
              color: widget.badgeColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.badge > 99 ? '99+' : '${widget.badge}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
