/// Registration use case (docs/40 §14.3, §20). Creates an account via the frozen
/// `POST /auth/register`. The username is permanent (§11.5) — the caller confirms
/// it once ("write it in ink") and never offers an edit path. Pure orchestration
/// over the repository; the caller establishes the session from the [AuthResult].
library;

import '../../../../core/utils/result.dart';
import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

class RegisterAccountUseCase {
  const RegisterAccountUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthResult>> call({
    required String email,
    required String username,
    required String password,
  }) => _repository.register(
    email: email,
    username: username,
    password: password,
  );
}
