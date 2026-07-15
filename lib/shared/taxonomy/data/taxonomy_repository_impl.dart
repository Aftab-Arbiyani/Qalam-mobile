/// Shared taxonomy repository (docs/40 §16, §23, §25) — cache-then-network for the
/// language + genre option lists, with offline fallback to the last-cached copy.
/// Cached at the Taxonomy freshness tier (docs/40 §8.3). Translates transport
/// errors to domain [Failure]s; no DTO/`DioException`/HTTP status escapes.
library;

import '../../../core/error/api_exception.dart';
import '../../../core/error/error_mapper.dart';
import '../../../core/error/failure.dart';
import '../../../core/storage/cache_policy.dart';
import '../../../core/storage/cache_store.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/typedefs.dart';
import '../../domain/entities/taxonomy.dart';
import '../../domain/error_codes.dart';
import '../domain/taxonomy_repository.dart';
import 'taxonomy_remote_data_source.dart';

class TaxonomyRepositoryImpl implements TaxonomyRepository {
  TaxonomyRepositoryImpl(this._remote, this._cache);

  final TaxonomyRemoteDataSource _remote;
  final CacheStore _cache;

  static const String _languagesKey = 'taxonomy:languages';
  static const String _genresKey = 'taxonomy:genres';

  @override
  Future<Result<List<LanguageRef>>> languages() => _load<LanguageRef>(
    key: _languagesKey,
    fetch: _remote.languages,
    toJson: (LanguageRef l) => l.toJson(),
    fromJson: LanguageRef.fromJson,
  );

  @override
  Future<Result<List<GenreRef>>> genres() => _load<GenreRef>(
    key: _genresKey,
    fetch: _remote.genres,
    toJson: (GenreRef g) => g.toJson(),
    fromJson: GenreRef.fromJson,
  );

  Future<Result<List<T>>> _load<T>({
    required String key,
    required Future<List<T>> Function() fetch,
    required Json Function(T) toJson,
    required T Function(Json) fromJson,
  }) async {
    try {
      final List<T> items = await fetch();
      await _cache.write(key, <String, Object?>{
        'items': <Json>[for (final T item in items) toJson(item)],
      }, tier: CacheTier.taxonomy);
      return Ok<List<T>>(items);
    } on ApiException catch (e) {
      final List<T>? cached = await _readCache<T>(key, fromJson);
      if (cached != null && e.isTransport) return Ok<List<T>>(cached);
      return Err<List<T>>(mapApiExceptionToFailure(e));
    } on Object catch (e) {
      return Err<List<T>>(
        Failure.unexpected(
          code: ErrorCodes.apiUnexpected,
          message: e.toString(),
        ),
      );
    }
  }

  Future<List<T>?> _readCache<T>(String key, T Function(Json) fromJson) async {
    final CacheEntry? entry = await _cache.read(key);
    if (entry == null) return null;
    final Object? items = entry.value['items'];
    if (items is! List) return null;
    return items
        .whereType<Map<dynamic, dynamic>>()
        .map((Map<dynamic, dynamic> m) => fromJson(Json.from(m)))
        .toList(growable: false);
  }
}
