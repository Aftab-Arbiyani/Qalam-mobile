// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(aiRemoteDataSource)
final aiRemoteDataSourceProvider = AiRemoteDataSourceProvider._();

final class AiRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          AiRemoteDataSource,
          AiRemoteDataSource,
          AiRemoteDataSource
        >
    with $Provider<AiRemoteDataSource> {
  AiRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<AiRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AiRemoteDataSource create(Ref ref) {
    return aiRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AiRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AiRemoteDataSource>(value),
    );
  }
}

String _$aiRemoteDataSourceHash() =>
    r'976180fed2ef92e2a04de1c6deef75108cb2a600';

@ProviderFor(aiRepository)
final aiRepositoryProvider = AiRepositoryProvider._();

final class AiRepositoryProvider
    extends $FunctionalProvider<AiRepository, AiRepository, AiRepository>
    with $Provider<AiRepository> {
  AiRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiRepositoryHash();

  @$internal
  @override
  $ProviderElement<AiRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AiRepository create(Ref ref) {
    return aiRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AiRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AiRepository>(value),
    );
  }
}

String _$aiRepositoryHash() => r'd4493bbed813189b507a2199e502f4fbb589194a';

/// The on-device Prompt Library store (favourites / custom presets / history).

@ProviderFor(promptLibraryStore)
final promptLibraryStoreProvider = PromptLibraryStoreProvider._();

/// The on-device Prompt Library store (favourites / custom presets / history).

final class PromptLibraryStoreProvider
    extends
        $FunctionalProvider<
          PromptLibraryStore,
          PromptLibraryStore,
          PromptLibraryStore
        >
    with $Provider<PromptLibraryStore> {
  /// The on-device Prompt Library store (favourites / custom presets / history).
  PromptLibraryStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'promptLibraryStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$promptLibraryStoreHash();

  @$internal
  @override
  $ProviderElement<PromptLibraryStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PromptLibraryStore create(Ref ref) {
    return promptLibraryStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PromptLibraryStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PromptLibraryStore>(value),
    );
  }
}

String _$promptLibraryStoreHash() =>
    r'606641f2e0da266e9f49f7b04852effd92d602df';

/// The caller's AI feature-flag state (server source of truth for gating).

@ProviderFor(aiFeatures)
final aiFeaturesProvider = AiFeaturesProvider._();

/// The caller's AI feature-flag state (server source of truth for gating).

final class AiFeaturesProvider
    extends
        $FunctionalProvider<
          AsyncValue<AiFeatures>,
          AiFeatures,
          FutureOr<AiFeatures>
        >
    with $FutureModifier<AiFeatures>, $FutureProvider<AiFeatures> {
  /// The caller's AI feature-flag state (server source of truth for gating).
  AiFeaturesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiFeaturesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiFeaturesHash();

  @$internal
  @override
  $FutureProviderElement<AiFeatures> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<AiFeatures> create(Ref ref) {
    return aiFeatures(ref);
  }
}

String _$aiFeaturesHash() => r'4856f1cb3e19e9fae3b09097b122f4fa40fc2464';

/// The caller's AI usage (daily/monthly/lifetime + per feature) for the token meter.

@ProviderFor(aiUsage)
final aiUsageProvider = AiUsageProvider._();

/// The caller's AI usage (daily/monthly/lifetime + per feature) for the token meter.

final class AiUsageProvider
    extends
        $FunctionalProvider<
          AsyncValue<AiUsageSummary>,
          AiUsageSummary,
          FutureOr<AiUsageSummary>
        >
    with $FutureModifier<AiUsageSummary>, $FutureProvider<AiUsageSummary> {
  /// The caller's AI usage (daily/monthly/lifetime + per feature) for the token meter.
  AiUsageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiUsageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiUsageHash();

  @$internal
  @override
  $FutureProviderElement<AiUsageSummary> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AiUsageSummary> create(Ref ref) {
    return aiUsage(ref);
  }
}

String _$aiUsageHash() => r'b30333a3d4a9b4e4e6a05e158ee780cd2b191561';
