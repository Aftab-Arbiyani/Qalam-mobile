/// Token attachment + single-flight refresh (docs/40 §14, §15).
///
/// The refresh call runs on a DEDICATED bare Dio (no auth interceptor) so it can
/// never recurse. Concurrent callers await ONE in-flight refresh — critical,
/// because the backend rotates refresh tokens with family-reuse detection and a
/// stampede would self-revoke the session. On failure, tokens are cleared and
/// [onUnauthorized] fires so the session flips to anonymous.
library;

import 'dart:async';

import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../logging/app_logger.dart';
import '../security/token_store.dart';
import '../utils/typedefs.dart';
import 'api_paths.dart';

typedef UnauthorizedCallback = void Function();

class AuthGateway {
  AuthGateway({
    required TokenStore tokenStore,
    required AppConfig config,
    required AppLogger logger,
    Dio? refreshClient,
  }) : _tokenStore = tokenStore,
       _logger = logger,
       _refreshClient =
           refreshClient ??
           Dio(
             BaseOptions(
               baseUrl: config.apiBaseUrl,
               connectTimeout: const Duration(seconds: 20),
               receiveTimeout: const Duration(seconds: 20),
               headers: <String, Object?>{
                 'Accept': 'application/json',
                 'X-Client': config.clientHeader,
               },
             ),
           );

  final TokenStore _tokenStore;
  final AppLogger _logger;
  final Dio _refreshClient;

  /// Fired on a terminal unauthorized (refresh failed / session revoked). The
  /// session layer wires this to flip the session to anonymous and route to login.
  UnauthorizedCallback? onUnauthorized;

  Completer<bool>? _inflight;

  /// The cached access token for the request hot path.
  String? get accessToken => _tokenStore.accessToken;

  /// Attempt a single-flight refresh. Returns true on success (new tokens saved).
  Future<bool> refresh() {
    final Completer<bool>? existing = _inflight;
    if (existing != null) return existing.future;

    final Completer<bool> completer = Completer<bool>();
    _inflight = completer;
    unawaited(
      _performRefresh()
          .then((bool ok) {
            _inflight = null;
            completer.complete(ok);
          })
          .catchError((Object _) {
            _inflight = null;
            completer.complete(false);
          }),
    );
    return completer.future;
  }

  Future<bool> _performRefresh() async {
    final String? refreshToken = await _tokenStore.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final Response<dynamic> resp = await _refreshClient.post<dynamic>(
        ApiPaths.authRefresh,
        data: <String, Object?>{'refreshToken': refreshToken},
      );
      final Object? body = resp.data;
      if (body is Map && body['success'] == true && body['data'] is Map) {
        final Json data = Json.from(body['data'] as Map<dynamic, dynamic>);
        final String? access = data['accessToken'] as String?;
        final String? newRefresh = data['refreshToken'] as String?;
        if (access != null && newRefresh != null) {
          await _tokenStore.save(access: access, refresh: newRefresh);
          return true;
        }
      }
      return false;
    } on DioException catch (e) {
      _logger.w('Token refresh failed', error: e);
      return false;
    }
  }

  /// Clear the session and notify listeners (route to login).
  Future<void> handleTerminalUnauthorized() async {
    await _tokenStore.clear();
    onUnauthorized?.call();
  }
}
