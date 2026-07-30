// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'taxonomy_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(taxonomyRemoteDataSource)
final taxonomyRemoteDataSourceProvider = TaxonomyRemoteDataSourceProvider._();

final class TaxonomyRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          TaxonomyRemoteDataSource,
          TaxonomyRemoteDataSource,
          TaxonomyRemoteDataSource
        >
    with $Provider<TaxonomyRemoteDataSource> {
  TaxonomyRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taxonomyRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taxonomyRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<TaxonomyRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TaxonomyRemoteDataSource create(Ref ref) {
    return taxonomyRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaxonomyRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TaxonomyRemoteDataSource>(value),
    );
  }
}

String _$taxonomyRemoteDataSourceHash() =>
    r'38fcc02ff136672e824580ba5a57013b5dfe2fba';

@ProviderFor(taxonomyRepository)
final taxonomyRepositoryProvider = TaxonomyRepositoryProvider._();

final class TaxonomyRepositoryProvider
    extends
        $FunctionalProvider<
          TaxonomyRepository,
          TaxonomyRepository,
          TaxonomyRepository
        >
    with $Provider<TaxonomyRepository> {
  TaxonomyRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taxonomyRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taxonomyRepositoryHash();

  @$internal
  @override
  $ProviderElement<TaxonomyRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TaxonomyRepository create(Ref ref) {
    return taxonomyRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaxonomyRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TaxonomyRepository>(value),
    );
  }
}

String _$taxonomyRepositoryHash() =>
    r'991c71aa07390f6fe05edcaf3d2fab993e42337d';

@ProviderFor(taxonomyLanguages)
final taxonomyLanguagesProvider = TaxonomyLanguagesProvider._();

final class TaxonomyLanguagesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LanguageRef>>,
          List<LanguageRef>,
          FutureOr<List<LanguageRef>>
        >
    with
        $FutureModifier<List<LanguageRef>>,
        $FutureProvider<List<LanguageRef>> {
  TaxonomyLanguagesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taxonomyLanguagesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taxonomyLanguagesHash();

  @$internal
  @override
  $FutureProviderElement<List<LanguageRef>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<LanguageRef>> create(Ref ref) {
    return taxonomyLanguages(ref);
  }
}

String _$taxonomyLanguagesHash() => r'49e26e44dbc0f6b9b1bfe5284241731b7ca56aa1';

@ProviderFor(taxonomyGenres)
final taxonomyGenresProvider = TaxonomyGenresProvider._();

final class TaxonomyGenresProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GenreRef>>,
          List<GenreRef>,
          FutureOr<List<GenreRef>>
        >
    with $FutureModifier<List<GenreRef>>, $FutureProvider<List<GenreRef>> {
  TaxonomyGenresProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taxonomyGenresProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taxonomyGenresHash();

  @$internal
  @override
  $FutureProviderElement<List<GenreRef>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<GenreRef>> create(Ref ref) {
    return taxonomyGenres(ref);
  }
}

String _$taxonomyGenresHash() => r'379270a3e319322de36f8a19235853219bf1c6ba';
