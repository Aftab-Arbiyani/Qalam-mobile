// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MyProfileController)
final myProfileControllerProvider = MyProfileControllerProvider._();

final class MyProfileControllerProvider
    extends $AsyncNotifierProvider<MyProfileController, Profile> {
  MyProfileControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myProfileControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myProfileControllerHash();

  @$internal
  @override
  MyProfileController create() => MyProfileController();
}

String _$myProfileControllerHash() =>
    r'cbd060df5c6d3a1bffc033d2f3654864792b9c1f';

abstract class _$MyProfileController extends $AsyncNotifier<Profile> {
  FutureOr<Profile> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Profile>, Profile>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Profile>, Profile>,
              AsyncValue<Profile>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
