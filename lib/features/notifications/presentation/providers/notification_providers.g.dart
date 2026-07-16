// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notificationRemoteDataSource)
final notificationRemoteDataSourceProvider =
    NotificationRemoteDataSourceProvider._();

final class NotificationRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          NotificationRemoteDataSource,
          NotificationRemoteDataSource,
          NotificationRemoteDataSource
        >
    with $Provider<NotificationRemoteDataSource> {
  NotificationRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<NotificationRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationRemoteDataSource create(Ref ref) {
    return notificationRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationRemoteDataSource>(value),
    );
  }
}

String _$notificationRemoteDataSourceHash() =>
    r'c6a024dca71ed4846160265214e7149af04f15db';

@ProviderFor(notificationRepository)
final notificationRepositoryProvider = NotificationRepositoryProvider._();

final class NotificationRepositoryProvider
    extends
        $FunctionalProvider<
          NotificationRepository,
          NotificationRepository,
          NotificationRepository
        >
    with $Provider<NotificationRepository> {
  NotificationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationRepositoryHash();

  @$internal
  @override
  $ProviderElement<NotificationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationRepository create(Ref ref) {
    return notificationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationRepository>(value),
    );
  }
}

String _$notificationRepositoryHash() =>
    r'990ad698619ec1c25f77fcf660f49249355e7a53';

@ProviderFor(notificationPreferencesRepository)
final notificationPreferencesRepositoryProvider =
    NotificationPreferencesRepositoryProvider._();

final class NotificationPreferencesRepositoryProvider
    extends
        $FunctionalProvider<
          NotificationPreferencesRepository,
          NotificationPreferencesRepository,
          NotificationPreferencesRepository
        >
    with $Provider<NotificationPreferencesRepository> {
  NotificationPreferencesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationPreferencesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$notificationPreferencesRepositoryHash();

  @$internal
  @override
  $ProviderElement<NotificationPreferencesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationPreferencesRepository create(Ref ref) {
    return notificationPreferencesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationPreferencesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationPreferencesRepository>(
        value,
      ),
    );
  }
}

String _$notificationPreferencesRepositoryHash() =>
    r'c934ea627342885478cde1f32ce2a9d036ec1876';

@ProviderFor(notificationOutboxStore)
final notificationOutboxStoreProvider = NotificationOutboxStoreProvider._();

final class NotificationOutboxStoreProvider
    extends
        $FunctionalProvider<
          NotificationOutboxStore,
          NotificationOutboxStore,
          NotificationOutboxStore
        >
    with $Provider<NotificationOutboxStore> {
  NotificationOutboxStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationOutboxStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationOutboxStoreHash();

  @$internal
  @override
  $ProviderElement<NotificationOutboxStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationOutboxStore create(Ref ref) {
    return notificationOutboxStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationOutboxStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationOutboxStore>(value),
    );
  }
}

String _$notificationOutboxStoreHash() =>
    r'36286cef1b3674713bf85e67df960240a43a7ab5';

@ProviderFor(notificationSyncEngine)
final notificationSyncEngineProvider = NotificationSyncEngineProvider._();

final class NotificationSyncEngineProvider
    extends
        $FunctionalProvider<
          NotificationSyncEngine,
          NotificationSyncEngine,
          NotificationSyncEngine
        >
    with $Provider<NotificationSyncEngine> {
  NotificationSyncEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationSyncEngineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationSyncEngineHash();

  @$internal
  @override
  $ProviderElement<NotificationSyncEngine> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationSyncEngine create(Ref ref) {
    return notificationSyncEngine(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationSyncEngine value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationSyncEngine>(value),
    );
  }
}

String _$notificationSyncEngineHash() =>
    r'40e8bc593900d994631b88ef5131187b5f486797';

/// The number of pending queued notification actions — drives the offline-pending
/// indicator. Re-reads whenever the engine's revision changes.

@ProviderFor(notificationPendingCount)
final notificationPendingCountProvider = NotificationPendingCountProvider._();

/// The number of pending queued notification actions — drives the offline-pending
/// indicator. Re-reads whenever the engine's revision changes.

final class NotificationPendingCountProvider
    extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// The number of pending queued notification actions — drives the offline-pending
  /// indicator. Re-reads whenever the engine's revision changes.
  NotificationPendingCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationPendingCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationPendingCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return notificationPendingCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$notificationPendingCountHash() =>
    r'310a882d8c51e4afba53a6d78a2702f28744dc46';

@ProviderFor(pushNotificationCoordinator)
final pushNotificationCoordinatorProvider =
    PushNotificationCoordinatorProvider._();

final class PushNotificationCoordinatorProvider
    extends
        $FunctionalProvider<
          PushNotificationCoordinator,
          PushNotificationCoordinator,
          PushNotificationCoordinator
        >
    with $Provider<PushNotificationCoordinator> {
  PushNotificationCoordinatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushNotificationCoordinatorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushNotificationCoordinatorHash();

  @$internal
  @override
  $ProviderElement<PushNotificationCoordinator> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PushNotificationCoordinator create(Ref ref) {
    return pushNotificationCoordinator(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PushNotificationCoordinator value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PushNotificationCoordinator>(value),
    );
  }
}

String _$pushNotificationCoordinatorHash() =>
    r'df94e2779da648a1ae7ccc4676991ffb719f5aa6';
