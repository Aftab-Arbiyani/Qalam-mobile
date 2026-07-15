/// Wire → entity mappers for auth (docs/40 §18). The "DTO" here is the raw
/// envelope `data` map: this repo has no generated `qalam_api` client (an M1
/// decision), so — exactly as `core/network` decodes every other payload — the
/// data layer parses the wire map straight into domain entities via these pure
/// functions. All wire fields are camelCase (confirmed against the frozen backend).
///
/// Rule: ignore unknown fields (forward-compatible with additive `v1` changes);
/// a missing `user`/`refreshToken` is valid (the Google exchange shape).
library;

import '../../../../core/session/current_user.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/auth_result.dart';

/// Parse the `user` summary `{ id, email, username, isEmailVerified }`.
CurrentUser currentUserFromJson(Json json) => CurrentUser(
  id: json['id'] as String,
  email: json['email'] as String,
  username: json['username'] as String,
  isEmailVerified: (json['isEmailVerified'] as bool?) ?? false,
);

/// Parse an auth response. Handles both the login/register shape
/// (`{ user, accessToken, refreshToken }`) and the Google exchange shape
/// (`{ accessToken }` — no user, no body refresh token).
AuthResult authResultFromJson(Json json) {
  final Object? userJson = json['user'];
  return AuthResult(
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String?,
    user: userJson is Map ? currentUserFromJson(Json.from(userJson)) : null,
  );
}
