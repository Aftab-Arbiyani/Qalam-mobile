// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PublicProfileController)
final publicProfileControllerProvider = PublicProfileControllerFamily._();

final class PublicProfileControllerProvider
    extends $AsyncNotifierProvider<PublicProfileController, Profile> {
  PublicProfileControllerProvider._({
    required PublicProfileControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'publicProfileControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publicProfileControllerHash();

  @override
  String toString() {
    return r'publicProfileControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PublicProfileController create() => PublicProfileController();

  @override
  bool operator ==(Object other) {
    return other is PublicProfileControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publicProfileControllerHash() =>
    r'f9ba2c500a1759b93c5dc1238eaee8b9b9513c2d';

final class PublicProfileControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          PublicProfileController,
          AsyncValue<Profile>,
          Profile,
          FutureOr<Profile>,
          String
        > {
  PublicProfileControllerFamily._()
    : super(
        retry: null,
        name: r'publicProfileControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PublicProfileControllerProvider call(String username) =>
      PublicProfileControllerProvider._(argument: username, from: this);

  @override
  String toString() => r'publicProfileControllerProvider';
}

abstract class _$PublicProfileController extends $AsyncNotifier<Profile> {
  late final _$args = ref.$arg as String;
  String get username => _$args;

  FutureOr<Profile> build(String username);
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
    return element.handleCreate(ref, () => build(_$args));
  }
}
