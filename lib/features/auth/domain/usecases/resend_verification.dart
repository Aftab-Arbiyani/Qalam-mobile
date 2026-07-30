/// Resend-verification use case (docs/40 §14.1, §20). Re-sends the verification
/// email via `POST /auth/resend-verification`, which requires an authenticated
/// session (it operates on the current user — no email in the body).
library;

import '../../../../core/utils/result.dart';
import '../../../../core/utils/typedefs.dart';
import '../repositories/auth_repository.dart';

class ResendVerificationUseCase {
  const ResendVerificationUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<Unit>> call() => _repository.resendVerification();
}
