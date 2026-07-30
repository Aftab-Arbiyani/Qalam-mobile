/// The domain result of a successful authentication (docs/40 §14.2). The auth
/// data layer maps the wire response into this; the session layer consumes it to
/// establish the session.
///
/// [user] is present for email/password login & register (the response carries the
/// `user` summary); it is `null` for the Google exchange path, whose frozen `v1`
/// response is `{ accessToken }` only (§14.4). [refreshToken] is likewise present
/// for login/register (mobile channel → body) and `null` for Google exchange.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/session/current_user.dart';

part 'auth_result.freezed.dart';

@freezed
abstract class AuthResult with _$AuthResult {
  const factory AuthResult({
    required String accessToken,
    CurrentUser? user,
    String? refreshToken,
  }) = _AuthResult;
}
