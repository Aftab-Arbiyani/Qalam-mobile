// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discovery_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(discoveryRemoteDataSource)
final discoveryRemoteDataSourceProvider = DiscoveryRemoteDataSourceProvider._();

final class DiscoveryRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          DiscoveryRemoteDataSource,
          DiscoveryRemoteDataSource,
          DiscoveryRemoteDataSource
        >
    with $Provider<DiscoveryRemoteDataSource> {
  DiscoveryRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'discoveryRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$discoveryRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<DiscoveryRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DiscoveryRemoteDataSource create(Ref ref) {
    return discoveryRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DiscoveryRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DiscoveryRemoteDataSource>(value),
    );
  }
}

String _$discoveryRemoteDataSourceHash() =>
    r'bf9a83aa1db16acb7b6cc643deaae0f532c38257';

@ProviderFor(discoveryRepository)
final discoveryRepositoryProvider = DiscoveryRepositoryProvider._();

final class DiscoveryRepositoryProvider
    extends
        $FunctionalProvider<
          DiscoveryRepository,
          DiscoveryRepository,
          DiscoveryRepository
        >
    with $Provider<DiscoveryRepository> {
  DiscoveryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'discoveryRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$discoveryRepositoryHash();

  @$internal
  @override
  $ProviderElement<DiscoveryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DiscoveryRepository create(Ref ref) {
    return discoveryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DiscoveryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DiscoveryRepository>(value),
    );
  }
}

String _$discoveryRepositoryHash() =>
    r'8fc3e627b47b9b3f0706ba5015a4d2c271f8ad98';

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
    r'fb7f7481fbe691b3b3b1cf781ba55fdb6b93bb0d';

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
    r'b6cc61dace33c4aa526c840ac418d816bcf2f22c';

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

String _$trendingTagsShelfHash() => r'0180bd32c07fe1773d1696ce8c4374fcf2e34cfd';

@ProviderFor(trendingGenresShelf)
final trendingGenresShelfProvider = TrendingGenresShelfProvider._();

final class TrendingGenresShelfProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TrendingGenre>>,
          List<TrendingGenre>,
          FutureOr<List<TrendingGenre>>
        >
    with
        $FutureModifier<List<TrendingGenre>>,
        $FutureProvider<List<TrendingGenre>> {
  TrendingGenresShelfProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trendingGenresShelfProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trendingGenresShelfHash();

  @$internal
  @override
  $FutureProviderElement<List<TrendingGenre>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TrendingGenre>> create(Ref ref) {
    return trendingGenresShelf(ref);
  }
}

String _$trendingGenresShelfHash() =>
    r'52128c1eefc2315388f2508032870998dcc0bbde';

@ProviderFor(trendingLanguagesShelf)
final trendingLanguagesShelfProvider = TrendingLanguagesShelfProvider._();

final class TrendingLanguagesShelfProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TrendingLanguage>>,
          List<TrendingLanguage>,
          FutureOr<List<TrendingLanguage>>
        >
    with
        $FutureModifier<List<TrendingLanguage>>,
        $FutureProvider<List<TrendingLanguage>> {
  TrendingLanguagesShelfProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trendingLanguagesShelfProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trendingLanguagesShelfHash();

  @$internal
  @override
  $FutureProviderElement<List<TrendingLanguage>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TrendingLanguage>> create(Ref ref) {
    return trendingLanguagesShelf(ref);
  }
}

String _$trendingLanguagesShelfHash() =>
    r'2a6cf7cc36b1f4bd102e1c7641027d0186c2c172';
