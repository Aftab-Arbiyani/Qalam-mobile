// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'semantic_search_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RetrievalSessionController)
final retrievalSessionControllerProvider =
    RetrievalSessionControllerProvider._();

final class RetrievalSessionControllerProvider
    extends $NotifierProvider<RetrievalSessionController, RetrievalSession> {
  RetrievalSessionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'retrievalSessionControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$retrievalSessionControllerHash();

  @$internal
  @override
  RetrievalSessionController create() => RetrievalSessionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RetrievalSession value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RetrievalSession>(value),
    );
  }
}

String _$retrievalSessionControllerHash() =>
    r'3d6e207ade0f86ec928c53ec42ec9f1a2009f429';

abstract class _$RetrievalSessionController
    extends $Notifier<RetrievalSession> {
  RetrievalSession build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<RetrievalSession, RetrievalSession>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RetrievalSession, RetrievalSession>,
              RetrievalSession,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Server state: ranked, grounded, explainable results for a submitted query.

@ProviderFor(semanticSearchResults)
final semanticSearchResultsProvider = SemanticSearchResultsFamily._();

/// Server state: ranked, grounded, explainable results for a submitted query.

final class SemanticSearchResultsProvider
    extends
        $FunctionalProvider<
          AsyncValue<SemanticSearchResponse>,
          SemanticSearchResponse,
          FutureOr<SemanticSearchResponse>
        >
    with
        $FutureModifier<SemanticSearchResponse>,
        $FutureProvider<SemanticSearchResponse> {
  /// Server state: ranked, grounded, explainable results for a submitted query.
  SemanticSearchResultsProvider._({
    required SemanticSearchResultsFamily super.from,
    required SemanticSearchArgs super.argument,
  }) : super(
         retry: null,
         name: r'semanticSearchResultsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$semanticSearchResultsHash();

  @override
  String toString() {
    return r'semanticSearchResultsProvider'
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
    final argument = this.argument as SemanticSearchArgs;
    return semanticSearchResults(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SemanticSearchResultsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$semanticSearchResultsHash() =>
    r'bb83e21b0782e6cbfad7442ea0862db3dff57b6f';

/// Server state: ranked, grounded, explainable results for a submitted query.

final class SemanticSearchResultsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<SemanticSearchResponse>,
          SemanticSearchArgs
        > {
  SemanticSearchResultsFamily._()
    : super(
        retry: null,
        name: r'semanticSearchResultsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Server state: ranked, grounded, explainable results for a submitted query.

  SemanticSearchResultsProvider call(SemanticSearchArgs args) =>
      SemanticSearchResultsProvider._(argument: args, from: this);

  @override
  String toString() => r'semanticSearchResultsProvider';
}

/// Server state: debounced query suggestions (empty for short prefixes; never errors).

@ProviderFor(searchSuggestions)
final searchSuggestionsProvider = SearchSuggestionsFamily._();

/// Server state: debounced query suggestions (empty for short prefixes; never errors).

final class SearchSuggestionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// Server state: debounced query suggestions (empty for short prefixes; never errors).
  SearchSuggestionsProvider._({
    required SearchSuggestionsFamily super.from,
    required SuggestionArgs super.argument,
  }) : super(
         retry: null,
         name: r'searchSuggestionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchSuggestionsHash();

  @override
  String toString() {
    return r'searchSuggestionsProvider'
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
    return searchSuggestions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchSuggestionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchSuggestionsHash() => r'175fef5660c05caa807445a3780ef88cfac3ad5f';

/// Server state: debounced query suggestions (empty for short prefixes; never errors).

final class SearchSuggestionsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<String>>, SuggestionArgs> {
  SearchSuggestionsFamily._()
    : super(
        retry: null,
        name: r'searchSuggestionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Server state: debounced query suggestions (empty for short prefixes; never errors).

  SearchSuggestionsProvider call(SuggestionArgs args) =>
      SearchSuggestionsProvider._(argument: args, from: this);

  @override
  String toString() => r'searchSuggestionsProvider';
}
