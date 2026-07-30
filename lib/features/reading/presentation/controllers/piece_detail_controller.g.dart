// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'piece_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PieceDetailController)
final pieceDetailControllerProvider = PieceDetailControllerFamily._();

final class PieceDetailControllerProvider
    extends $AsyncNotifierProvider<PieceDetailController, CachedDetail> {
  PieceDetailControllerProvider._({
    required PieceDetailControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'pieceDetailControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pieceDetailControllerHash();

  @override
  String toString() {
    return r'pieceDetailControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PieceDetailController create() => PieceDetailController();

  @override
  bool operator ==(Object other) {
    return other is PieceDetailControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pieceDetailControllerHash() =>
    r'e0965bb861acfee3b265ce0b4a282800abafd310';

final class PieceDetailControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          PieceDetailController,
          AsyncValue<CachedDetail>,
          CachedDetail,
          FutureOr<CachedDetail>,
          String
        > {
  PieceDetailControllerFamily._()
    : super(
        retry: null,
        name: r'pieceDetailControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PieceDetailControllerProvider call(String pieceId) =>
      PieceDetailControllerProvider._(argument: pieceId, from: this);

  @override
  String toString() => r'pieceDetailControllerProvider';
}

abstract class _$PieceDetailController extends $AsyncNotifier<CachedDetail> {
  late final _$args = ref.$arg as String;
  String get pieceId => _$args;

  FutureOr<CachedDetail> build(String pieceId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<CachedDetail>, CachedDetail>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CachedDetail>, CachedDetail>,
              AsyncValue<CachedDetail>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
