/// `GET/PATCH /settings` — the server-side preference bag. Throws [ApiException]
/// for the repository to convert; the partial PATCH sends only the keys being
/// changed, so a write here can never clobber a sibling preference.
library;

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_paths.dart';
import '../../domain/entities/user_settings.dart';

class UserSettingsRemoteDataSource {
  UserSettingsRemoteDataSource(this._api);

  final ApiClient _api;

  Future<UserSettings> get() => _api.get<UserSettings>(
    ApiPaths.userSettings,
    decode: UserSettings.fromJson,
  );

  /// B5 — flip the account's AI switch. `aiEnabled` is the ONLY key sent: the endpoint
  /// treats an absent key as "leave it alone", so this cannot reset the writer's theme
  /// or notification flags as a side effect.
  Future<UserSettings> setAiEnabled(bool value) => _api.patch<UserSettings>(
    ApiPaths.userSettings,
    body: <String, dynamic>{'aiEnabled': value},
    decode: UserSettings.fromJson,
  );
}
