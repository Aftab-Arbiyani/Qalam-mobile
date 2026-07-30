// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'craft_coach_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CraftCoachController)
final craftCoachControllerProvider = CraftCoachControllerProvider._();

final class CraftCoachControllerProvider
    extends $NotifierProvider<CraftCoachController, CraftCoachState> {
  CraftCoachControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'craftCoachControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$craftCoachControllerHash();

  @$internal
  @override
  CraftCoachController create() => CraftCoachController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CraftCoachState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CraftCoachState>(value),
    );
  }
}

String _$craftCoachControllerHash() =>
    r'2db0fa12297d0dd6ef3850508b97c0ae3227a97d';

abstract class _$CraftCoachController extends $Notifier<CraftCoachState> {
  CraftCoachState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CraftCoachState, CraftCoachState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CraftCoachState, CraftCoachState>,
              CraftCoachState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
