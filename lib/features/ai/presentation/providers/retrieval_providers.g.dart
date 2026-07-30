// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'retrieval_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Device-local recent AI-search queries (survives cache-clear + logout).

@ProviderFor(aiSearchHistoryStore)
final aiSearchHistoryStoreProvider = AiSearchHistoryStoreProvider._();

/// Device-local recent AI-search queries (survives cache-clear + logout).

final class AiSearchHistoryStoreProvider
    extends
        $FunctionalProvider<
          AiSearchHistoryStore,
          AiSearchHistoryStore,
          AiSearchHistoryStore
        >
    with $Provider<AiSearchHistoryStore> {
  /// Device-local recent AI-search queries (survives cache-clear + logout).
  AiSearchHistoryStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiSearchHistoryStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiSearchHistoryStoreHash();

  @$internal
  @override
  $ProviderElement<AiSearchHistoryStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AiSearchHistoryStore create(Ref ref) {
    return aiSearchHistoryStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AiSearchHistoryStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AiSearchHistoryStore>(value),
    );
  }
}

String _$aiSearchHistoryStoreHash() =>
    r'd6aa9f1f3f9d9bf4844bab5118cd9367736f5340';

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

/// Disposable last-viewed explorer cache (instant / offline render).

@ProviderFor(explorerCacheStore)
final explorerCacheStoreProvider = ExplorerCacheStoreProvider._();

/// Disposable last-viewed explorer cache (instant / offline render).

final class ExplorerCacheStoreProvider
    extends
        $FunctionalProvider<
          ExplorerCacheStore,
          ExplorerCacheStore,
          ExplorerCacheStore
        >
    with $Provider<ExplorerCacheStore> {
  /// Disposable last-viewed explorer cache (instant / offline render).
  ExplorerCacheStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'explorerCacheStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$explorerCacheStoreHash();

  @$internal
  @override
  $ProviderElement<ExplorerCacheStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ExplorerCacheStore create(Ref ref) {
    return explorerCacheStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExplorerCacheStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExplorerCacheStore>(value),
    );
  }
}

String _$explorerCacheStoreHash() =>
    r'611e0c64141ad09b1e2bd803a7300cfb199dd7d9';
