// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_draft_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CurrentDraftController)
final currentDraftControllerProvider = CurrentDraftControllerFamily._();

final class CurrentDraftControllerProvider
    extends $AsyncNotifierProvider<CurrentDraftController, EditorState> {
  CurrentDraftControllerProvider._({
    required CurrentDraftControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'currentDraftControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$currentDraftControllerHash();

  @override
  String toString() {
    return r'currentDraftControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CurrentDraftController create() => CurrentDraftController();

  @override
  bool operator ==(Object other) {
    return other is CurrentDraftControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$currentDraftControllerHash() =>
    r'83a5620aef4b9b1c448b8f746def32506b09d949';

final class CurrentDraftControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          CurrentDraftController,
          AsyncValue<EditorState>,
          EditorState,
          FutureOr<EditorState>,
          String
        > {
  CurrentDraftControllerFamily._()
    : super(
        retry: null,
        name: r'currentDraftControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CurrentDraftControllerProvider call(String routeId) =>
      CurrentDraftControllerProvider._(argument: routeId, from: this);

  @override
  String toString() => r'currentDraftControllerProvider';
}

abstract class _$CurrentDraftController extends $AsyncNotifier<EditorState> {
  late final _$args = ref.$arg as String;
  String get routeId => _$args;

  FutureOr<EditorState> build(String routeId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<EditorState>, EditorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<EditorState>, EditorState>,
              AsyncValue<EditorState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
