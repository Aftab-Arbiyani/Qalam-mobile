// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trust_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TrustController)
final trustControllerProvider = TrustControllerProvider._();

final class TrustControllerProvider
    extends $AsyncNotifierProvider<TrustController, void> {
  TrustControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trustControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trustControllerHash();

  @$internal
  @override
  TrustController create() => TrustController();
}

String _$trustControllerHash() => r'02cc4a58ab82517a2cf2efc29fe6b03efa088a77';

abstract class _$TrustController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
