// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prompt_library_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PromptLibraryController)
final promptLibraryControllerProvider = PromptLibraryControllerProvider._();

final class PromptLibraryControllerProvider
    extends $NotifierProvider<PromptLibraryController, PromptLibraryState> {
  PromptLibraryControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'promptLibraryControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$promptLibraryControllerHash();

  @$internal
  @override
  PromptLibraryController create() => PromptLibraryController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PromptLibraryState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PromptLibraryState>(value),
    );
  }
}

String _$promptLibraryControllerHash() =>
    r'10fd234a7f550e48a57e716219677fd537dd9732';

abstract class _$PromptLibraryController extends $Notifier<PromptLibraryState> {
  PromptLibraryState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PromptLibraryState, PromptLibraryState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PromptLibraryState, PromptLibraryState>,
              PromptLibraryState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
