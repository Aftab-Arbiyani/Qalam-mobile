// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RegisterFormController)
final registerFormControllerProvider = RegisterFormControllerProvider._();

final class RegisterFormControllerProvider
    extends $NotifierProvider<RegisterFormController, RegisterFormState> {
  RegisterFormControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'registerFormControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$registerFormControllerHash();

  @$internal
  @override
  RegisterFormController create() => RegisterFormController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RegisterFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RegisterFormState>(value),
    );
  }
}

String _$registerFormControllerHash() =>
    r'2775170559c473c5ef1ce2a9b818831f911b44f8';

abstract class _$RegisterFormController extends $Notifier<RegisterFormState> {
  RegisterFormState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<RegisterFormState, RegisterFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RegisterFormState, RegisterFormState>,
              RegisterFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
