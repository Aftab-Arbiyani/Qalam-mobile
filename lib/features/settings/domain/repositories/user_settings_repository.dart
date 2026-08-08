/// The server-side preference bag, as the presentation layer sees it (docs/40 §16.2):
/// `Result`-returning, never throwing.
library;

import '../../../../core/utils/result.dart';
import '../entities/user_settings.dart';

abstract interface class UserSettingsRepository {
  Future<Result<UserSettings>> get();

  /// B5 — turn AI on or off for this account (`platfrom/docs/45` §4.10).
  Future<Result<UserSettings>> setAiEnabled(bool value);
}
