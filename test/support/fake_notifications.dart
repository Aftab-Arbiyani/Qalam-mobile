/// Test doubles + factories for the notifications feature (docs/40 §38).
/// In-memory fakes with a `failNext` hook (mirrors `fake_social.dart`) so
/// controller/repository tests drive success, offline, and error paths without a
/// server. A [notif] factory builds `AppNotification`s with sensible defaults.
library;

import 'package:qalam_mobile/core/error/failure.dart';
import 'package:qalam_mobile/core/utils/result.dart';
import 'package:qalam_mobile/core/utils/typedefs.dart';
import 'package:qalam_mobile/features/notifications/domain/entities/app_notification.dart';
import 'package:qalam_mobile/features/notifications/domain/entities/notification_preferences.dart';
import 'package:qalam_mobile/features/notifications/domain/entities/unread_count.dart';
import 'package:qalam_mobile/features/notifications/domain/repositories/notification_preferences_repository.dart';
import 'package:qalam_mobile/features/notifications/domain/repositories/notification_repository.dart';
import 'package:qalam_mobile/features/notifications/domain/value_objects/notification_filter.dart';
import 'package:qalam_mobile/shared/api/api_envelope.dart';
import 'package:qalam_mobile/shared/domain/entities/author.dart';
import 'package:qalam_mobile/shared/domain/enums.dart';
import 'package:qalam_mobile/shared/pagination/cached_page.dart';

/// Build a notification with defaults; override any field.
AppNotification notif({
  String id = 'n1',
  NotificationType type = NotificationType.unknown,
  NotificationStatus status = NotificationStatus.unread,
  NotificationEntityType entityType = NotificationEntityType.user,
  String? entityId,
  NotificationPayload payload = const NotificationPayload(),
  String? actorUsername = 'ali',
  DateTime? createdAt,
}) => AppNotification(
  id: id,
  type: type,
  status: status,
  entityType: entityType,
  entityId: entityId,
  payload: payload,
  actor: actorUsername == null
      ? null
      : Author(username: actorUsername, penName: 'Ali'),
  createdAt: createdAt ?? DateTime.utc(2026, 7, 16, 12),
);

/// An in-memory [NotificationRepository]. Seed [items]; flip [failNext] to make
/// the next mutation fail with [failure] (default a transient network failure).
class FakeNotificationRepository implements NotificationRepository {
  FakeNotificationRepository({
    List<AppNotification>? items,
    UnreadCount? unread,
  }) : items = <AppNotification>[...?items],
       _unread = unread ?? UnreadCount.zero;

  final List<AppNotification> items;
  UnreadCount _unread;

  bool failNext = false;
  Failure failure = const Failure.network(
    code: 'API_NETWORK_ERROR',
    isOffline: true,
  );

  int markReadCalls = 0;
  int markAllReadCalls = 0;
  int archiveCalls = 0;
  int deleteCalls = 0;

  @override
  Future<Result<CachedPage<AppNotification>>> list(
    NotificationFilter filter, {
    String? cursor,
  }) async {
    final List<AppNotification> matched = items
        .where((AppNotification n) => filter.matches(n.status))
        .toList();
    return Ok<CachedPage<AppNotification>>(
      CachedPage<AppNotification>(
        page: CursorPage<AppNotification>(
          items: matched,
          meta: const CursorMeta(),
        ),
      ),
    );
  }

  @override
  Future<Result<UnreadCount>> unreadCount() async => Ok<UnreadCount>(_unread);

  void setUnread(UnreadCount value) => _unread = value;

  @override
  Future<Result<Unit>> markRead(String id) async {
    markReadCalls++;
    return _guard();
  }

  @override
  Future<Result<Unit>> markAllRead() async {
    markAllReadCalls++;
    return _guard();
  }

  @override
  Future<Result<Unit>> archive(String id) async {
    archiveCalls++;
    return _guard();
  }

  @override
  Future<Result<Unit>> delete(String id) async {
    deleteCalls++;
    return _guard();
  }

  Result<Unit> _guard() {
    if (failNext) {
      failNext = false;
      return Err<Unit>(failure);
    }
    return const Ok<Unit>(unit);
  }
}

/// An in-memory [NotificationPreferencesRepository].
class FakeNotificationPreferencesRepository
    implements NotificationPreferencesRepository {
  FakeNotificationPreferencesRepository({NotificationPreferences? initial})
    : _prefs = initial ?? const NotificationPreferences();

  NotificationPreferences _prefs;
  bool failNext = false;
  Failure failure = const Failure.network(code: 'API_NETWORK_ERROR');

  @override
  Future<Result<NotificationPreferences>> get() async =>
      Ok<NotificationPreferences>(_prefs);

  @override
  Future<Result<NotificationPreferences>> update(
    NotificationPreferenceCategory category,
    bool value,
  ) async {
    if (failNext) {
      failNext = false;
      return Err<NotificationPreferences>(failure);
    }
    _prefs = category.apply(_prefs, value);
    return Ok<NotificationPreferences>(_prefs);
  }
}
