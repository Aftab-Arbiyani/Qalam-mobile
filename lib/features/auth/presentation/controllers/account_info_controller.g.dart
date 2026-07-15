// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_info_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(signInMethod)
final signInMethodProvider = SignInMethodProvider._();

final class SignInMethodProvider
    extends $FunctionalProvider<SignInMethod, SignInMethod, SignInMethod>
    with $Provider<SignInMethod> {
  SignInMethodProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signInMethodProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signInMethodHash();

  @$internal
  @override
  $ProviderElement<SignInMethod> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SignInMethod create(Ref ref) {
    return signInMethod(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignInMethod value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignInMethod>(value),
    );
  }
}

String _$signInMethodHash() => r'fd0c4df0ada9e0cd70df825ba737829c7e139eb9';

@ProviderFor(deviceSessionInfo)
final deviceSessionInfoProvider = DeviceSessionInfoProvider._();

final class DeviceSessionInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<DeviceSessionInfo>,
          DeviceSessionInfo,
          FutureOr<DeviceSessionInfo>
        >
    with
        $FutureModifier<DeviceSessionInfo>,
        $FutureProvider<DeviceSessionInfo> {
  DeviceSessionInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceSessionInfoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceSessionInfoHash();

  @$internal
  @override
  $FutureProviderElement<DeviceSessionInfo> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DeviceSessionInfo> create(Ref ref) {
    return deviceSessionInfo(ref);
  }
}

String _$deviceSessionInfoHash() => r'1895572a7890b710d59859b75d9bf9c93214c570';
