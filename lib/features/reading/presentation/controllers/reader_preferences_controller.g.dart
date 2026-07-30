// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reader_preferences_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ReaderPreferencesController)
final readerPreferencesControllerProvider =
    ReaderPreferencesControllerProvider._();

final class ReaderPreferencesControllerProvider
    extends $NotifierProvider<ReaderPreferencesController, ReaderPreferences> {
  ReaderPreferencesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readerPreferencesControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readerPreferencesControllerHash();

  @$internal
  @override
  ReaderPreferencesController create() => ReaderPreferencesController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReaderPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReaderPreferences>(value),
    );
  }
}

String _$readerPreferencesControllerHash() =>
    r'f7470e83f472a8472b3b16da0934a6564b9bf35d';

abstract class _$ReaderPreferencesController
    extends $Notifier<ReaderPreferences> {
  ReaderPreferences build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ReaderPreferences, ReaderPreferences>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ReaderPreferences, ReaderPreferences>,
              ReaderPreferences,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
