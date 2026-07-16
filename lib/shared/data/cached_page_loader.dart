/// The shared cache-then-network engine (docs/40 §16, §23) — one implementation
/// of "fetch a cursor page; on page one write the cache and, on a network
/// failure, fall back to the cached page marked stale; later pages are
/// network-only." Every repository (feed, discovery, search) delegates here so
/// there is zero duplicated pagination/caching logic (docs/40 §44). Transport
/// errors become domain [Failure]s; no DTO/`DioException`/HTTP status escapes.
library;

import '../../core/error/api_exception.dart';
import '../../core/error/error_mapper.dart';
import '../../core/error/failure.dart';
import '../../core/storage/cache_policy.dart';
import '../../core/storage/cache_store.dart';
import '../../core/utils/result.dart';
import '../../core/utils/typedefs.dart';
import '../api/api_envelope.dart';
import '../domain/error_codes.dart';
import '../pagination/cached_page.dart';
import 'cache_list_data_source.dart';

/// Load one cursor page cache-then-network. [cacheKey] is `null` for surfaces
/// that must never be cached (e.g. pending follow requests) — then no read/write
/// and no stale fallback happen, and a page-one failure surfaces directly.
Future<Result<CachedPage<T>>> loadCachedPage<T>({
  required CacheListDataSource cache,
  required String? cacheKey,
  required String? cursor,
  required Future<CursorPage<T>> Function(String? cursor) fetch,
  required Json Function(T) toJson,
  required T Function(Json) fromJson,
  required CacheTier tier,
}) async {
  final bool firstPage = cursor == null;
  final bool cacheable = cacheKey != null;
  try {
    final CursorPage<T> page = await fetch(cursor);
    if (firstPage && cacheable) {
      await cache.writeList<T>(cacheKey, page.items, toJson, tier: tier);
    }
    return Ok<CachedPage<T>>(CachedPage<T>(page: page));
  } on ApiException catch (e) {
    if (firstPage && cacheable) {
      final CachedList<T>? cached = await cache.readList<T>(cacheKey, fromJson);
      if (cached != null) {
        return Ok<CachedPage<T>>(
          CachedPage<T>(
            page: CursorPage<T>(items: cached.items, meta: const CursorMeta()),
            isStale: true,
          ),
        );
      }
    }
    return Err<CachedPage<T>>(mapApiExceptionToFailure(e));
  } on Object catch (e) {
    return Err<CachedPage<T>>(
      Failure.unexpected(code: ErrorCodes.apiUnexpected, message: e.toString()),
    );
  }
}

/// Load a whole decoded object cache-then-network (the non-paginated sibling of
/// [loadCachedPage]): fetch, write the cache on success and, on an API failure,
/// fall back to the unexpired cached copy. An expired or undecodable cached
/// entry is evicted and ignored — a broken cache never masks the real failure.
Future<Result<T>> loadCachedObject<T>({
  required CacheStore cache,
  required String cacheKey,
  required Future<T> Function() fetch,
  required Json Function(T) toJson,
  required T Function(Json) fromJson,
  required CacheTier tier,
}) async {
  try {
    final T value = await fetch();
    await cache.write(cacheKey, toJson(value), tier: tier);
    return Ok<T>(value);
  } on ApiException catch (e) {
    try {
      final CacheEntry? entry = await cache.read(cacheKey);
      if (entry != null) {
        if (entry.isExpired(DateTime.now())) {
          await cache.evict(cacheKey);
        } else {
          return Ok<T>(fromJson(entry.value));
        }
      }
    } on Object {
      await cache.evict(cacheKey);
    }
    return Err<T>(mapApiExceptionToFailure(e));
  } on Object catch (e) {
    return Err<T>(
      Failure.unexpected(code: ErrorCodes.apiUnexpected, message: e.toString()),
    );
  }
}
