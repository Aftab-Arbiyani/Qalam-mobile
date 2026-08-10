// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'actor_profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(actorProfile)
final actorProfileProvider = ActorProfileFamily._();

final class ActorProfileProvider
    extends
        $FunctionalProvider<AsyncValue<Profile?>, Profile?, FutureOr<Profile?>>
    with $FutureModifier<Profile?>, $FutureProvider<Profile?> {
  ActorProfileProvider._({
    required ActorProfileFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'actorProfileProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$actorProfileHash();

  @override
  String toString() {
    return r'actorProfileProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Profile?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Profile?> create(Ref ref) {
    final argument = this.argument as String;
    return actorProfile(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ActorProfileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$actorProfileHash() => r'5bfc2ead0092e0f91238864725b3027b51008179';

final class ActorProfileFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Profile?>, String> {
  ActorProfileFamily._()
    : super(
        retry: null,
        name: r'actorProfileProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  ActorProfileProvider call(String userId) =>
      ActorProfileProvider._(argument: userId, from: this);

  @override
  String toString() => r'actorProfileProvider';
}
