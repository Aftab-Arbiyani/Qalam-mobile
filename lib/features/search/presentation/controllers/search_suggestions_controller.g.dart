// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_suggestions_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(autocomplete)
final autocompleteProvider = AutocompleteProvider._();

final class AutocompleteProvider
    extends
        $FunctionalProvider<
          AsyncValue<AutocompleteResult>,
          AutocompleteResult,
          FutureOr<AutocompleteResult>
        >
    with
        $FutureModifier<AutocompleteResult>,
        $FutureProvider<AutocompleteResult> {
  AutocompleteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'autocompleteProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$autocompleteHash();

  @$internal
  @override
  $FutureProviderElement<AutocompleteResult> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AutocompleteResult> create(Ref ref) {
    return autocomplete(ref);
  }
}

String _$autocompleteHash() => r'f45d3ca85c09fe0804e317008fd36c5b55ff6230';

@ProviderFor(trendingSearches)
final trendingSearchesProvider = TrendingSearchesProvider._();

final class TrendingSearchesProvider
    extends
        $FunctionalProvider<
          AsyncValue<TrendingSearches>,
          TrendingSearches,
          FutureOr<TrendingSearches>
        >
    with $FutureModifier<TrendingSearches>, $FutureProvider<TrendingSearches> {
  TrendingSearchesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trendingSearchesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trendingSearchesHash();

  @$internal
  @override
  $FutureProviderElement<TrendingSearches> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TrendingSearches> create(Ref ref) {
    return trendingSearches(ref);
  }
}

String _$trendingSearchesHash() => r'0dedb0d7016e7564370c3d2999979366127e5baf';
