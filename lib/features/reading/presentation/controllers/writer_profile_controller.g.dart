// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'writer_profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WriterProfileController)
final writerProfileControllerProvider = WriterProfileControllerFamily._();

final class WriterProfileControllerProvider
    extends $AsyncNotifierProvider<WriterProfileController, WriterProfile> {
  WriterProfileControllerProvider._({
    required WriterProfileControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'writerProfileControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$writerProfileControllerHash();

  @override
  String toString() {
    return r'writerProfileControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  WriterProfileController create() => WriterProfileController();

  @override
  bool operator ==(Object other) {
    return other is WriterProfileControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$writerProfileControllerHash() =>
    r'bcb806fe88f678202e263e3096f278b2a68a9cfb';

final class WriterProfileControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          WriterProfileController,
          AsyncValue<WriterProfile>,
          WriterProfile,
          FutureOr<WriterProfile>,
          String
        > {
  WriterProfileControllerFamily._()
    : super(
        retry: null,
        name: r'writerProfileControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WriterProfileControllerProvider call(String username) =>
      WriterProfileControllerProvider._(argument: username, from: this);

  @override
  String toString() => r'writerProfileControllerProvider';
}

abstract class _$WriterProfileController extends $AsyncNotifier<WriterProfile> {
  late final _$args = ref.$arg as String;
  String get username => _$args;

  FutureOr<WriterProfile> build(String username);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<WriterProfile>, WriterProfile>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<WriterProfile>, WriterProfile>,
              AsyncValue<WriterProfile>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
