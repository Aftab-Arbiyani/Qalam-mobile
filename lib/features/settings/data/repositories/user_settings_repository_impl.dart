/// Preference-bag repository (docs/40 §16.2). Both operations go through the single
/// [guardResult] boundary, which is what turns an [ApiException] into a [Failure] the
/// controller can render.
///
/// **Deliberately not cached.** The other preference reads on this client cache at the
/// identity tier, but B5's switch is an ENFORCEMENT setting: a stale `true` would draw
/// AI affordances the server has already started refusing, which is the client/server
/// disagreement the whole feature exists to avoid. It is read once per settings screen.
library;

import '../../../../core/error/result_guard.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/user_settings.dart';
import '../../domain/repositories/user_settings_repository.dart';
import '../datasources/user_settings_remote_data_source.dart';

class UserSettingsRepositoryImpl implements UserSettingsRepository {
  UserSettingsRepositoryImpl(this._remote);

  final UserSettingsRemoteDataSource _remote;

  @override
  Future<Result<UserSettings>> get() => guardResult(_remote.get);

  @override
  Future<Result<UserSettings>> setAiEnabled(bool value) =>
      guardResult(() => _remote.setAiEnabled(value));
}
