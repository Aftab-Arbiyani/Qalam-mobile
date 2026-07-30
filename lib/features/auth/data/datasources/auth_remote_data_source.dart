/// Auth remote data source (docs/40 §17.1) — the only place the auth feature
/// touches the wire. Every call goes through `core/network`'s [ApiClient], which
/// unwraps the envelope, applies the offline pre-check, and converts transport
/// failures to [ApiException]. `X-Client: mobile` (set globally on the Dio
/// instance) makes the backend return the refresh token in the body.
///
/// Knows nothing about caching, session state, or `Failure` — it returns raw
/// entities or throws [ApiException]; the repository translates.
library;

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_paths.dart';
import '../../../../core/security/token_store.dart';
import '../../domain/entities/auth_result.dart';
import '../mappers/auth_mappers.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._api, this._tokenStore);

  final ApiClient _api;
  final TokenStore _tokenStore;

  Future<AuthResult> login({required String email, required String password}) =>
      _api.post<AuthResult>(
        ApiPaths.authLogin,
        body: <String, Object?>{'email': email, 'password': password},
        decode: authResultFromJson,
      );

  Future<AuthResult> register({
    required String email,
    required String username,
    required String password,
  }) => _api.post<AuthResult>(
    ApiPaths.authRegister,
    body: <String, Object?>{
      'email': email,
      'username': username,
      'password': password,
    },
    decode: authResultFromJson,
  );

  Future<void> requestPasswordReset({required String email}) => _api.postVoid(
    ApiPaths.authForgotPassword,
    body: <String, Object?>{'email': email},
  );

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) => _api.postVoid(
    ApiPaths.authResetPassword,
    body: <String, Object?>{'token': token, 'newPassword': newPassword},
  );

  Future<void> verifyEmail({required String token}) => _api.postVoid(
    ApiPaths.authVerifyEmail,
    body: <String, Object?>{'token': token},
  );

  Future<void> resendVerification() =>
      _api.postVoid(ApiPaths.authResendVerification);

  Future<void> logout() async {
    // Mobile sends the refresh token in the body so the server can revoke this
    // family; the access token is attached by the interceptor.
    final String? refresh = await _tokenStore.readRefreshToken();
    await _api.postVoid(
      ApiPaths.authLogout,
      body: refresh == null || refresh.isEmpty
          ? null
          : <String, Object?>{'refreshToken': refresh},
    );
  }

  Future<void> logoutAll() => _api.postVoid(ApiPaths.authLogoutAll);

  /// `POST /auth/change-password` (200). Returns a fresh `TokenResponseDto`
  /// (mobile channel → refresh token in body; no `user`), because the server
  /// revokes all sessions — the caller re-establishes with these rotated tokens.
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => _api.post<AuthResult>(
    ApiPaths.authChangePassword,
    body: <String, Object?>{
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    },
    decode: authResultFromJson,
  );

  Future<AuthResult> exchangeSocialCode({required String code}) =>
      _api.post<AuthResult>(
        ApiPaths.authGoogleExchange,
        body: <String, Object?>{'code': code},
        decode: authResultFromJson,
      );
}
