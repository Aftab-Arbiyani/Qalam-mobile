// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(searchRemoteDataSource)
final searchRemoteDataSourceProvider = SearchRemoteDataSourceProvider._();

final class SearchRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          SearchRemoteDataSource,
          SearchRemoteDataSource,
          SearchRemoteDataSource
        >
    with $Provider<SearchRemoteDataSource> {
  SearchRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<SearchRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SearchRemoteDataSource create(Ref ref) {
    return searchRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchRemoteDataSource>(value),
    );
  }
}

String _$searchRemoteDataSourceHash() =>
    r'6b3cdadd1cc83ce1613692daa3167016a7b9bce6';

@ProviderFor(searchRecentsStore)
final searchRecentsStoreProvider = SearchRecentsStoreProvider._();

final class SearchRecentsStoreProvider
    extends
        $FunctionalProvider<
          SearchRecentsStore,
          SearchRecentsStore,
          SearchRecentsStore
        >
    with $Provider<SearchRecentsStore> {
  SearchRecentsStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchRecentsStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchRecentsStoreHash();

  @$internal
  @override
  $ProviderElement<SearchRecentsStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SearchRecentsStore create(Ref ref) {
    return searchRecentsStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchRecentsStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchRecentsStore>(value),
    );
  }
}

String _$searchRecentsStoreHash() =>
    r'7e3d169cc91a0f1efda5678aa0e346602d8d0111';

@ProviderFor(searchRepository)
final searchRepositoryProvider = SearchRepositoryProvider._();

final class SearchRepositoryProvider
    extends
        $FunctionalProvider<
          SearchRepository,
          SearchRepository,
          SearchRepository
        >
    with $Provider<SearchRepository> {
  SearchRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchRepositoryHash();

  @$internal
  @override
  $ProviderElement<SearchRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SearchRepository create(Ref ref) {
    return searchRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchRepository>(value),
    );
  }
}

String _$searchRepositoryHash() => r'ebe70c046cb475cf85fdc32d20f2429c82b36611';
