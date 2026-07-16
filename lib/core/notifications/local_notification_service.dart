/// Local (on-device) notifications (docs/40 §33) — foreground presentation of an
/// incoming push (Phase-2 seam) and the opt-in scheduled-reminder seam, behind a
/// `core/notifications` interface so no widget or feature imports the plugin
/// directly (docs/40 §31). The concrete [FlutterLocalNotificationService] backs
/// this with `flutter_local_notifications`; tests bind [NoopLocalNotificationService].
///
/// Every notification carries the same `route` payload as a push, so tapping one
/// deep-links through the app router (§12.4) — the service surfaces tapped routes
/// on [onSelectRoute]; the app coordinator navigates.
library;

import 'notification_channels.dart';

/// A local notification to present or schedule.
class LocalNotification {
  const LocalNotification({
    required this.id,
    required this.title,
    required this.body,
    this.channel = NotificationChannelKind.social,
    this.route,
    this.scheduledAt,
    this.badgeCount,
  });

  final int id;
  final String title;
  final String body;

  /// Which channel (Android) / category this belongs to.
  final NotificationChannelKind channel;

  /// Deep-link route to open on tap (docs/40 §12.4). Carried through to the OS
  /// notification payload and surfaced on [LocalNotificationService.onSelectRoute].
  final String? route;

  /// When to fire; null = show immediately. A future value schedules the
  /// notification (the reminder seam, §33) via `zonedSchedule`.
  final DateTime? scheduledAt;

  /// App-icon badge number to set alongside this notification (iOS badge /
  /// Android number). Null leaves the badge untouched.
  final int? badgeCount;
}

abstract interface class LocalNotificationService {
  /// Create channels + wire the tap handler. Safe to call more than once.
  Future<void> initialize();

  /// Request OS notification permission (contextually — never on first launch,
  /// docs/40 §33). Returns whether permission is granted.
  Future<bool> requestPermission();

  /// Present [notification] now, or schedule it when [LocalNotification.scheduledAt]
  /// is set. Scheduling respects the reminder seam and is preference-gated by the
  /// caller (the backend has no reminder preference yet, so nothing schedules
  /// reminders in Phase 1 — docs/40 §33).
  Future<void> show(LocalNotification notification);

  Future<void> cancel(int id);
  Future<void> cancelAll();

  /// Routes emitted when the user taps a presented/scheduled notification. The app
  /// coordinator listens and navigates through the guarded router (§12.4).
  Stream<String> get onSelectRoute;
}

/// Inert implementation — bound in tests and when on-device notifications are
/// unavailable. No plugin dependency, no channels, no stream events.
class NoopLocalNotificationService implements LocalNotificationService {
  const NoopLocalNotificationService();

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> show(LocalNotification notification) async {}

  @override
  Future<void> cancel(int id) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Stream<String> get onSelectRoute => const Stream<String>.empty();
}
