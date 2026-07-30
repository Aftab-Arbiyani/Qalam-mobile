/// The unread-count controller (docs/40 §32.1) — the small Live-tier polled
/// provider that drives the nav badge. Fetches on build, polls every 30s, and
/// refreshes on reconnect and on app resume (polling pauses while backgrounded to
/// respect the Live tier and battery, §32.1). keepAlive because the badge lives on
/// the persistent shell. Exposes [applyDelta]/[reset] so an optimistic read in the
/// inbox zeroes the badge instantly without waiting for the next poll (docs/40
/// §21.4). A fetch failure keeps the last known value — the badge never flickers.
library;

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/connectivity/connectivity_providers.dart';
import '../../../../shared/domain/limits.dart';
import '../../domain/entities/unread_count.dart';
import '../providers/notification_providers.dart';

part 'unread_count_controller.g.dart';

@Riverpod(keepAlive: true)
class UnreadCountController extends _$UnreadCountController {
  static const Duration _pollInterval = Duration(seconds: 30);

  Timer? _timer;
  AppLifecycleListener? _lifecycle;

  @override
  Future<UnreadCount> build() async {
    // Refresh the moment connectivity is restored (docs/40 §24).
    ref.listen(connectivityStatusProvider, (_, AsyncValue<bool> next) {
      if (next.asData?.value ?? false) unawaited(refresh());
    });
    _startPolling();
    _lifecycle = AppLifecycleListener(
      onResume: () {
        _startPolling();
        unawaited(refresh());
      },
      onHide: _stopPolling,
      onPause: _stopPolling,
    );
    ref.onDispose(() {
      _stopPolling();
      _lifecycle?.dispose();
    });
    final UnreadCount? initial = await _fetch();
    return initial ?? UnreadCount.zero;
  }

  /// Re-fetch, keeping the last value on failure (the badge stays calm).
  Future<void> refresh() async {
    final UnreadCount? next = await _fetch();
    if (next != null) state = AsyncData<UnreadCount>(next);
  }

  Future<UnreadCount?> _fetch() async {
    final result = await ref.read(notificationRepositoryProvider).unreadCount();
    return result
        .valueOrNull; // null on failure → caller keeps last known value
  }

  /// Optimistically adjust the count (e.g. −1 when a row is marked read). Clamped
  /// at zero; [UnreadCount.capped] is recomputed against the display cap.
  void applyDelta(int delta) {
    final UnreadCount? current = state.asData?.value;
    if (current == null) return;
    final int next = current.count + delta;
    final int clamped = next < 0 ? 0 : next;
    state = AsyncData<UnreadCount>(
      current.copyWith(
        count: clamped,
        capped: clamped > Limits.notificationUnreadDisplayCap,
      ),
    );
  }

  /// Zero the badge (mark-all-read).
  void reset() => state = const AsyncData<UnreadCount>(UnreadCount.zero);

  void _startPolling() {
    _timer ??= Timer.periodic(_pollInterval, (_) => unawaited(refresh()));
  }

  void _stopPolling() {
    _timer?.cancel();
    _timer = null;
  }
}
