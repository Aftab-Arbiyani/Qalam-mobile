/// Local (on-device) notifications — architecture placeholder (docs/40 §33).
///
/// Foreground presentation of pushes and opt-in scheduled reminders. The
/// `flutter_local_notifications` package is intentionally deferred to the
/// notifications epic (it needs platform channel/permission setup); the concrete
/// implementation drops in behind this interface with no refactor. M1 is inert.
library;

/// A local notification to present or schedule.
class LocalNotification {
  const LocalNotification({
    required this.id,
    required this.title,
    required this.body,
    this.route,
    this.scheduledAt,
  });

  final int id;
  final String title;
  final String body;

  /// Deep-link route to open on tap (docs/40 §12.4).
  final String? route;

  /// When to fire; null = show immediately.
  final DateTime? scheduledAt;
}

abstract interface class LocalNotificationService {
  Future<void> initialize();
  Future<bool> requestPermission();
  Future<void> show(LocalNotification notification);
  Future<void> cancel(int id);
  Future<void> cancelAll();
}

/// M1 implementation: inert. Swapped for the concrete implementation in the
/// notifications epic.
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
}
