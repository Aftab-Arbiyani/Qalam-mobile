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
