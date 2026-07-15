/// Sign-in use case (docs/40 §14.3, §20). Authenticates email + password against
/// the frozen `POST /auth/login`. Pure orchestration over the repository; the
/// caller (the login form controller) establishes the session from the returned
/// [AuthResult] via the core session notifier.
library;

import '../../../../core/utils/result.dart';
import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase {
  const SignInUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthResult>> call({
    required String email,
    required String password,
  }) => _repository.login(email: email, password: password);
}
