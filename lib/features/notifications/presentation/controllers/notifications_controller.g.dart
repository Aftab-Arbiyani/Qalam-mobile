// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NotificationsController)
final notificationsControllerProvider = NotificationsControllerFamily._();

final class NotificationsControllerProvider
    extends
        $AsyncNotifierProvider<
          NotificationsController,
          PagedListState<AppNotification>
        > {
  NotificationsControllerProvider._({
    required NotificationsControllerFamily super.from,
    required NotificationFilter super.argument,
  }) : super(
         retry: null,
         name: r'notificationsControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$notificationsControllerHash();

  @override
  String toString() {
    return r'notificationsControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  NotificationsController create() => NotificationsController();

  @override
  bool operator ==(Object other) {
    return other is NotificationsControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$notificationsControllerHash() =>
    r'be40b812a3cc21257131503fc539a3b26be0a0c4';

final class NotificationsControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          NotificationsController,
          AsyncValue<PagedListState<AppNotification>>,
          PagedListState<AppNotification>,
          FutureOr<PagedListState<AppNotification>>,
          NotificationFilter
        > {
  NotificationsControllerFamily._()
    : super(
        retry: null,
        name: r'notificationsControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  NotificationsControllerProvider call(NotificationFilter filter) =>
      NotificationsControllerProvider._(argument: filter, from: this);

  @override
  String toString() => r'notificationsControllerProvider';
}

abstract class _$NotificationsController
    extends $AsyncNotifier<PagedListState<AppNotification>> {
  late final _$args = ref.$arg as NotificationFilter;
  NotificationFilter get filter => _$args;

  FutureOr<PagedListState<AppNotification>> build(NotificationFilter filter);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PagedListState<AppNotification>>,
              PagedListState<AppNotification>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PagedListState<AppNotification>>,
                PagedListState<AppNotification>
              >,
              AsyncValue<PagedListState<AppNotification>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
