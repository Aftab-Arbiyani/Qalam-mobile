// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authRemoteDataSource)
final authRemoteDataSourceProvider = AuthRemoteDataSourceProvider._();

final class AuthRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          AuthRemoteDataSource,
          AuthRemoteDataSource,
          AuthRemoteDataSource
        >
    with $Provider<AuthRemoteDataSource> {
  AuthRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<AuthRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AuthRemoteDataSource create(Ref ref) {
    return authRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRemoteDataSource>(value),
    );
  }
}

String _$authRemoteDataSourceHash() =>
    r'37299f0ffabc196c9e20a4de417cf9d55d10ca41';

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'c2e2aedfa7e64bc1421d451d13d19426f1c7eb29';

/// The native social-launch seam (docs/40 §14.4). Inert by default; overridden by
/// a real launcher in a later epic with no change to the pipeline above.

@ProviderFor(socialSignInService)
final socialSignInServiceProvider = SocialSignInServiceProvider._();

/// The native social-launch seam (docs/40 §14.4). Inert by default; overridden by
/// a real launcher in a later epic with no change to the pipeline above.

final class SocialSignInServiceProvider
    extends
        $FunctionalProvider<
          SocialSignInService,
          SocialSignInService,
          SocialSignInService
        >
    with $Provider<SocialSignInService> {
  /// The native social-launch seam (docs/40 §14.4). Inert by default; overridden by
  /// a real launcher in a later epic with no change to the pipeline above.
  SocialSignInServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'socialSignInServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$socialSignInServiceHash();

  @$internal
  @override
  $ProviderElement<SocialSignInService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SocialSignInService create(Ref ref) {
    return socialSignInService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SocialSignInService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SocialSignInService>(value),
    );
  }
}

String _$socialSignInServiceHash() =>
    r'0ed745d7111537577e94ac9d50a0a6d9beb169f7';

@ProviderFor(signInUseCase)
final signInUseCaseProvider = SignInUseCaseProvider._();

final class SignInUseCaseProvider
    extends $FunctionalProvider<SignInUseCase, SignInUseCase, SignInUseCase>
    with $Provider<SignInUseCase> {
  SignInUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signInUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signInUseCaseHash();

  @$internal
  @override
  $ProviderElement<SignInUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SignInUseCase create(Ref ref) {
    return signInUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignInUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignInUseCase>(value),
    );
  }
}

String _$signInUseCaseHash() => r'3be5fb94ae08302bbccc4de0394917075359007c';

@ProviderFor(registerAccountUseCase)
final registerAccountUseCaseProvider = RegisterAccountUseCaseProvider._();

final class RegisterAccountUseCaseProvider
    extends
        $FunctionalProvider<
          RegisterAccountUseCase,
          RegisterAccountUseCase,
          RegisterAccountUseCase
        >
    with $Provider<RegisterAccountUseCase> {
  RegisterAccountUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'registerAccountUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$registerAccountUseCaseHash();

  @$internal
  @override
  $ProviderElement<RegisterAccountUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RegisterAccountUseCase create(Ref ref) {
    return registerAccountUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RegisterAccountUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RegisterAccountUseCase>(value),
    );
  }
}

String _$registerAccountUseCaseHash() =>
    r'5124780cbcf581c0190389bab7b5df14e35353e1';

@ProviderFor(requestPasswordResetUseCase)
final requestPasswordResetUseCaseProvider =
    RequestPasswordResetUseCaseProvider._();

final class RequestPasswordResetUseCaseProvider
    extends
        $FunctionalProvider<
          RequestPasswordResetUseCase,
          RequestPasswordResetUseCase,
          RequestPasswordResetUseCase
        >
    with $Provider<RequestPasswordResetUseCase> {
  RequestPasswordResetUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'requestPasswordResetUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$requestPasswordResetUseCaseHash();

  @$internal
  @override
  $ProviderElement<RequestPasswordResetUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RequestPasswordResetUseCase create(Ref ref) {
    return requestPasswordResetUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RequestPasswordResetUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RequestPasswordResetUseCase>(value),
    );
  }
}

String _$requestPasswordResetUseCaseHash() =>
    r'e7f4f5edac15c152a5b069169b8d8ba8a9840eaa';

