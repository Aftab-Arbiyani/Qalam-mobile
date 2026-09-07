// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_map_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StoryMapController)
final storyMapControllerProvider = StoryMapControllerProvider._();

final class StoryMapControllerProvider
    extends $NotifierProvider<StoryMapController, StoryMapState> {
  StoryMapControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storyMapControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storyMapControllerHash();

  @$internal
  @override
  StoryMapController create() => StoryMapController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StoryMapState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StoryMapState>(value),
    );
  }
}

String _$storyMapControllerHash() =>
    r'005b8041370dc9b8c09fa8af713f886dbc58fc14';

abstract class _$StoryMapController extends $Notifier<StoryMapState> {
  StoryMapState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<StoryMapState, StoryMapState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StoryMapState, StoryMapState>,
              StoryMapState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
