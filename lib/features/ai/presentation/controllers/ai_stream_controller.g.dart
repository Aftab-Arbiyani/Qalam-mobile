// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_stream_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AiStreamController)
final aiStreamControllerProvider = AiStreamControllerProvider._();

final class AiStreamControllerProvider
    extends $NotifierProvider<AiStreamController, AiStreamState> {
  AiStreamControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiStreamControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiStreamControllerHash();

  @$internal
  @override
  AiStreamController create() => AiStreamController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AiStreamState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AiStreamState>(value),
    );
  }
}

String _$aiStreamControllerHash() =>
    r'44083c1156a07598169727b27a3a1b761ac65f19';

abstract class _$AiStreamController extends $Notifier<AiStreamState> {
  AiStreamState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AiStreamState, AiStreamState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AiStreamState, AiStreamState>,
              AiStreamState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
