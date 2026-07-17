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

/// Keeps the unread badge honest as queued notification actions drain on the
/// unified engine: a change in the engine's outstanding work re-reads the count.
/// Kept alive + watched from the app root so it works with no inbox screen open —
/// the same always-on guarantee the old engine gave.

@ProviderFor(notificationSyncWatcher)
final notificationSyncWatcherProvider = NotificationSyncWatcherProvider._();

/// Keeps the unread badge honest as queued notification actions drain on the
/// unified engine: a change in the engine's outstanding work re-reads the count.
/// Kept alive + watched from the app root so it works with no inbox screen open —
/// the same always-on guarantee the old engine gave.

final class NotificationSyncWatcherProvider
    extends $FunctionalProvider<Object, Object, Object>
    with $Provider<Object> {
  /// Keeps the unread badge honest as queued notification actions drain on the
  /// unified engine: a change in the engine's outstanding work re-reads the count.
  /// Kept alive + watched from the app root so it works with no inbox screen open —
  /// the same always-on guarantee the old engine gave.
  NotificationSyncWatcherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationSyncWatcherProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationSyncWatcherHash();

  @$internal
  @override
  $ProviderElement<Object> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Object create(Ref ref) {
    return notificationSyncWatcher(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Object value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Object>(value),
    );
  }
}

String _$notificationSyncWatcherHash() =>
    r'83ed2175c2c1d1b4e063235530b01b97119cb7a2';

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
