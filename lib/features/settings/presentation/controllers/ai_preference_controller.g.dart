// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_preference_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AiPreferenceController)
final aiPreferenceControllerProvider = AiPreferenceControllerProvider._();

final class AiPreferenceControllerProvider
    extends $AsyncNotifierProvider<AiPreferenceController, UserSettings> {
  AiPreferenceControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiPreferenceControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiPreferenceControllerHash();

  @$internal
  @override
  AiPreferenceController create() => AiPreferenceController();
}

String _$aiPreferenceControllerHash() =>
    r'189f2b9dea0dbec91c548fc89d70b2c748d2eb0f';

abstract class _$AiPreferenceController extends $AsyncNotifier<UserSettings> {
  FutureOr<UserSettings> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<UserSettings>, UserSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UserSettings>, UserSettings>,
              AsyncValue<UserSettings>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
