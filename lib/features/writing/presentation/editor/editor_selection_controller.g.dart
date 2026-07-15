// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editor_selection_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EditorSelectionController)
final editorSelectionControllerProvider = EditorSelectionControllerProvider._();

final class EditorSelectionControllerProvider
    extends $NotifierProvider<EditorSelectionController, EditorSelection?> {
  EditorSelectionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'editorSelectionControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$editorSelectionControllerHash();

  @$internal
  @override
  EditorSelectionController create() => EditorSelectionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EditorSelection? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EditorSelection?>(value),
    );
  }
}

String _$editorSelectionControllerHash() =>
    r'039dea653b381c0be9480a1d0d69c5c406867b95';

abstract class _$EditorSelectionController extends $Notifier<EditorSelection?> {
  EditorSelection? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<EditorSelection?, EditorSelection?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<EditorSelection?, EditorSelection?>,
              EditorSelection?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
