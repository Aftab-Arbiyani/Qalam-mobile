// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collaboration_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CollaborationController)
final collaborationControllerProvider = CollaborationControllerProvider._();

final class CollaborationControllerProvider
    extends $AsyncNotifierProvider<CollaborationController, void> {
  CollaborationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'collaborationControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$collaborationControllerHash();

  @$internal
  @override
  CollaborationController create() => CollaborationController();
}

String _$collaborationControllerHash() =>
    r'155fe57a32e2fa5af86616bc6fcece67a8b2d61d';

abstract class _$CollaborationController extends $AsyncNotifier<void> {
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
