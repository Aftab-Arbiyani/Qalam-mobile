// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reset_password_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ResetPasswordFormController)
final resetPasswordFormControllerProvider =
    ResetPasswordFormControllerProvider._();

final class ResetPasswordFormControllerProvider
    extends
        $NotifierProvider<ResetPasswordFormController, ResetPasswordFormState> {
  ResetPasswordFormControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'resetPasswordFormControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$resetPasswordFormControllerHash();

  @$internal
  @override
  ResetPasswordFormController create() => ResetPasswordFormController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ResetPasswordFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ResetPasswordFormState>(value),
    );
  }
}

String _$resetPasswordFormControllerHash() =>
    r'1ff40b7c4532cb0896d0267e9b729ba65875e94f';

abstract class _$ResetPasswordFormController
    extends $Notifier<ResetPasswordFormState> {
  ResetPasswordFormState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<ResetPasswordFormState, ResetPasswordFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ResetPasswordFormState, ResetPasswordFormState>,
              ResetPasswordFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
