/// Change-password use case (docs/40 §14.1, §20). Changes the signed-in user's
/// password via `POST /auth/change-password`. On success the backend revokes all
/// sessions and returns freshly-rotated tokens; the caller re-establishes the
/// session with them so the user stays signed in on THIS device.
library;

import '../../../../core/utils/result.dart';
import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

class ChangePasswordUseCase {
  const ChangePasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthResult>> call({
    required String currentPassword,
    required String newPassword,
  }) => _repository.changePassword(
    currentPassword: currentPassword,
    newPassword: newPassword,
  );
}
