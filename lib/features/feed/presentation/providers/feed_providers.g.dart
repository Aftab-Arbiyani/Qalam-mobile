// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(feedRemoteDataSource)
final feedRemoteDataSourceProvider = FeedRemoteDataSourceProvider._();

final class FeedRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          FeedRemoteDataSource,
          FeedRemoteDataSource,
          FeedRemoteDataSource
        >
    with $Provider<FeedRemoteDataSource> {
  FeedRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<FeedRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FeedRemoteDataSource create(Ref ref) {
    return feedRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeedRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeedRemoteDataSource>(value),
    );
  }
}

String _$feedRemoteDataSourceHash() =>
    r'057d8949e3fc995f2721e237e40a0dc4e1d8ee29';

@ProviderFor(feedLocalDataSource)
final feedLocalDataSourceProvider = FeedLocalDataSourceProvider._();

final class FeedLocalDataSourceProvider
    extends
        $FunctionalProvider<
          FeedLocalDataSource,
          FeedLocalDataSource,
          FeedLocalDataSource
        >
    with $Provider<FeedLocalDataSource> {
  FeedLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedLocalDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<FeedLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FeedLocalDataSource create(Ref ref) {
    return feedLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeedLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeedLocalDataSource>(value),
    );
  }
}

String _$feedLocalDataSourceHash() =>
    r'882be55ec30f07a193b90c071350d035e67e9959';

@ProviderFor(feedRepository)
final feedRepositoryProvider = FeedRepositoryProvider._();

final class FeedRepositoryProvider
    extends $FunctionalProvider<FeedRepository, FeedRepository, FeedRepository>
    with $Provider<FeedRepository> {
  FeedRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedRepositoryHash();

  @$internal
  @override
  $ProviderElement<FeedRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FeedRepository create(Ref ref) {
    return feedRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeedRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeedRepository>(value),
    );
  }
}

String _$feedRepositoryHash() => r'd4c9ccd9d2b1bc39aec3b5dbe3d58266c7758b2c';
