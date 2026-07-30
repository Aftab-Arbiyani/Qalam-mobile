import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/error/api_exception.dart';
import 'package:qalam_mobile/core/error/failure.dart';
import 'package:qalam_mobile/core/storage/cache_policy.dart';
import 'package:qalam_mobile/core/storage/cache_store.dart';
import 'package:qalam_mobile/core/utils/typedefs.dart';
import 'package:qalam_mobile/features/search/data/datasources/search_remote_data_source.dart';
import 'package:qalam_mobile/features/search/data/repositories/search_repository_impl.dart';
import 'package:qalam_mobile/features/search/domain/entities/global_search_result.dart';
import 'package:qalam_mobile/features/search/domain/value_objects/search_filters.dart';
import 'package:qalam_mobile/shared/api/api_envelope.dart';
import 'package:qalam_mobile/shared/data/cache_list_data_source.dart';
import 'package:qalam_mobile/shared/domain/entities/author.dart';
import 'package:qalam_mobile/shared/domain/entities/piece_summary.dart';
import 'package:qalam_mobile/shared/domain/entities/taxonomy.dart';

class _MemCache implements CacheStore {
  final Map<String, CacheEntry> _m = <String, CacheEntry>{};

  @override
  Future<CacheEntry?> read(String key) async => _m[key];

  @override
  Future<void> write(String key, Json value, {required CacheTier tier}) async {
    _m[key] = CacheEntry(value: value, writtenAt: DateTime.now().toUtc(), tier: tier);
  }

  @override
  Future<void> evict(String key) async => _m.remove(key);

  @override
  Future<void> clear() async => _m.clear();
}

/// A [SearchRemoteDataSource] whose piece + grouped responses are driven by
/// responders; everything else throws via [noSuchMethod] (unused in these tests).
class _StubRemote implements SearchRemoteDataSource {
  _StubRemote({required this.pieceResponder, required this.globalResponder});

  Future<CursorPage<PieceSummary>> Function(String? cursor) pieceResponder;
  Future<GlobalSearchResult> Function() globalResponder;

  @override
  Future<CursorPage<PieceSummary>> searchPieces(
    String query,
    Json filterParams, {
    String? cursor,
  }) => pieceResponder(cursor);

  @override
  Future<GlobalSearchResult> globalSearch(String query, {int limit = 5}) =>
      globalResponder();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

PieceSummary _piece(String id) => PieceSummary(
  id: id,
  title: 'Title $id',
  author: const Author(username: 'a'),
  language: const LanguageRef(code: 'en'),
);

const ApiException _offline = ApiException(
  code: 'API_OFFLINE',
  status: 0,
  message: 'offline',
);

SearchRepositoryImpl _repo(_MemCache cache, _StubRemote remote) =>
    SearchRepositoryImpl(remote, CacheListDataSource(cache), cache);

void main() {
  group('searchPieces cache-then-network', () {
    test('online success returns fresh page and warms the cache', () async {
      final _MemCache cache = _MemCache();
      final repo = _repo(
        cache,
        _StubRemote(
          pieceResponder: (_) async => CursorPage<PieceSummary>(
            items: <PieceSummary>[_piece('a')],
            meta: const CursorMeta(),
          ),
          globalResponder: () async => const GlobalSearchResult(),
        ),
      );
      final r = await repo.searchPieces('barish', SearchFilters.none);
      expect(r.isOk, isTrue);
      expect(r.valueOrNull!.isStale, isFalse);
      expect(r.valueOrNull!.page.items.single.id, 'a');
    });

    test('offline after a warm cache falls back to a stale page', () async {
      final _MemCache cache = _MemCache();
      final remote = _StubRemote(
        pieceResponder: (_) async => CursorPage<PieceSummary>(
          items: <PieceSummary>[_piece('a')],
          meta: const CursorMeta(),
        ),
        globalResponder: () async => const GlobalSearchResult(),
      );
      final repo = _repo(cache, remote);
      await repo.searchPieces('barish', SearchFilters.none); // warm
      remote.pieceResponder = (_) async => throw _offline;

      final r = await repo.searchPieces('barish', SearchFilters.none);
      expect(r.isOk, isTrue);
      expect(r.valueOrNull!.isStale, isTrue);
      expect(r.valueOrNull!.page.items.single.id, 'a');
    });

    test('offline with no cache surfaces a NetworkFailure', () async {
      final repo = _repo(
        _MemCache(),
        _StubRemote(
          pieceResponder: (_) async => throw _offline,
          globalResponder: () async => const GlobalSearchResult(),
        ),
      );
      final r = await repo.searchPieces('x', SearchFilters.none);
      expect(r.failureOrNull, isA<NetworkFailure>());
    });

    test('a later-page failure does not fall back to cache', () async {
      final repo = _repo(
        _MemCache(),
        _StubRemote(
          pieceResponder: (_) async => throw _offline,
          globalResponder: () async => const GlobalSearchResult(),
        ),
      );
      final r = await repo.searchPieces('x', SearchFilters.none, cursor: 'c2');
      expect(r.isErr, isTrue);
    });
  });

  group('globalSearch object cache', () {
    test('offline after a warm cache replays the last grouped preview', () async {
      final _MemCache cache = _MemCache();
      final remote = _StubRemote(
        pieceResponder: (_) async =>
            const CursorPage<PieceSummary>(items: <PieceSummary>[], meta: CursorMeta()),
        globalResponder: () async =>
            GlobalSearchResult(pieces: <PieceSummary>[_piece('g')]),
      );
      final repo = _repo(cache, remote);
      await repo.globalSearch('barish'); // warm
      remote.globalResponder = () async => throw _offline;

      final r = await repo.globalSearch('barish');
      expect(r.isOk, isTrue);
      expect(r.valueOrNull!.pieces.single.id, 'g');
    });
  });
}
