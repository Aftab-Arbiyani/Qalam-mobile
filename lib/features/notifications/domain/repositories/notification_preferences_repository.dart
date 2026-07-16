/// The notification-preferences repository (docs/40 §16, §32) — reads and
/// partially updates the seven per-category toggles. A whole-object cache-then-
/// network read (Identity tier) so the settings screen paints instantly; the
/// update is a partial PATCH returning the full, authoritative set.
library;

import '../../../../core/utils/result.dart';
import '../entities/notification_preferences.dart';

abstract interface class NotificationPreferencesRepository {
  /// The current preference set (cache-then-network).
  Future<Result<NotificationPreferences>> get();

  /// Persist a single category change, returning the server's full updated set.
  /// [category]/[value] become the partial PATCH body (only the changed key is
  /// sent), so a concurrent server-side change to other keys is not clobbered.
  Future<Result<NotificationPreferences>> update(
    NotificationPreferenceCategory category,
    bool value,
  );
}
