// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'retrieval_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(retrievalRemoteDataSource)
final retrievalRemoteDataSourceProvider = RetrievalRemoteDataSourceProvider._();

final class RetrievalRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          RetrievalRemoteDataSource,
          RetrievalRemoteDataSource,
          RetrievalRemoteDataSource
        >
    with $Provider<RetrievalRemoteDataSource> {
  RetrievalRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'retrievalRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$retrievalRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<RetrievalRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RetrievalRemoteDataSource create(Ref ref) {
    return retrievalRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RetrievalRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RetrievalRemoteDataSource>(value),
    );
  }
}

String _$retrievalRemoteDataSourceHash() =>
    r'318954f4c174ed9d0af97ebd5ce3a357f605cad0';

@ProviderFor(retrievalRepository)
final retrievalRepositoryProvider = RetrievalRepositoryProvider._();

final class RetrievalRepositoryProvider
    extends
        $FunctionalProvider<
          RetrievalRepository,
          RetrievalRepository,
          RetrievalRepository
        >
    with $Provider<RetrievalRepository> {
  RetrievalRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'retrievalRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$retrievalRepositoryHash();

  @$internal
  @override
  $ProviderElement<RetrievalRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RetrievalRepository create(Ref ref) {
    return retrievalRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RetrievalRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RetrievalRepository>(value),
    );
  }
}

String _$retrievalRepositoryHash() =>
    r'c310cc681f547167a6e6cd13ec40920493988ab1';

/// Device-local mirror of the caller's saved searches.

@ProviderFor(savedSearchesStore)
final savedSearchesStoreProvider = SavedSearchesStoreProvider._();

/// Device-local mirror of the caller's saved searches.

final class SavedSearchesStoreProvider
    extends
        $FunctionalProvider<
          SavedSearchesStore,
          SavedSearchesStore,
          SavedSearchesStore
        >
    with $Provider<SavedSearchesStore> {
  /// Device-local mirror of the caller's saved searches.
  SavedSearchesStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedSearchesStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedSearchesStoreHash();

  @$internal
  @override
  $ProviderElement<SavedSearchesStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SavedSearchesStore create(Ref ref) {
    return savedSearchesStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SavedSearchesStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SavedSearchesStore>(value),
    );
  }
}

String _$savedSearchesStoreHash() =>
    r'7e7b7f91f79cca8b2031b5dc8b4e5df1017ef781';

/// Ranked, grounded, explainable results for a submitted query. **Public.**

@ProviderFor(retrievalResults)
final retrievalResultsProvider = RetrievalResultsFamily._();

/// Ranked, grounded, explainable results for a submitted query. **Public.**

final class RetrievalResultsProvider
    extends
        $FunctionalProvider<
          AsyncValue<SemanticSearchResponse>,
          SemanticSearchResponse,
          FutureOr<SemanticSearchResponse>
        >
    with
        $FutureModifier<SemanticSearchResponse>,
        $FutureProvider<SemanticSearchResponse> {
  /// Ranked, grounded, explainable results for a submitted query. **Public.**
  RetrievalResultsProvider._({
    required RetrievalResultsFamily super.from,
    required RetrievalArgs super.argument,
  }) : super(
         retry: null,
         name: r'retrievalResultsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$retrievalResultsHash();

  @override
  String toString() {
    return r'retrievalResultsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SemanticSearchResponse> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SemanticSearchResponse> create(Ref ref) {
    final argument = this.argument as RetrievalArgs;
    return retrievalResults(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RetrievalResultsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$retrievalResultsHash() => r'f6741a0618c86b50e64a7699ade5c57c5c708b92';

/// Ranked, grounded, explainable results for a submitted query. **Public.**

final class RetrievalResultsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<SemanticSearchResponse>,
          RetrievalArgs
        > {
  RetrievalResultsFamily._()
    : super(
        retry: null,
        name: r'retrievalResultsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Ranked, grounded, explainable results for a submitted query. **Public.**

  RetrievalResultsProvider call(RetrievalArgs args) =>
      RetrievalResultsProvider._(argument: args, from: this);

  @override
  String toString() => r'retrievalResultsProvider';
}

/// Query suggestions. **Public**, empty for short prefixes, and never throws — a
/// suggestion strip that errors is worse than one that is absent.

@ProviderFor(retrievalSuggestions)
final retrievalSuggestionsProvider = RetrievalSuggestionsFamily._();

/// Query suggestions. **Public**, empty for short prefixes, and never throws — a
/// suggestion strip that errors is worse than one that is absent.

final class RetrievalSuggestionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// Query suggestions. **Public**, empty for short prefixes, and never throws — a
  /// suggestion strip that errors is worse than one that is absent.
  RetrievalSuggestionsProvider._({
    required RetrievalSuggestionsFamily super.from,
    required SuggestionArgs super.argument,
  }) : super(
         retry: null,
         name: r'retrievalSuggestionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$retrievalSuggestionsHash();

  @override
  String toString() {
    return r'retrievalSuggestionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    final argument = this.argument as SuggestionArgs;
    return retrievalSuggestions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RetrievalSuggestionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$retrievalSuggestionsHash() =>
    r'126e103526f92a776de047e2d3f7697bd56e885f';

/// Query suggestions. **Public**, empty for short prefixes, and never throws — a
/// suggestion strip that errors is worse than one that is absent.

final class RetrievalSuggestionsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<String>>, SuggestionArgs> {
  RetrievalSuggestionsFamily._()
    : super(
        retry: null,
        name: r'retrievalSuggestionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Query suggestions. **Public**, empty for short prefixes, and never throws — a
  /// suggestion strip that errors is worse than one that is absent.

  RetrievalSuggestionsProvider call(SuggestionArgs args) =>
      RetrievalSuggestionsProvider._(argument: args, from: this);

  @override
  String toString() => r'retrievalSuggestionsProvider';
}

/// Explainable recommendations for a surface. **Authenticated** — see the library note.

@ProviderFor(recommendations)
final recommendationsProvider = RecommendationsFamily._();

/// Explainable recommendations for a surface. **Authenticated** — see the library note.

final class RecommendationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<RecommendationResponse>,
          RecommendationResponse,
          FutureOr<RecommendationResponse>
        >
    with
        $FutureModifier<RecommendationResponse>,
        $FutureProvider<RecommendationResponse> {
  /// Explainable recommendations for a surface. **Authenticated** — see the library note.
  RecommendationsProvider._({
    required RecommendationsFamily super.from,
    required RecommendationArgs super.argument,
  }) : super(
         retry: null,
         name: r'recommendationsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recommendationsHash();

  @override
  String toString() {
    return r'recommendationsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<RecommendationResponse> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RecommendationResponse> create(Ref ref) {
    final argument = this.argument as RecommendationArgs;
    return recommendations(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RecommendationsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recommendationsHash() => r'cd6e315367f471c0b5d590dfe1aa8560531a9bf3';

/// Explainable recommendations for a surface. **Authenticated** — see the library note.

final class RecommendationsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<RecommendationResponse>,
          RecommendationArgs
        > {
  RecommendationsFamily._()
    : super(
        retry: null,
        name: r'recommendationsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Explainable recommendations for a surface. **Authenticated** — see the library note.

  RecommendationsProvider call(RecommendationArgs args) =>
      RecommendationsProvider._(argument: args, from: this);

  @override
  String toString() => r'recommendationsProvider';
}
