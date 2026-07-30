/// Reset-password use case (docs/40 §14.1, §20). Sets a new password from a reset
/// token via `POST /auth/reset-password`. On success the backend revokes ALL
/// sessions, so the caller lands the user back on login to re-authenticate.
library;

import '../../../../core/utils/result.dart';
import '../../../../core/utils/typedefs.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  const ResetPasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<Unit>> call({
    required String token,
    required String newPassword,
  }) => _repository.resetPassword(token: token, newPassword: newPassword);
}
