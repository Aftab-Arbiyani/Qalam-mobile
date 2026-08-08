// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'writing_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(draftLocalDataSource)
final draftLocalDataSourceProvider = DraftLocalDataSourceProvider._();

final class DraftLocalDataSourceProvider
    extends
        $FunctionalProvider<
          DraftLocalDataSource,
          DraftLocalDataSource,
          DraftLocalDataSource
        >
    with $Provider<DraftLocalDataSource> {
  DraftLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'draftLocalDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$draftLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<DraftLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DraftLocalDataSource create(Ref ref) {
    return draftLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DraftLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DraftLocalDataSource>(value),
    );
  }
}

String _$draftLocalDataSourceHash() =>
    r'9846092d5d42c8da40cb6302396e5d9b432b6c01';

@ProviderFor(pieceEditorRemoteDataSource)
final pieceEditorRemoteDataSourceProvider =
    PieceEditorRemoteDataSourceProvider._();

final class PieceEditorRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          PieceEditorRemoteDataSource,
          PieceEditorRemoteDataSource,
          PieceEditorRemoteDataSource
        >
    with $Provider<PieceEditorRemoteDataSource> {
  PieceEditorRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pieceEditorRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pieceEditorRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<PieceEditorRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PieceEditorRemoteDataSource create(Ref ref) {
    return pieceEditorRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PieceEditorRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PieceEditorRemoteDataSource>(value),
    );
  }
}

String _$pieceEditorRemoteDataSourceHash() =>
    r'1dd0bd75a31ad41bdba61e8c38b1549b4d195d98';

@ProviderFor(pieceEditorRepository)
final pieceEditorRepositoryProvider = PieceEditorRepositoryProvider._();

final class PieceEditorRepositoryProvider
    extends
        $FunctionalProvider<
          PieceEditorRepository,
          PieceEditorRepository,
          PieceEditorRepository
        >
    with $Provider<PieceEditorRepository> {
  PieceEditorRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pieceEditorRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pieceEditorRepositoryHash();

  @$internal
  @override
  $ProviderElement<PieceEditorRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PieceEditorRepository create(Ref ref) {
    return pieceEditorRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PieceEditorRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PieceEditorRepository>(value),
    );
  }
}

String _$pieceEditorRepositoryHash() =>
    r'b726ec4657af86959ef991ce0953dbb488f652d3';

/// The offline-draft sync engine (docs/40 §42). Kept alive for the app's lifetime;
/// registered as a background task on the unified [SyncEngine] (see
/// `app/sync_bootstrap.dart`) so offline drafts drain the moment connectivity
/// returns — on the ONE connectivity signal — even with no editor screen open.

@ProviderFor(draftSyncEngine)
final draftSyncEngineProvider = DraftSyncEngineProvider._();

/// The offline-draft sync engine (docs/40 §42). Kept alive for the app's lifetime;
/// registered as a background task on the unified [SyncEngine] (see
/// `app/sync_bootstrap.dart`) so offline drafts drain the moment connectivity
/// returns — on the ONE connectivity signal — even with no editor screen open.

final class DraftSyncEngineProvider
    extends
        $FunctionalProvider<DraftSyncEngine, DraftSyncEngine, DraftSyncEngine>
    with $Provider<DraftSyncEngine> {
  /// The offline-draft sync engine (docs/40 §42). Kept alive for the app's lifetime;
  /// registered as a background task on the unified [SyncEngine] (see
  /// `app/sync_bootstrap.dart`) so offline drafts drain the moment connectivity
  /// returns — on the ONE connectivity signal — even with no editor screen open.
  DraftSyncEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'draftSyncEngineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$draftSyncEngineHash();

  @$internal
  @override
  $ProviderElement<DraftSyncEngine> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DraftSyncEngine create(Ref ref) {
    return draftSyncEngine(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DraftSyncEngine value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DraftSyncEngine>(value),
    );
  }
}

