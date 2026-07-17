// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ConversationDetailController)
final conversationDetailControllerProvider =
    ConversationDetailControllerFamily._();

final class ConversationDetailControllerProvider
    extends
        $AsyncNotifierProvider<
          ConversationDetailController,
          AiConversationDetail
        > {
  ConversationDetailControllerProvider._({
    required ConversationDetailControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'conversationDetailControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$conversationDetailControllerHash();

  @override
  String toString() {
    return r'conversationDetailControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ConversationDetailController create() => ConversationDetailController();

  @override
  bool operator ==(Object other) {
    return other is ConversationDetailControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$conversationDetailControllerHash() =>
    r'6d4e804a82a2a6e36d9acadbee22d27523a5ac16';

final class ConversationDetailControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ConversationDetailController,
          AsyncValue<AiConversationDetail>,
          AiConversationDetail,
          FutureOr<AiConversationDetail>,
          String
        > {
  ConversationDetailControllerFamily._()
    : super(
        retry: null,
        name: r'conversationDetailControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ConversationDetailControllerProvider call(String conversationId) =>
      ConversationDetailControllerProvider._(
        argument: conversationId,
        from: this,
      );

  @override
  String toString() => r'conversationDetailControllerProvider';
}

abstract class _$ConversationDetailController
    extends $AsyncNotifier<AiConversationDetail> {
  late final _$args = ref.$arg as String;
  String get conversationId => _$args;

  FutureOr<AiConversationDetail> build(String conversationId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<AiConversationDetail>, AiConversationDetail>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<AiConversationDetail>,
                AiConversationDetail
              >,
              AsyncValue<AiConversationDetail>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
