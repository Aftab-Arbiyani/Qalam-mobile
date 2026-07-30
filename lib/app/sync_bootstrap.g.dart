// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_bootstrap.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Registers every handler + background task onto the engine and starts it.
/// Returns the started engine so a watcher holds it alive.

@ProviderFor(appSync)
final appSyncProvider = AppSyncProvider._();

/// Registers every handler + background task onto the engine and starts it.
/// Returns the started engine so a watcher holds it alive.

final class AppSyncProvider
    extends $FunctionalProvider<SyncEngine, SyncEngine, SyncEngine>
    with $Provider<SyncEngine> {
  /// Registers every handler + background task onto the engine and starts it.
  /// Returns the started engine so a watcher holds it alive.
  AppSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appSyncHash();

  @$internal
  @override
  $ProviderElement<SyncEngine> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncEngine create(Ref ref) {
    return appSync(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncEngine value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncEngine>(value),
    );
  }
}

String _$appSyncHash() => r'c406e8fb6e9b7d2f64f4e96119ead8876117ead2';
