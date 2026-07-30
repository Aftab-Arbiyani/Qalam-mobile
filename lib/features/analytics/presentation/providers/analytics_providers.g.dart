// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(analyticsRemoteDataSource)
final analyticsRemoteDataSourceProvider = AnalyticsRemoteDataSourceProvider._();

final class AnalyticsRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          AnalyticsRemoteDataSource,
          AnalyticsRemoteDataSource,
          AnalyticsRemoteDataSource
        >
    with $Provider<AnalyticsRemoteDataSource> {
  AnalyticsRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'analyticsRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$analyticsRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<AnalyticsRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AnalyticsRemoteDataSource create(Ref ref) {
    return analyticsRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnalyticsRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnalyticsRemoteDataSource>(value),
    );
  }
}

String _$analyticsRemoteDataSourceHash() =>
    r'df7ccc073d073620242c4b3a452b81f628d09f27';

@ProviderFor(analyticsRepository)
final analyticsRepositoryProvider = AnalyticsRepositoryProvider._();

final class AnalyticsRepositoryProvider
    extends
        $FunctionalProvider<
          AnalyticsRepository,
          AnalyticsRepository,
          AnalyticsRepository
        >
    with $Provider<AnalyticsRepository> {
  AnalyticsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'analyticsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$analyticsRepositoryHash();

  @$internal
  @override
  $ProviderElement<AnalyticsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AnalyticsRepository create(Ref ref) {
    return analyticsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnalyticsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnalyticsRepository>(value),
    );
  }
}

String _$analyticsRepositoryHash() =>
    r'f79ff812c23103c96191189c997f4a72cdf0ff8d';
