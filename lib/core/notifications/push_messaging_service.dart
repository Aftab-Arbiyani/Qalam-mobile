/// Push messaging — architecture placeholder (docs/40 §32).
///
/// Phase 1 notifications are in-app polling only; FCM push is a Phase-2 seam. The
/// `firebase_messaging` / `firebase_core` packages are intentionally NOT added in
/// M1 (they require `firebase_options.dart` from `flutterfire configure` and
/// platform config that would make the app un-runnable). The concrete FCM
/// implementation drops in behind this interface in the push epic — register on
/// login, refresh on rotation, unregister on logout, map payload → route — with
/// no refactor. Gated by `AppConfig.enablePush` (off by default).
library;

/// A received push payload, normalized to a route + identifiers (docs/40 §12.4).
class PushMessage {
  const PushMessage({
    required this.route,
    this.data = const <String, String>{},
  });

  final String route;
  final Map<String, String> data;
}

abstract interface class PushMessagingService {
  /// Request notification permission and register the device token with the
  /// backend (via an additive endpoint, Phase 2).
  Future<void> register();

  /// Remove the device token registration (logout).
  Future<void> unregister();

  /// Messages that arrived while the app was foregrounded.
  Stream<PushMessage> get onMessage;

  /// The route to open from a notification tap that launched/resumed the app.
  Future<PushMessage?> initialMessage();
}

/// M1 implementation: inert. No Firebase dependency, no registration, no stream
/// events. Swapped for the FCM implementation in the push epic.
class NoopPushMessagingService implements PushMessagingService {
  const NoopPushMessagingService();

  @override
  Future<void> register() async {}

  @override
  Future<void> unregister() async {}

  @override
  Stream<PushMessage> get onMessage => const Stream<PushMessage>.empty();

  @override
  Future<PushMessage?> initialMessage() async => null;
}
