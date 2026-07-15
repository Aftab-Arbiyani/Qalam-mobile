/// The in-memory current-user holder (docs/40 §8.5). `keepAlive` so it survives
/// navigation; populated alongside the session on sign-in, cleared on sign-out.
/// After a cold-start silent restore it is `null` (the refresh response carries no
/// user object and the JWT no email) — the account surface degrades gracefully and
/// M3 hydrates the full profile from `GET /me`.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'current_user.dart';

part 'current_user_controller.g.dart';

@Riverpod(keepAlive: true)
class CurrentUserController extends _$CurrentUserController {
  @override
  CurrentUser? build() => null;

  // ignore: use_setters_to_change_properties
  void set(CurrentUser user) => state = user;

  void clear() => state = null;

  /// Reflect a successful email verification without re-fetching identity.
  void markEmailVerified() {
    final CurrentUser? user = state;
    if (user != null) state = user.copyWith(isEmailVerified: true);
  }
}
