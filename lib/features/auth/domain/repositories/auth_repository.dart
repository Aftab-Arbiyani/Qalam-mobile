/// The auth repository boundary (docs/40 §16). The domain speaks this interface;
/// the data layer implements it against the frozen `/api/v1/auth/*` contract. Every
/// method returns a domain [Result] — never a DTO, a `DioException`, or an HTTP
/// status. Nothing outside the data layer knows the wire exists.
library;

import '../../../../core/utils/result.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/auth_result.dart';

abstract interface class AuthRepository {
  /// `POST /auth/login` (200). Mobile channel → refresh token in body.
  Future<Result<AuthResult>> login({
    required String email,
    required String password,
  });

  /// `POST /auth/register` (201). Username is permanent (docs/40 §11.5).
  Future<Result<AuthResult>> register({
    required String email,
    required String username,
    required String password,
  });

  /// `POST /auth/forgot-password` (202). Always succeeds server-side regardless of
  /// whether the account exists (no enumeration) — a success here means "if that
  /// address has an account, a link is on its way."
  Future<Result<Unit>> requestPasswordReset({required String email});

  /// `POST /auth/reset-password` (200). Revokes all server sessions on success.
  Future<Result<Unit>> resetPassword({
    required String token,
    required String newPassword,
  });

  /// `POST /auth/verify-email` (200). Public — reachable signed-out (deep link) or
  /// freshly-registered.
  Future<Result<Unit>> verifyEmail({required String token});

  /// `POST /auth/resend-verification` (202). Requires an authenticated session
  /// (operates on the current user; no email in the body).
  Future<Result<Unit>> resendVerification();

  /// `POST /auth/logout` (204). Best-effort server revocation of the current
  /// refresh family; the local teardown proceeds regardless.
  Future<Result<Unit>> logout();

  /// `POST /auth/logout-all` (204). Revokes every session (bumps the session
  /// version) — "sign out everywhere".
  Future<Result<Unit>> logoutAll();

  /// `POST /auth/google/exchange` (200). Trades the one-time authorization code for
  /// an access token. The frozen response is `{ accessToken }` only — no user
  /// object and no body refresh token (docs/40 §14.4) — so the returned
  /// [AuthResult] has null `user`/`refreshToken`.
  Future<Result<AuthResult>> exchangeSocialCode({required String code});
}
