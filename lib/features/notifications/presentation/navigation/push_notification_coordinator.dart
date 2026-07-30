/// The push ↔ app bridge (docs/40 §31, §32) — the single place that turns push /
/// local notification events into app behavior, keeping Firebase-facing code in
/// `core/` and out of every widget. It:
///   • routes a notification TAP (local, background push, or terminated-launch
///     push) through the app router via [routeForNotification]/[routeForPushData];
///   • on a FOREGROUND push, presents it locally and refreshes the inbox + badge.
///
/// Phase 1 the push service is inert ([NoopPushMessagingService]) so only local
/// notification taps flow through; when FCM lands behind the same interface, push
/// taps and foreground messages light up here with no change to callers. Wired to
/// the router + provider invalidation via plain callbacks so it is unit-testable
/// with fakes (no `Ref`/`BuildContext`).
library;

import 'dart:async';

import '../../../../core/logging/app_logger.dart';
import '../../../../core/notifications/local_notification_service.dart';
import '../../../../core/notifications/notification_channels.dart';
import '../../../../core/notifications/push_messaging_service.dart';
import 'notification_deep_link.dart';

class PushNotificationCoordinator {
  PushNotificationCoordinator({
    required PushMessagingService push,
    required LocalNotificationService local,
    required void Function(String route) navigate,
    required void Function() onInboxChanged,
    required AppLogger logger,
  }) : _push = push,
       _local = local,
       _navigate = navigate,
       _onInboxChanged = onInboxChanged,
       _logger = logger;

  final PushMessagingService _push;
  final LocalNotificationService _local;
  final void Function(String route) _navigate;
  final void Function() _onInboxChanged;
  final AppLogger _logger;

  final List<StreamSubscription<Object?>> _subs =
      <StreamSubscription<Object?>>[];
  bool _started = false;

  /// Idempotent. Subscribes to tap + foreground streams, initializes local
  /// notifications (channels + tap handler), then replays any notification that
  /// cold-launched the app. Subscriptions are wired BEFORE init so a cold-launch
  /// route (emitted during init) is not missed.
  Future<void> start() async {
    if (_started) return;
    _started = true;
    _subs.add(_local.onSelectRoute.listen(_navigate));
    _subs.add(_push.onMessageOpenedApp.listen(_openTapped));
    _subs.add(_push.onMessage.listen(_presentForeground));
    try {
      await _local.initialize();
    } on Object catch (e, s) {
      _logger.recordError(e, s, reason: 'localNotifications.init');
    }
    try {
      final PushMessage? initial = await _push.initialMessage();
      if (initial != null) _openTapped(initial);
    } on Object catch (e, s) {
      _logger.recordError(e, s, reason: 'push.initialMessage');
    }
  }

  void _openTapped(PushMessage message) {
    final String? route = _routeFor(message);
    if (route != null) _navigate(route);
  }

  Future<void> _presentForeground(PushMessage message) async {
    final String title = message.data['title'] ?? 'Qalam';
    final String body = message.data['body'] ?? '';
    await _local.show(
      LocalNotification(
        id: _idFor(message),
        title: title,
        body: body,
        channel: _channelFor(message),
        route: _routeFor(message),
      ),
    );
    // A foreground push means the inbox/badge are now stale — refresh them.
    _onInboxChanged();
  }

  String? _routeFor(PushMessage message) =>
      message.route ?? routeForPushData(message.data);

  NotificationChannelKind _channelFor(PushMessage message) =>
      (message.data['entityType'] == 'system' ||
          message.data['type'] == 'system')
      ? NotificationChannelKind.system
      : NotificationChannelKind.social;

  /// A stable-ish notification id from the payload's entity id (falls back to a
  /// bounded hash) so re-delivery replaces rather than stacks.
  int _idFor(PushMessage message) {
    final String? key = message.data['entityId'] ?? message.data['id'];
    return (key ?? message.data.toString()).hashCode & 0x7fffffff;
  }

  Future<void> dispose() async {
    for (final StreamSubscription<Object?> sub in _subs) {
      await sub.cancel();
    }
    _subs.clear();
  }
}
