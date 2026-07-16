// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collections_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CollectionsController)
final collectionsControllerProvider = CollectionsControllerProvider._();

final class CollectionsControllerProvider
    extends
        $AsyncNotifierProvider<
          CollectionsController,
          PagedListState<Collection>
        > {
  CollectionsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'collectionsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$collectionsControllerHash();

  @$internal
  @override
  CollectionsController create() => CollectionsController();
}

String _$collectionsControllerHash() =>
    r'd9b81cbf3f96887751a926ebaadbd89e0539171b';

abstract class _$CollectionsController
    extends $AsyncNotifier<PagedListState<Collection>> {
  FutureOr<PagedListState<Collection>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PagedListState<Collection>>,
              PagedListState<Collection>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PagedListState<Collection>>,
                PagedListState<Collection>
              >,
              AsyncValue<PagedListState<Collection>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(CollectionPiecesController)
final collectionPiecesControllerProvider = CollectionPiecesControllerFamily._();

final class CollectionPiecesControllerProvider
    extends
        $AsyncNotifierProvider<
          CollectionPiecesController,
          PagedListState<CollectionPieceItem>
        > {
  CollectionPiecesControllerProvider._({
    required CollectionPiecesControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'collectionPiecesControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$collectionPiecesControllerHash();

  @override
  String toString() {
    return r'collectionPiecesControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CollectionPiecesController create() => CollectionPiecesController();

  @override
  bool operator ==(Object other) {
    return other is CollectionPiecesControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$collectionPiecesControllerHash() =>
    r'ddb89f3f7973ffedb226450785400c4cb43b9c73';

final class CollectionPiecesControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          CollectionPiecesController,
          AsyncValue<PagedListState<CollectionPieceItem>>,
          PagedListState<CollectionPieceItem>,
          FutureOr<PagedListState<CollectionPieceItem>>,
          String
        > {
  CollectionPiecesControllerFamily._()
    : super(
        retry: null,
        name: r'collectionPiecesControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CollectionPiecesControllerProvider call(String collectionId) =>
      CollectionPiecesControllerProvider._(argument: collectionId, from: this);

  @override
  String toString() => r'collectionPiecesControllerProvider';
}

abstract class _$CollectionPiecesController
    extends $AsyncNotifier<PagedListState<CollectionPieceItem>> {
  late final _$args = ref.$arg as String;
  String get collectionId => _$args;

  FutureOr<PagedListState<CollectionPieceItem>> build(String collectionId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PagedListState<CollectionPieceItem>>,
              PagedListState<CollectionPieceItem>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PagedListState<CollectionPieceItem>>,
                PagedListState<CollectionPieceItem>
              >,
              AsyncValue<PagedListState<CollectionPieceItem>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
