// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ask_book_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AskBookController)
final askBookControllerProvider = AskBookControllerProvider._();

final class AskBookControllerProvider
    extends $NotifierProvider<AskBookController, AskBookState> {
  AskBookControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'askBookControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$askBookControllerHash();

  @$internal
  @override
  AskBookController create() => AskBookController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AskBookState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AskBookState>(value),
    );
  }
}

String _$askBookControllerHash() => r'25595c9c5a331a3b530d9bea082131681f667995';

abstract class _$AskBookController extends $Notifier<AskBookState> {
  AskBookState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AskBookState, AskBookState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AskBookState, AskBookState>,
              AskBookState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
