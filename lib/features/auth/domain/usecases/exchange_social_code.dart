/// Social code-exchange use case (docs/40 §14.4, §20). Trades the one-time
/// authorization code (delivered to `/auth/callback`) for tokens via
/// `POST /auth/google/exchange`. Provider-agnostic at the domain level so Apple
/// (Phase 2) reuses it unchanged; the frozen backend exposes only the Google
/// exchange today.
library;

import '../../../../core/utils/result.dart';
import '../entities/auth_result.dart';
import '../entities/social_provider.dart';
import '../repositories/auth_repository.dart';

class ExchangeSocialCodeUseCase {
  const ExchangeSocialCodeUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthResult>> call({
    required SocialProvider provider,
    required String code,
  }) =>
      // Only Google is wired in the frozen contract; the provider is threaded
      // through for the Phase-2 Apple seam and telemetry.
      _repository.exchangeSocialCode(code: code);
}
