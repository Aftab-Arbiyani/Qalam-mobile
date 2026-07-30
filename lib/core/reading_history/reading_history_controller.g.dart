// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_history_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(readingHistoryStore)
final readingHistoryStoreProvider = ReadingHistoryStoreProvider._();

final class ReadingHistoryStoreProvider
    extends
        $FunctionalProvider<
          ReadingHistoryStore,
          ReadingHistoryStore,
          ReadingHistoryStore
        >
    with $Provider<ReadingHistoryStore> {
  ReadingHistoryStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readingHistoryStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readingHistoryStoreHash();

  @$internal
  @override
  $ProviderElement<ReadingHistoryStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReadingHistoryStore create(Ref ref) {
    return readingHistoryStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadingHistoryStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadingHistoryStore>(value),
    );
  }
}

String _$readingHistoryStoreHash() =>
    r'f7ea08612e640b5d4e3f3c01cace4fb58b0e3c9c';

@ProviderFor(ReadingHistoryController)
final readingHistoryControllerProvider = ReadingHistoryControllerProvider._();

final class ReadingHistoryControllerProvider
    extends
        $NotifierProvider<ReadingHistoryController, List<ReadingHistoryEntry>> {
  ReadingHistoryControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readingHistoryControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readingHistoryControllerHash();

  @$internal
  @override
  ReadingHistoryController create() => ReadingHistoryController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ReadingHistoryEntry> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ReadingHistoryEntry>>(value),
    );
  }
}

String _$readingHistoryControllerHash() =>
    r'3d14bf971ec345b8bef133cfcef9008cd96c6d15';

abstract class _$ReadingHistoryController
    extends $Notifier<List<ReadingHistoryEntry>> {
  List<ReadingHistoryEntry> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<List<ReadingHistoryEntry>, List<ReadingHistoryEntry>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<ReadingHistoryEntry>, List<ReadingHistoryEntry>>,
              List<ReadingHistoryEntry>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// "Continue Reading" — meaningfully-started, unfinished pieces, newest first.

@ProviderFor(continueReadingList)
final continueReadingListProvider = ContinueReadingListProvider._();

/// "Continue Reading" — meaningfully-started, unfinished pieces, newest first.

final class ContinueReadingListProvider
    extends
        $FunctionalProvider<
          List<ReadingHistoryEntry>,
          List<ReadingHistoryEntry>,
          List<ReadingHistoryEntry>
        >
    with $Provider<List<ReadingHistoryEntry>> {
  /// "Continue Reading" — meaningfully-started, unfinished pieces, newest first.
  ContinueReadingListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'continueReadingListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$continueReadingListHash();

  @$internal
  @override
  $ProviderElement<List<ReadingHistoryEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<ReadingHistoryEntry> create(Ref ref) {
    return continueReadingList(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ReadingHistoryEntry> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ReadingHistoryEntry>>(value),
    );
  }
}

String _$continueReadingListHash() =>
    r'973be4d3d75db1eb4753c53f921e34df5ca0de6d';

/// "Recently Read" — the full timeline, newest first.

@ProviderFor(recentlyReadList)
final recentlyReadListProvider = RecentlyReadListProvider._();

/// "Recently Read" — the full timeline, newest first.

final class RecentlyReadListProvider
    extends
        $FunctionalProvider<
          List<ReadingHistoryEntry>,
          List<ReadingHistoryEntry>,
          List<ReadingHistoryEntry>
        >
    with $Provider<List<ReadingHistoryEntry>> {
  /// "Recently Read" — the full timeline, newest first.
  RecentlyReadListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentlyReadListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentlyReadListHash();

  @$internal
  @override
  $ProviderElement<List<ReadingHistoryEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<ReadingHistoryEntry> create(Ref ref) {
    return recentlyReadList(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ReadingHistoryEntry> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ReadingHistoryEntry>>(value),
    );
  }
}

String _$recentlyReadListHash() => r'4c3728ff7de36a332bf88f47a123f96a9f0b3150';
