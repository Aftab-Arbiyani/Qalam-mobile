/// The signed-in user's identity summary (docs/40 §8.5, §19.1).
///
/// This is the small, cross-cutting identity the auth response carries
/// (`{ id, email, username, isEmailVerified }`) — NOT the full profile aggregate
/// (pen name, bio, counts), which is a separate server-state provider keyed by the
/// current user and hydrated by M3. A pure value object; it lives in `core`
/// because it is genuinely cross-cutting (session, the verify-email surface, the
/// account surface all read it) — a feature home would force cross-feature imports
/// (docs/40 §7.3). The holder (`CurrentUserController`) lives beside it in
/// `current_user_controller.dart`, kept separate so the pure entity can be imported
/// by the domain layer without a provider dependency.
///
/// Held in memory only; NEVER persisted to disk (it is session PII — docs/40 §27,
/// §39.1).
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'current_user.freezed.dart';

@freezed
abstract class CurrentUser with _$CurrentUser {
  const factory CurrentUser({
    required String id,
    required String email,
    required String username,
    required bool isEmailVerified,
  }) = _CurrentUser;
}
