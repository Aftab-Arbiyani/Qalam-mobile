// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_pieces_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MyPiecesController)
final myPiecesControllerProvider = MyPiecesControllerProvider._();

final class MyPiecesControllerProvider
    extends
        $AsyncNotifierProvider<
          MyPiecesController,
          PagedListState<ProfilePiece>
        > {
  MyPiecesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myPiecesControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myPiecesControllerHash();

  @$internal
  @override
  MyPiecesController create() => MyPiecesController();
}

String _$myPiecesControllerHash() =>
    r'e61c89897906fb2ba31c8012f9243966ebb28dff';

abstract class _$MyPiecesController
    extends $AsyncNotifier<PagedListState<ProfilePiece>> {
  FutureOr<PagedListState<ProfilePiece>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PagedListState<ProfilePiece>>,
              PagedListState<ProfilePiece>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PagedListState<ProfilePiece>>,
                PagedListState<ProfilePiece>
              >,
              AsyncValue<PagedListState<ProfilePiece>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
