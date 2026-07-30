// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'responses_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ResponsesController)
final responsesControllerProvider = ResponsesControllerFamily._();

final class ResponsesControllerProvider
    extends
        $AsyncNotifierProvider<
          ResponsesController,
          PagedListState<ResponseItem>
        > {
  ResponsesControllerProvider._({
    required ResponsesControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'responsesControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$responsesControllerHash();

  @override
  String toString() {
    return r'responsesControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ResponsesController create() => ResponsesController();

  @override
  bool operator ==(Object other) {
    return other is ResponsesControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$responsesControllerHash() =>
    r'18ee034f1137e89a8bb3c52ae60938843ffa0e90';

final class ResponsesControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ResponsesController,
          AsyncValue<PagedListState<ResponseItem>>,
          PagedListState<ResponseItem>,
          FutureOr<PagedListState<ResponseItem>>,
          String
        > {
  ResponsesControllerFamily._()
    : super(
        retry: null,
        name: r'responsesControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ResponsesControllerProvider call(String pieceId) =>
      ResponsesControllerProvider._(argument: pieceId, from: this);

  @override
  String toString() => r'responsesControllerProvider';
}

abstract class _$ResponsesController
    extends $AsyncNotifier<PagedListState<ResponseItem>> {
  late final _$args = ref.$arg as String;
  String get pieceId => _$args;

  FutureOr<PagedListState<ResponseItem>> build(String pieceId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PagedListState<ResponseItem>>,
              PagedListState<ResponseItem>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PagedListState<ResponseItem>>,
                PagedListState<ResponseItem>
              >,
              AsyncValue<PagedListState<ResponseItem>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
