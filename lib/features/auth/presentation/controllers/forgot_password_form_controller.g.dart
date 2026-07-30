// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forgot_password_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ForgotPasswordFormController)
final forgotPasswordFormControllerProvider =
    ForgotPasswordFormControllerProvider._();

final class ForgotPasswordFormControllerProvider
    extends
        $NotifierProvider<
          ForgotPasswordFormController,
          ForgotPasswordFormState
        > {
  ForgotPasswordFormControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'forgotPasswordFormControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$forgotPasswordFormControllerHash();

  @$internal
  @override
  ForgotPasswordFormController create() => ForgotPasswordFormController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ForgotPasswordFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ForgotPasswordFormState>(value),
    );
  }
}

String _$forgotPasswordFormControllerHash() =>
    r'cf72eff6ff04e0717e4c916be75f8ad0b5c58419';

abstract class _$ForgotPasswordFormController
    extends $Notifier<ForgotPasswordFormState> {
  ForgotPasswordFormState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<ForgotPasswordFormState, ForgotPasswordFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ForgotPasswordFormState, ForgotPasswordFormState>,
              ForgotPasswordFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
