// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'publishing_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PublishingController)
final publishingControllerProvider = PublishingControllerProvider._();

final class PublishingControllerProvider
    extends $AsyncNotifierProvider<PublishingController, void> {
  PublishingControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'publishingControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$publishingControllerHash();

  @$internal
  @override
  PublishingController create() => PublishingController();
}

String _$publishingControllerHash() =>
    r'2cdabb48ebf9fb63b68c73b5a1437f32f8c1bba0';

abstract class _$PublishingController extends $AsyncNotifier<void> {
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
