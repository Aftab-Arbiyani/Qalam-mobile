/// Access + refresh token custody (docs/40 §14, §15, §27).
///
/// Access token: kept in secure storage AND cached in memory for the hot path
/// (the auth interceptor reads it synchronously). Refresh token: secure storage
/// only. Rotation replaces BOTH atomically — a stale refresh token is never kept
/// (presenting it trips the backend's family-reuse detection).
library;

import '../storage/secure_storage.dart';

class TokenStore {
  TokenStore(this._storage);

  final SecureStorage _storage;

  static const String _kAccess = 'qalam.access_token';
  static const String _kRefresh = 'qalam.refresh_token';

  String? _accessCache;

  /// The cached access token for the request hot path (sync).
  String? get accessToken => _accessCache;

  /// Load the cached access token from secure storage at boot.
  Future<void> restore() async {
    _accessCache = await _storage.read(_kAccess);
  }

  Future<bool> hasRefreshToken() async {
    final String? refresh = await _storage.read(_kRefresh);
    return refresh != null && refresh.isNotEmpty;
  }

  Future<String?> readRefreshToken() => _storage.read(_kRefresh);

  /// Atomically persist a freshly issued token pair (login or rotation). A null
  /// or empty [refresh] persists the access token alone and clears any prior
  /// refresh token — the case for Google exchange, whose frozen `v1` response
  /// carries no body refresh token (docs/40 §14.4; the refresh was set as an
  /// httpOnly cookie in the web callback, unreachable on mobile). Such a session
  /// is access-token-only (no silent restore) — a documented contract gap.
  Future<void> save({required String access, String? refresh}) async {
    _accessCache = access;
    await _storage.write(_kAccess, access);
    if (refresh == null || refresh.isEmpty) {
      await _storage.delete(_kRefresh);
    } else {
      await _storage.write(_kRefresh, refresh);
    }
  }

  /// Clear all tokens (logout / refresh failure / session revoked).
  Future<void> clear() async {
    _accessCache = null;
    await _storage.delete(_kAccess);
    await _storage.delete(_kRefresh);
  }
}
