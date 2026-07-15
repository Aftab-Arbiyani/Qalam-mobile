// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discovery_controllers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(discoverPiecesShelf)
final discoverPiecesShelfProvider = DiscoverPiecesShelfFamily._();

final class DiscoverPiecesShelfProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PieceSummary>>,
          List<PieceSummary>,
          FutureOr<List<PieceSummary>>
        >
    with
        $FutureModifier<List<PieceSummary>>,
        $FutureProvider<List<PieceSummary>> {
  DiscoverPiecesShelfProvider._({
    required DiscoverPiecesShelfFamily super.from,
    required DiscoverPieceKind super.argument,
  }) : super(
         retry: null,
         name: r'discoverPiecesShelfProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$discoverPiecesShelfHash();

  @override
  String toString() {
    return r'discoverPiecesShelfProvider'
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
    final argument = this.argument as DiscoverPieceKind;
    return discoverPiecesShelf(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DiscoverPiecesShelfProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$discoverPiecesShelfHash() =>
    r'0159a04cf9ef7cc97a7c87b580fbfede7bbda514';

final class DiscoverPiecesShelfFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<PieceSummary>>,
          DiscoverPieceKind
        > {
  DiscoverPiecesShelfFamily._()
    : super(
        retry: null,
        name: r'discoverPiecesShelfProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DiscoverPiecesShelfProvider call(DiscoverPieceKind kind) =>
      DiscoverPiecesShelfProvider._(argument: kind, from: this);

  @override
  String toString() => r'discoverPiecesShelfProvider';
}

@ProviderFor(discoverWritersShelf)
final discoverWritersShelfProvider = DiscoverWritersShelfFamily._();

final class DiscoverWritersShelfProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WriterSummary>>,
          List<WriterSummary>,
          FutureOr<List<WriterSummary>>
        >
    with
        $FutureModifier<List<WriterSummary>>,
        $FutureProvider<List<WriterSummary>> {
  DiscoverWritersShelfProvider._({
    required DiscoverWritersShelfFamily super.from,
    required WriterKind super.argument,
  }) : super(
         retry: null,
         name: r'discoverWritersShelfProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$discoverWritersShelfHash();

  @override
  String toString() {
    return r'discoverWritersShelfProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<WriterSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WriterSummary>> create(Ref ref) {
    final argument = this.argument as WriterKind;
    return discoverWritersShelf(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DiscoverWritersShelfProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$discoverWritersShelfHash() =>
    r'fa7138640734e427d91aaec39b239185fc37233e';

final class DiscoverWritersShelfFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<WriterSummary>>, WriterKind> {
  DiscoverWritersShelfFamily._()
    : super(
        retry: null,
        name: r'discoverWritersShelfProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DiscoverWritersShelfProvider call(WriterKind kind) =>
      DiscoverWritersShelfProvider._(argument: kind, from: this);

  @override
  String toString() => r'discoverWritersShelfProvider';
}

@ProviderFor(trendingTagsShelf)
final trendingTagsShelfProvider = TrendingTagsShelfProvider._();

final class TrendingTagsShelfProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TrendingTag>>,
          List<TrendingTag>,
          FutureOr<List<TrendingTag>>
        >
    with
        $FutureModifier<List<TrendingTag>>,
        $FutureProvider<List<TrendingTag>> {
  TrendingTagsShelfProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trendingTagsShelfProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trendingTagsShelfHash();

  @$internal
  @override
  $FutureProviderElement<List<TrendingTag>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TrendingTag>> create(Ref ref) {
    return trendingTagsShelf(ref);
  }
}

String _$trendingTagsShelfHash() => r'd0df344dbcfa57ce7eed29ce3736d463b2d0fa25';
