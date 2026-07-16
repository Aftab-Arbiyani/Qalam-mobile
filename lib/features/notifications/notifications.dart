/// Public surface of the notifications feature (M8, docs/40 §32). Only the
/// route-mounted screens are exported — the router imports THIS, never a deep
/// presentation path (features are consumed through their barrel, docs/40 §7.3).
/// The unread-count provider (for the shell nav badge) is exported too, since the
/// persistent shell watches it cross-feature.
library;

export 'presentation/controllers/unread_count_controller.dart'
    show unreadCountControllerProvider;
export 'presentation/screens/notification_preferences_screen.dart';
export 'presentation/screens/notifications_screen.dart';
