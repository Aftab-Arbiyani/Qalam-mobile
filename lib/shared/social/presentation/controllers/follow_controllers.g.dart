// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow_controllers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FollowersController)
final followersControllerProvider = FollowersControllerFamily._();

final class FollowersControllerProvider
    extends
        $AsyncNotifierProvider<
          FollowersController,
          PagedListState<FollowUser>
        > {
  FollowersControllerProvider._({
    required FollowersControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'followersControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$followersControllerHash();

  @override
  String toString() {
    return r'followersControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FollowersController create() => FollowersController();

  @override
  bool operator ==(Object other) {
    return other is FollowersControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$followersControllerHash() =>
    r'84fee41a5df290e97e7457661ad5f3417e19ba11';

final class FollowersControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          FollowersController,
          AsyncValue<PagedListState<FollowUser>>,
          PagedListState<FollowUser>,
          FutureOr<PagedListState<FollowUser>>,
          String
        > {
  FollowersControllerFamily._()
    : super(
        retry: null,
        name: r'followersControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FollowersControllerProvider call(String username) =>
      FollowersControllerProvider._(argument: username, from: this);

  @override
  String toString() => r'followersControllerProvider';
}

abstract class _$FollowersController
    extends $AsyncNotifier<PagedListState<FollowUser>> {
  late final _$args = ref.$arg as String;
  String get username => _$args;

  FutureOr<PagedListState<FollowUser>> build(String username);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PagedListState<FollowUser>>,
              PagedListState<FollowUser>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PagedListState<FollowUser>>,
                PagedListState<FollowUser>
              >,
              AsyncValue<PagedListState<FollowUser>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(FollowingController)
final followingControllerProvider = FollowingControllerFamily._();

final class FollowingControllerProvider
    extends
        $AsyncNotifierProvider<
          FollowingController,
          PagedListState<FollowUser>
        > {
  FollowingControllerProvider._({
    required FollowingControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'followingControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$followingControllerHash();

  @override
  String toString() {
    return r'followingControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FollowingController create() => FollowingController();

  @override
  bool operator ==(Object other) {
    return other is FollowingControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$followingControllerHash() =>
    r'e26caab78fd75153b77d885e6b26d06005ca2f88';

final class FollowingControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          FollowingController,
          AsyncValue<PagedListState<FollowUser>>,
          PagedListState<FollowUser>,
          FutureOr<PagedListState<FollowUser>>,
          String
        > {
  FollowingControllerFamily._()
    : super(
        retry: null,
        name: r'followingControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FollowingControllerProvider call(String username) =>
      FollowingControllerProvider._(argument: username, from: this);

  @override
  String toString() => r'followingControllerProvider';
}

abstract class _$FollowingController
    extends $AsyncNotifier<PagedListState<FollowUser>> {
  late final _$args = ref.$arg as String;
  String get username => _$args;

  FutureOr<PagedListState<FollowUser>> build(String username);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PagedListState<FollowUser>>,
              PagedListState<FollowUser>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PagedListState<FollowUser>>,
                PagedListState<FollowUser>
              >,
              AsyncValue<PagedListState<FollowUser>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(FollowRequestsController)
final followRequestsControllerProvider = FollowRequestsControllerProvider._();

final class FollowRequestsControllerProvider
    extends
        $AsyncNotifierProvider<
          FollowRequestsController,
          PagedListState<FollowRequest>
        > {
  FollowRequestsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'followRequestsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$followRequestsControllerHash();

  @$internal
  @override
  FollowRequestsController create() => FollowRequestsController();
}

String _$followRequestsControllerHash() =>
    r'6ff8a58ce2bc4e828155b348bc2f1cd730700bd6';

abstract class _$FollowRequestsController
    extends $AsyncNotifier<PagedListState<FollowRequest>> {
  FutureOr<PagedListState<FollowRequest>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PagedListState<FollowRequest>>,
              PagedListState<FollowRequest>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PagedListState<FollowRequest>>,
                PagedListState<FollowRequest>
              >,
              AsyncValue<PagedListState<FollowRequest>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
