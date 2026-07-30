// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_explorer_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(explorerView)
final explorerViewProvider = ExplorerViewFamily._();

final class ExplorerViewProvider
    extends
        $FunctionalProvider<
          AsyncValue<ExplorerViewResult>,
          ExplorerViewResult,
          FutureOr<ExplorerViewResult>
        >
    with
        $FutureModifier<ExplorerViewResult>,
        $FutureProvider<ExplorerViewResult> {
  ExplorerViewProvider._({
    required ExplorerViewFamily super.from,
    required ExplorerArgs super.argument,
  }) : super(
         retry: null,
         name: r'explorerViewProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$explorerViewHash();

  @override
  String toString() {
    return r'explorerViewProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ExplorerViewResult> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ExplorerViewResult> create(Ref ref) {
    final argument = this.argument as ExplorerArgs;
    return explorerView(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ExplorerViewProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$explorerViewHash() => r'bd612381c063243d2f5e4c21d0ab01ef8c34396b';

final class ExplorerViewFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ExplorerViewResult>, ExplorerArgs> {
  ExplorerViewFamily._()
    : super(
        retry: null,
        name: r'explorerViewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ExplorerViewProvider call(ExplorerArgs args) =>
      ExplorerViewProvider._(argument: args, from: this);

  @override
  String toString() => r'explorerViewProvider';
}
