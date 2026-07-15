/// Sign-out use case (docs/40 §14.6, §20). Best-effort server revocation —
/// `POST /auth/logout` for this device, or `POST /auth/logout-all` ("sign out
/// everywhere", which bumps the session version and kills every family). The
/// caller runs the local session teardown regardless of the network outcome, so
/// logout works offline.
library;

import '../../../../core/utils/result.dart';
import '../../../../core/utils/typedefs.dart';
import '../repositories/auth_repository.dart';

class SignOutUseCase {
  const SignOutUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<Unit>> call({bool everywhere = false}) =>
      everywhere ? _repository.logoutAll() : _repository.logout();
}
