/// An in-memory [UserSettingsRepository] for B5 tests. Records the writes so a test can
/// assert the switch actually went to the SERVER rather than only moving on screen.
library;

import 'package:qalam_mobile/core/error/failure.dart';
import 'package:qalam_mobile/core/utils/result.dart';
import 'package:qalam_mobile/features/settings/domain/entities/user_settings.dart';
import 'package:qalam_mobile/features/settings/domain/repositories/user_settings_repository.dart';
import 'package:qalam_mobile/shared/domain/error_codes.dart';

class FakeUserSettingsRepository implements UserSettingsRepository {
  FakeUserSettingsRepository({bool aiEnabled = true, this.failWrites = false})
    : _aiEnabled = aiEnabled;

  bool _aiEnabled;

  /// When set, every write fails — the path where the switch must roll back and say so.
  final bool failWrites;

  /// Every value passed to [setAiEnabled], in order.
  final List<bool> writes = <bool>[];

  @override
  Future<Result<UserSettings>> get() async =>
      Ok<UserSettings>(UserSettings(aiEnabled: _aiEnabled));

  @override
  Future<Result<UserSettings>> setAiEnabled(bool value) async {
    writes.add(value);
    if (failWrites) {
      return const Err<UserSettings>(
        Failure.unexpected(code: ErrorCodes.apiUnexpected, message: 'nope'),
      );
    }
    _aiEnabled = value;
    return Ok<UserSettings>(UserSettings(aiEnabled: _aiEnabled));
  }
}
