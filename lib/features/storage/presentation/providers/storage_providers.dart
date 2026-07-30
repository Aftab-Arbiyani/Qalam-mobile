/// The storage/cache module composition root (docs/40 §25, §37). Provides the
/// [CacheManager], the reactive [CacheStats] the storage screen renders, and an
/// app-start maintenance hook that evicts hard-expired cache entries once (watched
/// from the app root). DI is Riverpod only.
library;

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/storage/cache_manager.dart';

part 'storage_providers.g.dart';

@Riverpod(keepAlive: true)
CacheManager cacheManager(Ref ref) => CacheManager(
  cacheBox: ref.watch(cacheBoxProvider),
  prefsBox: ref.watch(prefsBoxProvider),
  readingBox: ref.watch(readingBoxProvider),
  draftsBox: ref.watch(draftsBoxProvider),
);

/// The live cache statistics for the storage screen. Recomputed on demand after a
/// cleanup / clear.
@riverpod
class CacheStatsController extends _$CacheStatsController {
  @override
  CacheStats build() => ref.watch(cacheManagerProvider).stats();

  /// Re-measure.
  void refresh() => state = ref.read(cacheManagerProvider).stats();

  /// Evict hard-expired entries; returns how many were removed.
  Future<int> cleanupExpired() async {
    final int removed = await ref
        .read(cacheManagerProvider)
        .cleanupExpired();
    refresh();
    return removed;
  }

  /// Clear the disposable cache entirely (manual refresh).
  Future<void> clearCache() async {
    await ref.read(cacheManagerProvider).clearCache();
    refresh();
  }
}

/// App-start maintenance — evict hard-expired cache entries once, off the critical
/// path. Kept alive + watched from the app root (docs/40 §37 automatic cleanup).
@Riverpod(keepAlive: true)
Object cacheMaintenance(Ref ref) {
  unawaited(ref.watch(cacheManagerProvider).cleanupExpired());
  return const Object();
}
