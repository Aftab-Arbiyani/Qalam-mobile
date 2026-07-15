/// Forgot-password use case (docs/40 §14.1, §20). Requests a reset link via
/// `POST /auth/forgot-password`. Success is enumeration-safe: it means "if that
/// address has an account, a link is on its way" — the UI shows the same calm
/// confirmation either way.
library;

import '../../../../core/utils/result.dart';
import '../../../../core/utils/typedefs.dart';
import '../repositories/auth_repository.dart';

class RequestPasswordResetUseCase {
  const RequestPasswordResetUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<Unit>> call({required String email}) =>
      _repository.requestPasswordReset(email: email);
}
