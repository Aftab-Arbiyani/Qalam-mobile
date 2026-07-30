// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LoginFormController)
final loginFormControllerProvider = LoginFormControllerProvider._();

final class LoginFormControllerProvider
    extends $NotifierProvider<LoginFormController, LoginFormState> {
  LoginFormControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loginFormControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loginFormControllerHash();

  @$internal
  @override
  LoginFormController create() => LoginFormController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoginFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoginFormState>(value),
    );
  }
}

String _$loginFormControllerHash() =>
    r'8e6f5a8cd964d1fa5b4f9dedf36bc677472759d5';

abstract class _$LoginFormController extends $Notifier<LoginFormState> {
  LoginFormState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LoginFormState, LoginFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LoginFormState, LoginFormState>,
              LoginFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
