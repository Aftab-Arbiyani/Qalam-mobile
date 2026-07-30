/// The notification inbox repository (docs/40 §16, §32) — the single seam between
/// the notification presentation layer and the wire. Returns domain [Result]s
/// (never a DTO / `DioException` / HTTP status); the inbox is cache-then-network
/// (offline reads paint from Hive, marked stale). Reused by the notification
/// center, the unread badge, and the push coordinator — there is no second
/// notification repository (docs/40 §7.3, §44).
library;

import '../../../../core/utils/result.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../../shared/pagination/cached_page.dart';
import '../entities/app_notification.dart';
import '../entities/unread_count.dart';
import '../value_objects/notification_filter.dart';

abstract interface class NotificationRepository {
  /// One cursor page of the inbox, filtered by [filter]. Page one is cached
  /// per-filter and, on a network failure, falls back to the cached page marked
  /// stale.
  Future<Result<CachedPage<AppNotification>>> list(
    NotificationFilter filter, {
    String? cursor,
  });

  /// The unread count for the badge. Cache-then-network (Live tier) so the badge
  /// survives a brief offline blip.
  Future<Result<UnreadCount>> unreadCount();

  /// Mark one notification read (idempotent server-side).
  Future<Result<Unit>> markRead(String id);

  /// Mark every notification read.
  Future<Result<Unit>> markAllRead();

  /// Archive one notification.
  Future<Result<Unit>> archive(String id);

  /// Delete one notification (soft-delete server-side; undo-able in the UI).
  Future<Result<Unit>> delete(String id);
}
