// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'related_pieces_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(relatedPieces)
final relatedPiecesProvider = RelatedPiecesFamily._();

final class RelatedPiecesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PieceSummary>>,
          List<PieceSummary>,
          FutureOr<List<PieceSummary>>
        >
    with
        $FutureModifier<List<PieceSummary>>,
        $FutureProvider<List<PieceSummary>> {
  RelatedPiecesProvider._({
    required RelatedPiecesFamily super.from,
    required RelatedPiecesArgs super.argument,
  }) : super(
         retry: null,
         name: r'relatedPiecesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$relatedPiecesHash();

  @override
  String toString() {
    return r'relatedPiecesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PieceSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PieceSummary>> create(Ref ref) {
    final argument = this.argument as RelatedPiecesArgs;
    return relatedPieces(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RelatedPiecesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$relatedPiecesHash() => r'5f235c959f37e70e20ba4474896f1f632aa20682';

final class RelatedPiecesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<PieceSummary>>,
          RelatedPiecesArgs
        > {
  RelatedPiecesFamily._()
    : super(
        retry: null,
        name: r'relatedPiecesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RelatedPiecesProvider call(RelatedPiecesArgs args) =>
      RelatedPiecesProvider._(argument: args, from: this);

  @override
  String toString() => r'relatedPiecesProvider';
}
