// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'related_pieces_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(relatedSuggestions)
final relatedSuggestionsProvider = RelatedSuggestionsFamily._();

final class RelatedSuggestionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RelatedSuggestion>>,
          AsyncValue<List<RelatedSuggestion>>,
          AsyncValue<List<RelatedSuggestion>>
        >
    with $Provider<AsyncValue<List<RelatedSuggestion>>> {
  RelatedSuggestionsProvider._({
    required RelatedSuggestionsFamily super.from,
    required RelatedSuggestionsArgs super.argument,
  }) : super(
         retry: null,
         name: r'relatedSuggestionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$relatedSuggestionsHash();

  @override
  String toString() {
    return r'relatedSuggestionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<List<RelatedSuggestion>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<RelatedSuggestion>> create(Ref ref) {
    final argument = this.argument as RelatedSuggestionsArgs;
    return relatedSuggestions(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<RelatedSuggestion>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<RelatedSuggestion>>>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RelatedSuggestionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$relatedSuggestionsHash() =>
    r'eaeceeda41600832985ce50a54e52e17cf12534c';

final class RelatedSuggestionsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          AsyncValue<List<RelatedSuggestion>>,
          RelatedSuggestionsArgs
        > {
  RelatedSuggestionsFamily._()
    : super(
        retry: null,
        name: r'relatedSuggestionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RelatedSuggestionsProvider call(RelatedSuggestionsArgs args) =>
      RelatedSuggestionsProvider._(argument: args, from: this);

  @override
  String toString() => r'relatedSuggestionsProvider';
}

/// The tag search itself — a self-contained `Future` provider with exactly one
/// upstream dependency ([readingRepositoryProvider]). It never rejects (a failed
/// [Result] resolves to an empty list rather than throwing), so it never enters
/// the retrying-`AsyncLoading` state [_stillPending] has to account for.

@ProviderFor(_tagSearch)
final _tagSearchProvider = _TagSearchFamily._();

/// The tag search itself — a self-contained `Future` provider with exactly one
/// upstream dependency ([readingRepositoryProvider]). It never rejects (a failed
/// [Result] resolves to an empty list rather than throwing), so it never enters
/// the retrying-`AsyncLoading` state [_stillPending] has to account for.

final class _TagSearchProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RelatedSuggestion>>,
          List<RelatedSuggestion>,
          FutureOr<List<RelatedSuggestion>>
        >
    with
        $FutureModifier<List<RelatedSuggestion>>,
        $FutureProvider<List<RelatedSuggestion>> {
  /// The tag search itself — a self-contained `Future` provider with exactly one
  /// upstream dependency ([readingRepositoryProvider]). It never rejects (a failed
  /// [Result] resolves to an empty list rather than throwing), so it never enters
  /// the retrying-`AsyncLoading` state [_stillPending] has to account for.
  _TagSearchProvider._({
    required _TagSearchFamily super.from,
    required _TagSearchArgs super.argument,
  }) : super(
         retry: null,
         name: r'_tagSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$_tagSearchHash();

  @override
  String toString() {
    return r'_tagSearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<RelatedSuggestion>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<RelatedSuggestion>> create(Ref ref) {
    final argument = this.argument as _TagSearchArgs;
    return _tagSearch(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is _TagSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$_tagSearchHash() => r'08f38f2454baaa24c234a203aaf788980797fdfd';

/// The tag search itself — a self-contained `Future` provider with exactly one
/// upstream dependency ([readingRepositoryProvider]). It never rejects (a failed
/// [Result] resolves to an empty list rather than throwing), so it never enters
/// the retrying-`AsyncLoading` state [_stillPending] has to account for.

final class _TagSearchFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<RelatedSuggestion>>,
          _TagSearchArgs
        > {
  _TagSearchFamily._()
    : super(
        retry: null,
        name: r'_tagSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The tag search itself — a self-contained `Future` provider with exactly one
  /// upstream dependency ([readingRepositoryProvider]). It never rejects (a failed
  /// [Result] resolves to an empty list rather than throwing), so it never enters
  /// the retrying-`AsyncLoading` state [_stillPending] has to account for.

  _TagSearchProvider call(_TagSearchArgs args) =>
      _TagSearchProvider._(argument: args, from: this);

  @override
  String toString() => r'_tagSearchProvider';
}
