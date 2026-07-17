// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversations_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ConversationsController)
final conversationsControllerProvider = ConversationsControllerProvider._();

final class ConversationsControllerProvider
    extends
        $AsyncNotifierProvider<ConversationsController, ConversationsState> {
  ConversationsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conversationsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conversationsControllerHash();

  @$internal
  @override
  ConversationsController create() => ConversationsController();
}

String _$conversationsControllerHash() =>
    r'3658a0aa035657f22c4c9270e5ec67a75bd0c66e';

abstract class _$ConversationsController
    extends $AsyncNotifier<ConversationsState> {
  FutureOr<ConversationsState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<ConversationsState>, ConversationsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ConversationsState>, ConversationsState>,
              AsyncValue<ConversationsState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
