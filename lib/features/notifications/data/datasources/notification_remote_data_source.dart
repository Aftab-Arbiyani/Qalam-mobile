/// Notifications remote data source (docs/40 §17.1) — the only place the
/// notifications feature touches the wire. Reads are a cursor page (inbox), a
/// single object (unread count), and the preferences object; mutations are the
/// PATCH→204 read/read-all/archive actions, the DELETE→204 soft-delete, and the
/// partial-PATCH preferences update. Throws [ApiException] for the repository to
/// translate; knows nothing of caching or `Failure`.
library;

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_paths.dart';
import '../../../../shared/api/api_envelope.dart';
import '../../../../shared/domain/enums.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/entities/notification_preferences.dart';
import '../../domain/entities/unread_count.dart';
import '../mappers/notification_mappers.dart';

class NotificationRemoteDataSource {
  NotificationRemoteDataSource(this._api);

  final ApiClient _api;

  static const int _limit = 20;

  Future<CursorPage<AppNotification>> list(
    NotificationStatus? status, {
    String? cursor,
  }) => _api.getPage<AppNotification>(
    ApiPaths.notifications,
    query: <String, dynamic>{
      'status': ?status?.wire,
      'cursor': ?cursor,
      'limit': _limit,
    },
    decodeItem: notificationFromJson,
  );

  Future<UnreadCount> unreadCount() => _api.get<UnreadCount>(
    ApiPaths.notificationsUnreadCount,
    decode: unreadCountFromJson,
    // The badge polls this; a coalesced duplicate is fine, but freshness matters,
    // so leave deduplication on (identical concurrent polls share one request).
  );

  Future<void> markRead(String id) =>
      _api.patchVoid(ApiPaths.notificationRead(id));

  Future<void> markAllRead() => _api.patchVoid(ApiPaths.notificationsReadAll);

  Future<void> archive(String id) =>
      _api.patchVoid(ApiPaths.notificationArchive(id));

  Future<void> delete(String id) => _api.delete(ApiPaths.notification(id));

  Future<NotificationPreferences> getPreferences() =>
      _api.get<NotificationPreferences>(
        ApiPaths.notificationPreferences,
        decode: notificationPreferencesFromJson,
      );

  /// Partial update — only the changed category key is sent so a concurrent
  /// server-side change to other keys is not clobbered. Returns the full set.
  Future<NotificationPreferences> updatePreference(
    NotificationPreferenceCategory category,
    bool value,
  ) => _api.patch<NotificationPreferences>(
    ApiPaths.notificationPreferences,
    body: <String, dynamic>{category.wire: value},
    decode: notificationPreferencesFromJson,
  );
}
