/// Verify-email use case (docs/40 §11.5, §14.1, §20). Submits a verification token
/// via `POST /auth/verify-email`. Public — reachable signed-out (deep link) or
/// freshly-registered. On success the caller marks the live session verified.
library;

import '../../../../core/utils/result.dart';
import '../../../../core/utils/typedefs.dart';
import '../repositories/auth_repository.dart';

class VerifyEmailUseCase {
  const VerifyEmailUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<Unit>> call({required String token}) =>
      _repository.verifyEmail(token: token);
}