String _$draftSyncEngineHash() => r'2e658736ca3ff6c1c4ed6a2456725abdc5be9a31';

/// Rebuilds whenever the sync engine mutates a draft, so the drafts list and the
/// open editor refresh after background sync — without any feature→feature or
/// data→presentation dependency (the engine exposes only a change counter).

@ProviderFor(draftsRevision)
final draftsRevisionProvider = DraftsRevisionProvider._();

/// Rebuilds whenever the sync engine mutates a draft, so the drafts list and the
/// open editor refresh after background sync — without any feature→feature or
/// data→presentation dependency (the engine exposes only a change counter).

final class DraftsRevisionProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Rebuilds whenever the sync engine mutates a draft, so the drafts list and the
  /// open editor refresh after background sync — without any feature→feature or
  /// data→presentation dependency (the engine exposes only a change counter).
  DraftsRevisionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'draftsRevisionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$draftsRevisionHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return draftsRevision(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$draftsRevisionHash() => r'86e5d01d2740c90387dc6abee4a71a015e9ee295';

/// The author's plan piece allowance (B4, docs/45 §4.9).
///
/// Re-read whenever the sync engine mutates a draft, because that is when the number
/// moves: a create that lands or a delete that drains frees or spends a slot. Failing to
/// read it is not an error state here — the surfaces render nothing and stay usable,
/// since the server checks the create regardless (`null` = "not known", never
/// "blocked").

@ProviderFor(pieceAllowance)
final pieceAllowanceProvider = PieceAllowanceProvider._();

/// The author's plan piece allowance (B4, docs/45 §4.9).
///
/// Re-read whenever the sync engine mutates a draft, because that is when the number
/// moves: a create that lands or a delete that drains frees or spends a slot. Failing to
/// read it is not an error state here — the surfaces render nothing and stay usable,
/// since the server checks the create regardless (`null` = "not known", never
/// "blocked").

final class PieceAllowanceProvider
    extends
        $FunctionalProvider<
          AsyncValue<PieceAllowance?>,
          PieceAllowance?,
          FutureOr<PieceAllowance?>
        >
    with $FutureModifier<PieceAllowance?>, $FutureProvider<PieceAllowance?> {
  /// The author's plan piece allowance (B4, docs/45 §4.9).
  ///
  /// Re-read whenever the sync engine mutates a draft, because that is when the number
  /// moves: a create that lands or a delete that drains frees or spends a slot. Failing to
  /// read it is not an error state here — the surfaces render nothing and stay usable,
  /// since the server checks the create regardless (`null` = "not known", never
  /// "blocked").
  PieceAllowanceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pieceAllowanceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pieceAllowanceHash();

  @$internal
  @override
  $FutureProviderElement<PieceAllowance?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PieceAllowance?> create(Ref ref) {
    return pieceAllowance(ref);
  }
}

String _$pieceAllowanceHash() => r'01159ca0b7da7fdfe93d73444aee32306c8e4eb2';

/// Current cover-upload progress (0.0–1.0), or null when idle — for the editor's
/// cover field progress indicator.

@ProviderFor(coverUploadProgress)
final coverUploadProgressProvider = CoverUploadProgressProvider._();

/// Current cover-upload progress (0.0–1.0), or null when idle — for the editor's
/// cover field progress indicator.

final class CoverUploadProgressProvider
    extends $FunctionalProvider<double?, double?, double?>
    with $Provider<double?> {
  /// Current cover-upload progress (0.0–1.0), or null when idle — for the editor's
  /// cover field progress indicator.
  CoverUploadProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'coverUploadProgressProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$coverUploadProgressHash();

  @$internal
  @override
  $ProviderElement<double?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double? create(Ref ref) {
    return coverUploadProgress(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double?>(value),
    );
  }
}

String _$coverUploadProgressHash() =>
    r'5d763d1428bd15089c793122b76ca929c1f8bfb4';
