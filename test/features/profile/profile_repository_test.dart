import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/error/api_exception.dart';
import 'package:qalam_mobile/core/error/failure.dart';
import 'package:qalam_mobile/core/storage/cache_policy.dart';
import 'package:qalam_mobile/core/storage/cache_store.dart';
import 'package:qalam_mobile/core/utils/result.dart';
import 'package:qalam_mobile/core/utils/typedefs.dart';
import 'package:qalam_mobile/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:qalam_mobile/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:qalam_mobile/features/profile/domain/entities/profile.dart';
import 'package:qalam_mobile/features/profile/domain/entities/profile_counts.dart';
import 'package:qalam_mobile/features/profile/domain/entities/profile_piece.dart';
import 'package:qalam_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:qalam_mobile/features/profile/domain/value_objects/profile_edit.dart';
import 'package:qalam_mobile/shared/api/api_envelope.dart';
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

/// A [ProfileRemoteDataSource] whose responses are driven by injected closures.
class _StubRemote implements ProfileRemoteDataSource {
  _StubRemote({this.onGetMe, this.onPieces, this.onDrafts});

  Future<Profile> Function()? onGetMe;
  Future<CursorPage<ProfilePiece>> Function()? onPieces;
  Future<CursorPage<Json>> Function()? onDrafts;

  @override
  Future<Profile> getMe() => onGetMe!();

  @override
  Future<CursorPage<ProfilePiece>> publishedPieces({String? cursor}) =>
      onPieces!();

  @override
  Future<CursorPage<Json>> draftsCountPage() => onDrafts!();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const ApiException _offline = ApiException(
  code: 'API_OFFLINE',
  status: 0,
  message: 'offline',
);

const ApiException _notFound = ApiException(
  code: 'USER_NOT_FOUND',
  status: 404,
  message: 'gone',
);

Profile _profile(String pen) => Profile(
  id: 'u1',
  username: 'meera_k',
  penName: pen,
  counts: const ProfileCounts(piecesPublished: 3),
);

void main() {
  group('ProfileRepositoryImpl.myProfile', () {
    test('caches on success and serves it stale when offline', () async {
      int calls = 0;
      final _StubRemote remote = _StubRemote(
        onGetMe: () async {
          calls++;
          if (calls == 1) return _profile('Meera');
          throw _offline;
        },
      );
      final ProfileRepositoryImpl repo = ProfileRepositoryImpl(
        remote,
        _MemCache(),
      );

      final Result<CachedProfile> first = await repo.myProfile();
      expect(first.valueOrNull?.profile.penName, 'Meera');
      expect(first.valueOrNull?.isStale, isFalse);

      final Result<CachedProfile> second = await repo.myProfile();
      expect(second.isOk, isTrue);
      expect(second.valueOrNull?.isStale, isTrue);
      expect(second.valueOrNull?.profile.penName, 'Meera');
    });

    test('never masks a real 404 with cache', () async {
      final _StubRemote remote = _StubRemote(
        onGetMe: () async => _profile('M'),
      );
      final _MemCache cache = _MemCache();
      final ProfileRepositoryImpl repo = ProfileRepositoryImpl(remote, cache);
      await repo.myProfile(); // seed cache

      remote.onGetMe = () async => throw _notFound;
      final Result<CachedProfile> result = await repo.myProfile();
      expect(result.isErr, isTrue);
      expect(result.failureOrNull, isA<NotFoundFailure>());
    });

    test('errors (no cache) map to a domain Failure', () async {
      final _StubRemote remote = _StubRemote(
        onGetMe: () async => throw _offline,
      );
      final Result<CachedProfile> result = await ProfileRepositoryImpl(
        remote,
        _MemCache(),
      ).myProfile();
      expect(result.failureOrNull, isA<NetworkFailure>());
    });
  });

  group('bounded counts', () {
    test('reports exact count when the page is not full', () async {
      final _StubRemote remote = _StubRemote(
        onDrafts: () async => const CursorPage<Json>(
          items: <Json>[<String, dynamic>{}, <String, dynamic>{}],
          meta: CursorMeta(),
        ),
      );
      final Result<BoundedCount> result = await ProfileRepositoryImpl(
        remote,
        _MemCache(),
      ).myDraftCount();
      expect(result.valueOrNull?.count, 2);
      expect(result.valueOrNull?.hasMore, isFalse);
    });

    test('flags hasMore when the first page is full', () async {
      final _StubRemote remote = _StubRemote(
        onDrafts: () async => CursorPage<Json>(
          items: List<Json>.generate(50, (_) => <String, dynamic>{}),
          meta: const CursorMeta(nextCursor: 'c', hasMore: true),
        ),
      );
      final Result<BoundedCount> result = await ProfileRepositoryImpl(
        remote,
        _MemCache(),
      ).myDraftCount();
      expect(result.valueOrNull?.count, 50);
      expect(result.valueOrNull?.hasMore, isTrue);
    });
  });

  group('myPublishedPieces', () {
    test('caches the first page and serves it stale when offline', () async {
      int calls = 0;
      final _StubRemote remote = _StubRemote(
        onPieces: () async {
          calls++;
          if (calls == 1) {
            return const CursorPage<ProfilePiece>(
              items: <ProfilePiece>[ProfilePiece(id: 'p1', title: 'A')],
              meta: CursorMeta(),
            );
          }
          throw _offline;
        },
      );
      final ProfileRepositoryImpl repo = ProfileRepositoryImpl(
        remote,
        _MemCache(),
      );

      final Result<CachedPage<ProfilePiece>> first = await repo
          .myPublishedPieces();
      expect(first.valueOrNull?.page.items.single.id, 'p1');

      final Result<CachedPage<ProfilePiece>> offline = await repo
          .myPublishedPieces();
      expect(offline.isOk, isTrue);
      expect(offline.valueOrNull?.isStale, isTrue);
    });
  });

  group('updateProfile', () {
    test('returns the fresh profile and refreshes the /me cache', () async {
      final _MemCache cache = _MemCache();
      final ProfileRepositoryImpl repo = ProfileRepositoryImpl(
        _UpdatingRemote(_profile('New')),
        cache,
      );

      final Result<Profile> result = await repo.updateProfile(
        const ProfileEdit(penName: 'New'),
      );
      expect(result.valueOrNull?.penName, 'New');

      // A subsequent offline read serves the freshly-cached profile.
      final CacheEntry? entry = await cache.read('profile:me');
      expect(entry?.value['penName'], 'New');
    });
  });
}

class _UpdatingRemote implements ProfileRemoteDataSource {
  _UpdatingRemote(this._result);
  final Profile _result;

  @override
  Future<Profile> updateMe(Json body) async => _result;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
