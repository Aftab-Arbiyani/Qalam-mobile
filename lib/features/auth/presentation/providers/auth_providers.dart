/// The auth feature's composition root (docs/40 §9). One-line providers bind the
/// domain interfaces to their data implementations and expose the use cases. The
/// domain declares the interface; a provider produces the concrete impl; consumers
/// (form controllers) depend on the use-case providers — never on the data layer
/// directly. Everything is overridable, so tests fake at any boundary.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/services/social_sign_in_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/exchange_social_code.dart';
import '../../domain/usecases/register_account.dart';
import '../../domain/usecases/request_password_reset.dart';
import '../../domain/usecases/resend_verification.dart';
import '../../domain/usecases/reset_password.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/verify_email.dart';

part 'auth_providers.g.dart';

@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) => AuthRemoteDataSource(
  ref.watch(apiClientProvider),
  ref.watch(tokenStoreProvider),
);

@riverpod
AuthRepository authRepository(Ref ref) =>
    AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));

/// The native social-launch seam (docs/40 §14.4). Inert by default; overridden by
/// a real launcher in a later epic with no change to the pipeline above.
@Riverpod(keepAlive: true)
SocialSignInService socialSignInService(Ref ref) =>
    const UnsupportedSocialSignInService();

// ── Use cases ─────────────────────────────────────────────────────────────────

@riverpod
SignInUseCase signInUseCase(Ref ref) =>
    SignInUseCase(ref.watch(authRepositoryProvider));

@riverpod
RegisterAccountUseCase registerAccountUseCase(Ref ref) =>
    RegisterAccountUseCase(ref.watch(authRepositoryProvider));

@riverpod
RequestPasswordResetUseCase requestPasswordResetUseCase(Ref ref) =>
    RequestPasswordResetUseCase(ref.watch(authRepositoryProvider));

@riverpod
ResetPasswordUseCase resetPasswordUseCase(Ref ref) =>
    ResetPasswordUseCase(ref.watch(authRepositoryProvider));

@riverpod
VerifyEmailUseCase verifyEmailUseCase(Ref ref) =>
    VerifyEmailUseCase(ref.watch(authRepositoryProvider));

@riverpod
ResendVerificationUseCase resendVerificationUseCase(Ref ref) =>
    ResendVerificationUseCase(ref.watch(authRepositoryProvider));

@riverpod
SignOutUseCase signOutUseCase(Ref ref) =>
    SignOutUseCase(ref.watch(authRepositoryProvider));

@riverpod
ExchangeSocialCodeUseCase exchangeSocialCodeUseCase(Ref ref) =>
    ExchangeSocialCodeUseCase(ref.watch(authRepositoryProvider));
