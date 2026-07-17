// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cacheManager)
final cacheManagerProvider = CacheManagerProvider._();

final class CacheManagerProvider
    extends $FunctionalProvider<CacheManager, CacheManager, CacheManager>
    with $Provider<CacheManager> {
  CacheManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cacheManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cacheManagerHash();

  @$internal
  @override
  $ProviderElement<CacheManager> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CacheManager create(Ref ref) {
    return cacheManager(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CacheManager value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CacheManager>(value),
    );
  }
}

String _$cacheManagerHash() => r'718ca5eacf578ba22333283b5ea6d0e2c8a2c8a7';

/// The live cache statistics for the storage screen. Recomputed on demand after a
/// cleanup / clear.

@ProviderFor(CacheStatsController)
final cacheStatsControllerProvider = CacheStatsControllerProvider._();

/// The live cache statistics for the storage screen. Recomputed on demand after a
/// cleanup / clear.
final class CacheStatsControllerProvider
    extends $NotifierProvider<CacheStatsController, CacheStats> {
  /// The live cache statistics for the storage screen. Recomputed on demand after a
  /// cleanup / clear.
  CacheStatsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cacheStatsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cacheStatsControllerHash();

  @$internal
  @override
  CacheStatsController create() => CacheStatsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CacheStats value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CacheStats>(value),
    );
  }
}

String _$cacheStatsControllerHash() =>
    r'f8688c8e19c6ec10545ae20f034d13e3ae43ebb5';

/// The live cache statistics for the storage screen. Recomputed on demand after a
/// cleanup / clear.

abstract class _$CacheStatsController extends $Notifier<CacheStats> {
  CacheStats build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CacheStats, CacheStats>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CacheStats, CacheStats>,
              CacheStats,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// App-start maintenance — evict hard-expired cache entries once, off the critical
/// path. Kept alive + watched from the app root (docs/40 §37 automatic cleanup).

@ProviderFor(cacheMaintenance)
final cacheMaintenanceProvider = CacheMaintenanceProvider._();

/// App-start maintenance — evict hard-expired cache entries once, off the critical
/// path. Kept alive + watched from the app root (docs/40 §37 automatic cleanup).

final class CacheMaintenanceProvider
    extends $FunctionalProvider<Object, Object, Object>
    with $Provider<Object> {
  /// App-start maintenance — evict hard-expired cache entries once, off the critical
  /// path. Kept alive + watched from the app root (docs/40 §37 automatic cleanup).
  CacheMaintenanceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cacheMaintenanceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cacheMaintenanceHash();

  @$internal
  @override
  $ProviderElement<Object> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Object create(Ref ref) {
    return cacheMaintenance(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Object value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Object>(value),
    );
  }
}

String _$cacheMaintenanceHash() => r'88588d81ba2d51b10f89dfc61d0fbfd4178a92e4';
