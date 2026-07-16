/// Push messaging seam (docs/40 §31, §32) — the Phase-2 FCM contract, placed now
/// so real push drops in behind this interface with zero refactor. Phase 1 is
/// in-app polling only (§32.1): `firebase_messaging`/`firebase_core` are
/// intentionally NOT dependencies (they need `firebase_options.dart` +
/// google-services config the app doesn't ship, and the backend has no
/// device-token endpoint — ADR §10, §32.2). The binding stays
/// [NoopPushMessagingService], gated off by `AppConfig.enablePush`.
///
/// When push lands, a concrete `FcmPushMessagingService` implements THIS: request
/// permission, read the FCM token + surface rotations on [onTokenRefresh],
/// [register] it against the (future) backend endpoint, stream foreground
/// [onMessage] and background-tap [onMessageOpenedApp], and replay the
/// terminated-launch [initialMessage]. The app-level `PushNotificationCoordinator`
/// bridges those to the notification repository + local presentation + router —
/// so Firebase only ever talks to `core/`, never a widget (docs/40 §31).
library;

/// A received push, normalized to the deep-link inputs the app router needs
/// (docs/40 §12.4). [data] is the raw FCM data payload (type, entity ids,
/// denormalized piece slug, …); [route] is a pre-resolved path when the sender
/// supplied one, else null and the coordinator derives it from [data].
class PushMessage {
  const PushMessage({this.data = const <String, String>{}, this.route});

  final Map<String, String> data;
  final String? route;
}

abstract interface class PushMessagingService {
  /// Request OS notification permission (contextually). Returns whether granted.
  Future<bool> requestPermission();

  /// The current device push token, or null if unavailable/not granted.
  Future<String?> currentToken();

  /// Token rotations — a new token must be re-[register]ed with the backend.
  Stream<String> get onTokenRefresh;

  /// Request permission and register the device token with the backend (via the
  /// additive device-registration endpoint, Phase 2). Call on login.
  Future<void> register();

  /// Remove the device-token registration (logout).
  Future<void> unregister();

  /// Messages that arrived while the app was foregrounded (present locally +
  /// refresh the inbox/badge).
  Stream<PushMessage> get onMessage;

  /// A background notification the user tapped to bring the app forward.
  Stream<PushMessage> get onMessageOpenedApp;

  /// The message whose tap cold-launched the app (terminated → running), or null.
  Future<PushMessage?> initialMessage();
}

/// Inert Phase-1 implementation: no Firebase dependency, no registration, no
/// stream events. Swapped for the FCM implementation when push ships behind
/// `AppConfig.enablePush`.
class NoopPushMessagingService implements PushMessagingService {
  const NoopPushMessagingService();

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<String?> currentToken() async => null;

  @override
  Stream<String> get onTokenRefresh => const Stream<String>.empty();

  @override
  Future<void> register() async {}

  @override
  Future<void> unregister() async {}

  @override
  Stream<PushMessage> get onMessage => const Stream<PushMessage>.empty();

  @override
  Stream<PushMessage> get onMessageOpenedApp =>
      const Stream<PushMessage>.empty();

  @override
  Future<PushMessage?> initialMessage() async => null;
}
