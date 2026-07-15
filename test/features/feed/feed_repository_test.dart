import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/error/api_exception.dart';
import 'package:qalam_mobile/core/error/failure.dart';
import 'package:qalam_mobile/core/storage/cache_policy.dart';
import 'package:qalam_mobile/core/storage/cache_store.dart';
import 'package:qalam_mobile/core/utils/typedefs.dart';
import 'package:qalam_mobile/features/feed/data/datasources/feed_local_data_source.dart';
import 'package:qalam_mobile/features/feed/data/datasources/feed_remote_data_source.dart';
import 'package:qalam_mobile/features/feed/data/repositories/feed_repository_impl.dart';
import 'package:qalam_mobile/features/feed/domain/entities/piece_summary.dart';
import 'package:qalam_mobile/features/feed/domain/value_objects/feed_query.dart';
import 'package:qalam_mobile/shared/api/api_envelope.dart';
import 'package:qalam_mobile/shared/domain/entities/author.dart';
import 'package:qalam_mobile/shared/domain/entities/taxonomy.dart';
import 'package:qalam_mobile/shared/pagination/cached_page.dart';

class _MemCache implements CacheStore {
  final Map<String, CacheEntry> _m = <String, CacheEntry>{};

  @override
  Future<CacheEntry?> read(String key) async => _m[key];

  @override
  Future<void> write(String key, Json value, {required CacheTier tier}) async {
    _m[key] = CacheEntry(
      value: value,
      writtenAt: DateTime.now().toUtc(),
      tier: tier,
    );
  }

  @override
  Future<void> evict(String key) async => _m.remove(key);

  @override
  Future<void> clear() async => _m.clear();
}

/// A [FeedRemoteDataSource] whose piece-feed response is driven by [responder].
class _StubRemote implements FeedRemoteDataSource {
  _StubRemote(this.responder);

  Future<CursorPage<PieceSummary>> Function(String? cursor) responder;

  @override
  Future<CursorPage<PieceSummary>> pieceFeed(
    FeedTab tab, {
    FeedQuery query = FeedQuery.none,
    String? cursor,
  }) => responder(cursor);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

PieceSummary _summary(String id) => PieceSummary(
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

void main() {
  group('FeedRepositoryImpl cache-then-network', () {
    test('online success returns fresh data and populates the cache', () async {
      final _MemCache cache = _MemCache();
      final _StubRemote remote = _StubRemote(
        (String? _) async => CursorPage<PieceSummary>(
          items: <PieceSummary>[_summary('a')],
          meta: const CursorMeta(),
        ),
      );
      final FeedRepositoryImpl repo = FeedRepositoryImpl(
        remote,
        FeedLocalDataSource(cache),
      );

      final r = await repo.pieceFeed(FeedTab.latest);
      expect(r.isOk, isTrue);
      expect(r.valueOrNull!.isStale, isFalse);
      expect(r.valueOrNull!.page.items.single.id, 'a');
    });

    test('offline falls back to the cached first page marked stale', () async {
      final _MemCache cache = _MemCache();
      final _StubRemote remote = _StubRemote(
        (String? _) async => CursorPage<PieceSummary>(
          items: <PieceSummary>[_summary('a')],
          meta: const CursorMeta(),
        ),
      );
      final FeedRepositoryImpl repo = FeedRepositoryImpl(
        remote,
        FeedLocalDataSource(cache),
      );

      await repo.pieceFeed(FeedTab.latest); // warm the cache
      remote.responder = (String? _) async => throw _offline;

      final r = await repo.pieceFeed(FeedTab.latest);
      expect(r.isOk, isTrue);
      final CachedPage<PieceSummary> page = r.valueOrNull!;
      expect(page.isStale, isTrue);
      expect(page.page.items.single.id, 'a');
    });

    test('offline with no cache surfaces a NetworkFailure', () async {
      final FeedRepositoryImpl repo = FeedRepositoryImpl(
        _StubRemote((String? _) async => throw _offline),
        FeedLocalDataSource(_MemCache()),
      );
      final r = await repo.pieceFeed(FeedTab.latest);
      expect(r.isErr, isTrue);
      expect(r.failureOrNull, isA<NetworkFailure>());
    });

    test('a later-page failure does not fall back to cache', () async {
      final FeedRepositoryImpl repo = FeedRepositoryImpl(
        _StubRemote((String? _) async => throw _offline),
        FeedLocalDataSource(_MemCache()),
      );
      final r = await repo.pieceFeed(FeedTab.latest, cursor: 'c2');
      expect(r.isErr, isTrue);
    });
  });
}
