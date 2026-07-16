// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_results_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The grouped "All" preview for [query] (≥ min length). Errors surface as
/// `AsyncError`; the repository already falls back to a cached preview offline.

@ProviderFor(globalSearch)
final globalSearchProvider = GlobalSearchFamily._();

/// The grouped "All" preview for [query] (≥ min length). Errors surface as
/// `AsyncError`; the repository already falls back to a cached preview offline.

final class GlobalSearchProvider
    extends
        $FunctionalProvider<
          AsyncValue<GlobalSearchResult>,
          GlobalSearchResult,
          FutureOr<GlobalSearchResult>
        >
    with
        $FutureModifier<GlobalSearchResult>,
        $FutureProvider<GlobalSearchResult> {
  /// The grouped "All" preview for [query] (≥ min length). Errors surface as
  /// `AsyncError`; the repository already falls back to a cached preview offline.
  GlobalSearchProvider._({
    required GlobalSearchFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'globalSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$globalSearchHash();

  @override
  String toString() {
    return r'globalSearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<GlobalSearchResult> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<GlobalSearchResult> create(Ref ref) {
    final argument = this.argument as String;
    return globalSearch(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GlobalSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$globalSearchHash() => r'40e931480f17feaac498d61c2cd73bd98f564494';

/// The grouped "All" preview for [query] (≥ min length). Errors surface as
/// `AsyncError`; the repository already falls back to a cached preview offline.

final class GlobalSearchFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<GlobalSearchResult>, String> {
  GlobalSearchFamily._()
    : super(
        retry: null,
        name: r'globalSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The grouped "All" preview for [query] (≥ min length). Errors surface as
  /// `AsyncError`; the repository already falls back to a cached preview offline.

  GlobalSearchProvider call(String query) =>
      GlobalSearchProvider._(argument: query, from: this);

  @override
  String toString() => r'globalSearchProvider';
}

@ProviderFor(SearchResultsController)
final searchResultsControllerProvider = SearchResultsControllerFamily._();

final class SearchResultsControllerProvider
    extends
        $AsyncNotifierProvider<
          SearchResultsController,
          PagedListState<Object>
        > {
  SearchResultsControllerProvider._({
    required SearchResultsControllerFamily super.from,
    required SearchRequest super.argument,
  }) : super(
         retry: null,
         name: r'searchResultsControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchResultsControllerHash();

  @override
  String toString() {
    return r'searchResultsControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SearchResultsController create() => SearchResultsController();

  @override
  bool operator ==(Object other) {
    return other is SearchResultsControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchResultsControllerHash() =>
    r'd8748f0d05f877e5ed69f6018a93d140d500f843';

final class SearchResultsControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          SearchResultsController,
          AsyncValue<PagedListState<Object>>,
          PagedListState<Object>,
          FutureOr<PagedListState<Object>>,
          SearchRequest
        > {
  SearchResultsControllerFamily._()
    : super(
        retry: null,
        name: r'searchResultsControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SearchResultsControllerProvider call(SearchRequest request) =>
      SearchResultsControllerProvider._(argument: request, from: this);

  @override
  String toString() => r'searchResultsControllerProvider';
}

abstract class _$SearchResultsController
    extends $AsyncNotifier<PagedListState<Object>> {
  late final _$args = ref.$arg as SearchRequest;
  SearchRequest get request => _$args;

  FutureOr<PagedListState<Object>> build(SearchRequest request);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<PagedListState<Object>>, PagedListState<Object>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PagedListState<Object>>,
                PagedListState<Object>
              >,
              AsyncValue<PagedListState<Object>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