@ProviderFor(resetPasswordUseCase)
final resetPasswordUseCaseProvider = ResetPasswordUseCaseProvider._();

final class ResetPasswordUseCaseProvider
    extends
        $FunctionalProvider<
          ResetPasswordUseCase,
          ResetPasswordUseCase,
          ResetPasswordUseCase
        >
    with $Provider<ResetPasswordUseCase> {
  ResetPasswordUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'resetPasswordUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$resetPasswordUseCaseHash();

  @$internal
  @override
  $ProviderElement<ResetPasswordUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ResetPasswordUseCase create(Ref ref) {
    return resetPasswordUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ResetPasswordUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ResetPasswordUseCase>(value),
    );
  }
}

String _$resetPasswordUseCaseHash() =>
    r'954e56b2b94719a458ccec2b3c9101151c1cde49';

@ProviderFor(verifyEmailUseCase)
final verifyEmailUseCaseProvider = VerifyEmailUseCaseProvider._();

final class VerifyEmailUseCaseProvider
    extends
        $FunctionalProvider<
          VerifyEmailUseCase,
          VerifyEmailUseCase,
          VerifyEmailUseCase
        >
    with $Provider<VerifyEmailUseCase> {
  VerifyEmailUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'verifyEmailUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$verifyEmailUseCaseHash();

  @$internal
  @override
  $ProviderElement<VerifyEmailUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VerifyEmailUseCase create(Ref ref) {
    return verifyEmailUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VerifyEmailUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VerifyEmailUseCase>(value),
    );
  }
}

String _$verifyEmailUseCaseHash() =>
    r'16a79a670026b92b5c43a23aadd5eb73cd1c6bb3';

@ProviderFor(resendVerificationUseCase)
final resendVerificationUseCaseProvider = ResendVerificationUseCaseProvider._();

final class ResendVerificationUseCaseProvider
    extends
        $FunctionalProvider<
          ResendVerificationUseCase,
          ResendVerificationUseCase,
          ResendVerificationUseCase
        >
    with $Provider<ResendVerificationUseCase> {
  ResendVerificationUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'resendVerificationUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$resendVerificationUseCaseHash();

  @$internal
  @override
  $ProviderElement<ResendVerificationUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ResendVerificationUseCase create(Ref ref) {
    return resendVerificationUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ResendVerificationUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ResendVerificationUseCase>(value),
    );
  }
}

String _$resendVerificationUseCaseHash() =>
    r'57e293097153e410a929a61ed8d1d366b5c23ba9';

@ProviderFor(signOutUseCase)
final signOutUseCaseProvider = SignOutUseCaseProvider._();

final class SignOutUseCaseProvider
    extends $FunctionalProvider<SignOutUseCase, SignOutUseCase, SignOutUseCase>
    with $Provider<SignOutUseCase> {
  SignOutUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signOutUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signOutUseCaseHash();

  @$internal
  @override
  $ProviderElement<SignOutUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SignOutUseCase create(Ref ref) {
    return signOutUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignOutUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignOutUseCase>(value),
    );
  }
}

String _$signOutUseCaseHash() => r'43b88dc732fc2ec257d73871891f04dcae657f24';

@ProviderFor(exchangeSocialCodeUseCase)
final exchangeSocialCodeUseCaseProvider = ExchangeSocialCodeUseCaseProvider._();

final class ExchangeSocialCodeUseCaseProvider
    extends
        $FunctionalProvider<
          ExchangeSocialCodeUseCase,
          ExchangeSocialCodeUseCase,
          ExchangeSocialCodeUseCase
        >
    with $Provider<ExchangeSocialCodeUseCase> {
  ExchangeSocialCodeUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exchangeSocialCodeUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exchangeSocialCodeUseCaseHash();

  @$internal
  @override
  $ProviderElement<ExchangeSocialCodeUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ExchangeSocialCodeUseCase create(Ref ref) {
    return exchangeSocialCodeUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExchangeSocialCodeUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExchangeSocialCodeUseCase>(value),
    );
  }
}

String _$exchangeSocialCodeUseCaseHash() =>
    r'e5cc5681f20af51be8405539ee953584bf4c41a4';
