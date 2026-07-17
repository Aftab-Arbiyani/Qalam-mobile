// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(syncOutboxStore)
final syncOutboxStoreProvider = SyncOutboxStoreProvider._();

final class SyncOutboxStoreProvider
    extends
        $FunctionalProvider<SyncOutboxStore, SyncOutboxStore, SyncOutboxStore>
    with $Provider<SyncOutboxStore> {
  SyncOutboxStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncOutboxStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncOutboxStoreHash();

  @$internal
  @override
  $ProviderElement<SyncOutboxStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncOutboxStore create(Ref ref) {
    return syncOutboxStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncOutboxStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncOutboxStore>(value),
    );
  }
}

String _$syncOutboxStoreHash() => r'7035aede33bf85c075b1e2f2813eb8ffe3c743b9';

@ProviderFor(syncHistoryStore)
final syncHistoryStoreProvider = SyncHistoryStoreProvider._();

final class SyncHistoryStoreProvider
    extends
        $FunctionalProvider<
          SyncHistoryStore,
          SyncHistoryStore,
          SyncHistoryStore
        >
    with $Provider<SyncHistoryStore> {
  SyncHistoryStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncHistoryStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncHistoryStoreHash();

  @$internal
  @override
  $ProviderElement<SyncHistoryStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncHistoryStore create(Ref ref) {
    return syncHistoryStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncHistoryStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncHistoryStore>(value),
    );
  }
}

String _$syncHistoryStoreHash() => r'08ea875dd228ed23c1769417ab767e1329ab4908';

/// The single engine instance. Built without handlers — the app registrar adds
/// them and calls `start()`. Kept alive for the app's lifetime.

@ProviderFor(syncEngine)
final syncEngineProvider = SyncEngineProvider._();

/// The single engine instance. Built without handlers — the app registrar adds
/// them and calls `start()`. Kept alive for the app's lifetime.

final class SyncEngineProvider
    extends $FunctionalProvider<SyncEngine, SyncEngine, SyncEngine>
    with $Provider<SyncEngine> {
  /// The single engine instance. Built without handlers — the app registrar adds
  /// them and calls `start()`. Kept alive for the app's lifetime.
  SyncEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncEngineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncEngineHash();

  @$internal
  @override
  $ProviderElement<SyncEngine> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncEngine create(Ref ref) {
    return syncEngine(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncEngine value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncEngine>(value),
    );
  }
}

String _$syncEngineHash() => r'0cacf2dd3b8bb6c9fcde2e51ada72bade61b051a';

/// The engine's published state — drives the sync indicator, offline banner and
/// queue-status surfaces. Re-reads whenever the engine emits a new status.

@ProviderFor(syncStatus)
final syncStatusProvider = SyncStatusProvider._();

/// The engine's published state — drives the sync indicator, offline banner and
/// queue-status surfaces. Re-reads whenever the engine emits a new status.

final class SyncStatusProvider
    extends $FunctionalProvider<SyncStatus, SyncStatus, SyncStatus>
    with $Provider<SyncStatus> {
  /// The engine's published state — drives the sync indicator, offline banner and
  /// queue-status surfaces. Re-reads whenever the engine emits a new status.
  SyncStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncStatusHash();

  @$internal
  @override
  $ProviderElement<SyncStatus> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncStatus create(Ref ref) {
    return syncStatus(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncStatus>(value),
    );
  }
}

String _$syncStatusHash() => r'f0af89ae3010c2f27007459265e8cbb092fd0ffd';

/// Every queued operation (pending / failed / conflict), newest intent last.
/// Recomputed whenever the engine's status changes.

@ProviderFor(syncOperations)
final syncOperationsProvider = SyncOperationsProvider._();

/// Every queued operation (pending / failed / conflict), newest intent last.
/// Recomputed whenever the engine's status changes.

final class SyncOperationsProvider
    extends
        $FunctionalProvider<
          List<SyncOperation>,
          List<SyncOperation>,
          List<SyncOperation>
        >
    with $Provider<List<SyncOperation>> {
  /// Every queued operation (pending / failed / conflict), newest intent last.
  /// Recomputed whenever the engine's status changes.
  SyncOperationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncOperationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncOperationsHash();

  @$internal
  @override
  $ProviderElement<List<SyncOperation>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<SyncOperation> create(Ref ref) {
    return syncOperations(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SyncOperation> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SyncOperation>>(value),
    );
  }
}

String _$syncOperationsHash() => r'9ad04cb866269a1997b453256d684be94869ffff';

/// The queued operations currently parked awaiting conflict resolution.

@ProviderFor(syncConflicts)
final syncConflictsProvider = SyncConflictsProvider._();

/// The queued operations currently parked awaiting conflict resolution.

final class SyncConflictsProvider
    extends
        $FunctionalProvider<
          List<SyncOperation>,
          List<SyncOperation>,
          List<SyncOperation>
        >
    with $Provider<List<SyncOperation>> {
  /// The queued operations currently parked awaiting conflict resolution.
  SyncConflictsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncConflictsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncConflictsHash();

  @$internal
  @override
  $ProviderElement<List<SyncOperation>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<SyncOperation> create(Ref ref) {
    return syncConflicts(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SyncOperation> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SyncOperation>>(value),
    );
  }
}

String _$syncConflictsHash() => r'90f3b9d935d165f8788b3701cf6b6e8db153a1fc';

/// The durable synchronization history, newest first. Recomputed on status change
/// (every resolved op appends an entry and changes the status).

@ProviderFor(syncHistory)
final syncHistoryProvider = SyncHistoryProvider._();

/// The durable synchronization history, newest first. Recomputed on status change
/// (every resolved op appends an entry and changes the status).

final class SyncHistoryProvider
    extends
        $FunctionalProvider<
          List<SyncHistoryEntry>,
          List<SyncHistoryEntry>,
          List<SyncHistoryEntry>
        >
    with $Provider<List<SyncHistoryEntry>> {
  /// The durable synchronization history, newest first. Recomputed on status change
  /// (every resolved op appends an entry and changes the status).
  SyncHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncHistoryHash();

  @$internal
  @override
  $ProviderElement<List<SyncHistoryEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<SyncHistoryEntry> create(Ref ref) {
    return syncHistory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SyncHistoryEntry> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SyncHistoryEntry>>(value),
    );
  }
}

String _$syncHistoryHash() => r'9c0d0e3c8fa2147f6690edc4267e10c9f6e44d47';
