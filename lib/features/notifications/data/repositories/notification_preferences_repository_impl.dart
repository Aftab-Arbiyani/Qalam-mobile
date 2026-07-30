/// Notification-preferences repository implementation (docs/40 §16, §23). The
/// read is whole-object cache-then-network (Identity tier) so the settings screen
/// paints instantly and tolerates a brief offline blip; the update is a partial
/// PATCH through the single [guardResult] boundary, and on success the fresh set
/// is written back to the cache so a re-open reflects it immediately.
library;

import '../../../../core/error/result_guard.dart';
import '../../../../core/storage/cache_policy.dart';
import '../../../../core/storage/cache_store.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/data/cached_page_loader.dart';
import '../../domain/entities/notification_preferences.dart';
import '../../domain/repositories/notification_preferences_repository.dart';
import '../datasources/notification_remote_data_source.dart';

class NotificationPreferencesRepositoryImpl
    implements NotificationPreferencesRepository {
  NotificationPreferencesRepositoryImpl(this._remote, this._cache);

  final NotificationRemoteDataSource _remote;
  final CacheStore _cache;

  static const String _cacheKey = 'notifications:preferences';

  @override
  Future<Result<NotificationPreferences>> get() =>
      loadCachedObject<NotificationPreferences>(
        cache: _cache,
        cacheKey: _cacheKey,
        fetch: _remote.getPreferences,
        toJson: (NotificationPreferences p) => p.toJson(),
        fromJson: NotificationPreferences.fromJson,
        tier: CacheTier.identity,
      );

  @override
  Future<Result<NotificationPreferences>> update(
    NotificationPreferenceCategory category,
    bool value,
  ) async {
    final Result<NotificationPreferences> result =
        await guardResult<NotificationPreferences>(
          () => _remote.updatePreference(category, value),
        );
    if (result.isOk) {
      try {
        await _cache.write(
          _cacheKey,
          result.valueOrNull!.toJson(),
          tier: CacheTier.identity,
        );
      } on Object {
        // Best-effort cache refresh — the authoritative value is already returned.
      }
    }
    return result;
  }
}
