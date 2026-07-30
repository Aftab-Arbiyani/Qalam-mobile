/// Notification inbox repository implementation (docs/40 §16, §23, §25.3). The
/// inbox and unread count are cache-then-network via the shared [loadCachedPage]
/// / [loadCachedObject] engines (offline reads paint from Hive, marked stale);
/// mutations go through the single [guardUnit] boundary and, on success, evict the
/// list + unread-count cache so the next read is authoritative (docs/40 §25.3:
/// "notification read/read-all invalidates notifications:list:* + unreadCount").
/// All transport errors become domain [Failure]s — no DTO/`DioException` escapes.
library;

import '../../../../core/error/result_guard.dart';
import '../../../../core/storage/cache_policy.dart';
import '../../../../core/storage/cache_store.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../../shared/data/cache_list_data_source.dart';
import '../../../../shared/data/cached_page_loader.dart';
import '../../../../shared/pagination/cached_page.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/entities/unread_count.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/value_objects/notification_filter.dart';
import '../datasources/notification_remote_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._remote, this._pageCache, this._objectCache);

  final NotificationRemoteDataSource _remote;
  final CacheListDataSource _pageCache;
  final CacheStore _objectCache;

  static String _listKey(NotificationFilter filter) =>
      'notifications:list:${filter.cacheSuffix}';
  static const String _unreadCountKey = 'notifications:unreadCount';

  @override
  Future<Result<CachedPage<AppNotification>>> list(
    NotificationFilter filter, {
    String? cursor,
  }) => loadCachedPage<AppNotification>(
    cache: _pageCache,
    cacheKey: _listKey(filter),
    cursor: cursor,
    fetch: (String? c) => _remote.list(filter.status, cursor: c),
    toJson: (AppNotification n) => n.toJson(),
    fromJson: AppNotification.fromJson,
    tier: CacheTier.live,
  );

  @override
  Future<Result<UnreadCount>> unreadCount() => loadCachedObject<UnreadCount>(
    cache: _objectCache,
    cacheKey: _unreadCountKey,
    fetch: _remote.unreadCount,
    toJson: (UnreadCount c) => c.toJson(),
    fromJson: UnreadCount.fromJson,
    tier: CacheTier.live,
  );

  @override
  Future<Result<Unit>> markRead(String id) =>
      _mutate(() => _remote.markRead(id));

  @override
  Future<Result<Unit>> markAllRead() => _mutate(_remote.markAllRead);

  @override
  Future<Result<Unit>> archive(String id) => _mutate(() => _remote.archive(id));

  @override
  Future<Result<Unit>> delete(String id) => _mutate(() => _remote.delete(id));

  /// Run a mutation and, on success, invalidate the inbox + unread-count caches
  /// so the next read/poll is fresh. Cache eviction never fails the mutation.
  Future<Result<Unit>> _mutate(Future<void> Function() op) async {
    final Result<Unit> result = await guardUnit(op);
    if (result.isOk) await _invalidate();
    return result;
  }

  Future<void> _invalidate() async {
    try {
      await _objectCache.evict(_unreadCountKey);
      for (final NotificationFilter filter in NotificationFilter.values) {
        await _objectCache.evict(_listKey(filter));
      }
    } on Object {
      // Best-effort — a stale cache is corrected on the next network read.
    }
  }
}
