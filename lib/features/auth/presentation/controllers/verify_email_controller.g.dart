// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_email_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VerifyEmailController)
final verifyEmailControllerProvider = VerifyEmailControllerProvider._();

final class VerifyEmailControllerProvider
    extends $NotifierProvider<VerifyEmailController, VerifyEmailState> {
  VerifyEmailControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'verifyEmailControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$verifyEmailControllerHash();

  @$internal
  @override
  VerifyEmailController create() => VerifyEmailController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VerifyEmailState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VerifyEmailState>(value),
    );
  }
}

String _$verifyEmailControllerHash() =>
    r'fd53067fd39695760756d3d6ddf3b2db83516dd9';

abstract class _$VerifyEmailController extends $Notifier<VerifyEmailState> {
  VerifyEmailState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<VerifyEmailState, VerifyEmailState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VerifyEmailState, VerifyEmailState>,
              VerifyEmailState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
