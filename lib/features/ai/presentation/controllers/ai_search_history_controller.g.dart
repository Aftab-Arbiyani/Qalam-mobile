// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_search_history_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AiSearchHistoryController)
final aiSearchHistoryControllerProvider = AiSearchHistoryControllerProvider._();

final class AiSearchHistoryControllerProvider
    extends $NotifierProvider<AiSearchHistoryController, List<String>> {
  AiSearchHistoryControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiSearchHistoryControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiSearchHistoryControllerHash();

  @$internal
  @override
  AiSearchHistoryController create() => AiSearchHistoryController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$aiSearchHistoryControllerHash() =>
    r'b2947aaf586eb4897e73e048e3c41bd26eb2c9b3';

abstract class _$AiSearchHistoryController extends $Notifier<List<String>> {
  List<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<String>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<String>, List<String>>,
              List<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
