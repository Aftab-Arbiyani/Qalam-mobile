// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_password_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChangePasswordController)
final changePasswordControllerProvider = ChangePasswordControllerProvider._();

final class ChangePasswordControllerProvider
    extends $NotifierProvider<ChangePasswordController, ChangePasswordState> {
  ChangePasswordControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'changePasswordControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$changePasswordControllerHash();

  @$internal
  @override
  ChangePasswordController create() => ChangePasswordController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChangePasswordState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChangePasswordState>(value),
    );
  }
}

String _$changePasswordControllerHash() =>
    r'71baa90b31012ea7a8fcbd86c3c911452a529c6c';

abstract class _$ChangePasswordController
    extends $Notifier<ChangePasswordState> {
  ChangePasswordState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ChangePasswordState, ChangePasswordState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChangePasswordState, ChangePasswordState>,
              ChangePasswordState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
