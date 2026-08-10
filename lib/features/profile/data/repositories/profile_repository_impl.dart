/// Profile repository (docs/40 §16, §23). Cache-then-network for reads (own +
/// public profile, published-pieces grid) with offline fallback to the cached copy
/// on transport errors — a real 404/403 is never masked. Writes (edit, uploads)
/// are a pure remote boundary that fail fast offline; there is no outbox. Every
/// transport error becomes a domain [Failure]; no DTO/`DioException`/status escapes.
library;

import '../../../../core/error/api_exception.dart';
import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/storage/cache_policy.dart';
import '../../../../core/storage/cache_store.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../../shared/api/api_envelope.dart';
import '../../../../shared/domain/error_codes.dart';
import '../../../../shared/pagination/cached_page.dart';
import '../../domain/entities/profile.dart';
import '../../domain/entities/profile_piece.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/value_objects/profile_edit.dart';
import '../datasources/profile_remote_data_source.dart';
import '../mappers/profile_mappers.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remote, this._cache);

  final ProfileRemoteDataSource _remote;
  final CacheStore _cache;

  static const String _meKey = 'profile:me';
  static const String _mePiecesKey = 'profile:me:pieces';
  static String _userKey(String username) => 'profile:u:$username';
  static String _userIdKey(String userId) => 'profile:id:$userId';

  @override
  Future<Result<CachedProfile>> myProfile() =>
      _readProfile(_meKey, _remote.getMe);

  @override
  Future<Result<CachedProfile>> publicProfile(String username) =>
      _readProfile(_userKey(username), () => _remote.getByUsername(username));

  @override
  Future<Result<CachedProfile>> publicProfileById(String userId) =>
      _readProfile(_userIdKey(userId), () => _remote.getById(userId));

  Future<Result<CachedProfile>> _readProfile(
    String key,
    Future<Profile> Function() fetch,
  ) async {
    try {
      final Profile profile = await fetch();
      await _cache.write(key, profile.toJson(), tier: CacheTier.identity);
      return Ok<CachedProfile>((profile: profile, isStale: false));
    } on ApiException catch (e) {
      final Profile? cached = await _readCachedProfile(key);
      if (cached != null && e.isTransport) {
        return Ok<CachedProfile>((profile: cached, isStale: true));
      }
      return Err<CachedProfile>(mapApiExceptionToFailure(e));
    } on Object catch (e) {
      return Err<CachedProfile>(
        Failure.unexpected(
          code: ErrorCodes.apiUnexpected,
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<Profile>> updateProfile(
    ProfileEdit edit,
  ) => _guard<Profile>(() async {
    final Profile profile = await _remote.updateMe(profilePatchBody(edit));
    // Keep the own-profile cache in step so the next `/me` read is instant/fresh.
    await _cache.write(_meKey, profile.toJson(), tier: CacheTier.identity);
    return profile;
  });

  @override
  Future<Result<String>> uploadAvatar({
    required String filePath,
    UploadProgress? onProgress,
    String? uploadKey,
  }) => _guard<String>(
    () => _remote.uploadAvatar(
      filePath: filePath,
      mimeType: _mimeFor(filePath),
      onProgress: onProgress,
      uploadKey: uploadKey,
    ),
  );

  @override
  Future<Result<String>> uploadCover({
    required String filePath,
    UploadProgress? onProgress,
    String? uploadKey,
  }) => _guard<String>(
    () => _remote.uploadCover(
      filePath: filePath,
      mimeType: _mimeFor(filePath),
      onProgress: onProgress,
      uploadKey: uploadKey,
    ),
  );

  @override
  void cancelUpload(String uploadKey) => _remote.cancel(uploadKey);

  @override
  Future<Result<CachedPage<ProfilePiece>>> myPublishedPieces({
    String? cursor,
  }) async {
    final bool firstPage = cursor == null;
    try {
      final CursorPage<ProfilePiece> page = await _remote.publishedPieces(
        cursor: cursor,
      );
      if (firstPage) await _writePageCache(_mePiecesKey, page);
      return Ok<CachedPage<ProfilePiece>>(CachedPage<ProfilePiece>(page: page));
    } on ApiException catch (e) {
      if (firstPage && e.isTransport) {
        final CursorPage<ProfilePiece>? cached = await _readCachedPage(
          _mePiecesKey,
        );
        if (cached != null) {
          return Ok<CachedPage<ProfilePiece>>(
            CachedPage<ProfilePiece>(page: cached, isStale: true),
          );
        }
      }
      return Err<CachedPage<ProfilePiece>>(mapApiExceptionToFailure(e));
    } on Object catch (e) {
      return Err<CachedPage<ProfilePiece>>(
        Failure.unexpected(
          code: ErrorCodes.apiUnexpected,
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<BoundedCount>> myDraftCount() =>
      _boundedCount(_remote.draftsCountPage);

  @override
  Future<Result<BoundedCount>> myBookmarkCount() =>
      _boundedCount(_remote.bookmarksCountPage);

  Future<Result<BoundedCount>> _boundedCount(
    Future<CursorPage<Json>> Function() fetch,
  ) => _guard<BoundedCount>(() async {
    final CursorPage<Json> page = await fetch();
    return (count: page.items.length, hasMore: page.hasMore);
  });

  /// Run a remote call, translating exceptions to a [Failure].
  Future<Result<T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Ok<T>(await run());
    } on ApiException catch (e) {
      return Err<T>(mapApiExceptionToFailure(e));
    } on Object catch (e) {
      return Err<T>(
        Failure.unexpected(
          code: ErrorCodes.apiUnexpected,
          message: e.toString(),
        ),
      );
    }
  }

  Future<Profile?> _readCachedProfile(String key) async {
    final CacheEntry? entry = await _cache.read(key);
    if (entry == null) return null;
    try {
      return profileFromJson(entry.value);
    } on Object {
      return null;
    }
  }

  Future<void> _writePageCache(String key, CursorPage<ProfilePiece> page) =>
      _cache.write(key, <String, Object?>{
        'items': <Json>[for (final ProfilePiece p in page.items) p.toJson()],
        'meta': <String, Object?>{
          'nextCursor': page.meta.nextCursor,
          'hasMore': page.meta.hasMore,
          'limit': page.meta.limit,
        },
      }, tier: CacheTier.content);

  Future<CursorPage<ProfilePiece>?> _readCachedPage(String key) async {
    final CacheEntry? entry = await _cache.read(key);
    if (entry == null) return null;
    try {
      final Object? items = entry.value['items'];
      final Object? meta = entry.value['meta'];
      if (items is! List) return null;
      final List<ProfilePiece> pieces = items
          .whereType<Map<dynamic, dynamic>>()
          .map((Map<dynamic, dynamic> m) => profilePieceFromJson(Json.from(m)))
          .toList(growable: false);
      final CursorMeta cursorMeta = meta is Map
          ? CursorMeta.fromJson(Json.from(meta))
          : const CursorMeta();
      return CursorPage<ProfilePiece>(items: pieces, meta: cursorMeta);
    } on Object {
      return null;
    }
  }

  String _mimeFor(String path) {
    final String lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}
