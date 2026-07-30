// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(pieceRemoteDataSource)
final pieceRemoteDataSourceProvider = PieceRemoteDataSourceProvider._();

final class PieceRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          PieceRemoteDataSource,
          PieceRemoteDataSource,
          PieceRemoteDataSource
        >
    with $Provider<PieceRemoteDataSource> {
  PieceRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pieceRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pieceRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<PieceRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PieceRemoteDataSource create(Ref ref) {
    return pieceRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PieceRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PieceRemoteDataSource>(value),
    );
  }
}

String _$pieceRemoteDataSourceHash() =>
    r'6c629ce7705efbec765a2f54e0e1faf11455a08b';

@ProviderFor(pieceLocalDataSource)
final pieceLocalDataSourceProvider = PieceLocalDataSourceProvider._();

final class PieceLocalDataSourceProvider
    extends
        $FunctionalProvider<
          PieceLocalDataSource,
          PieceLocalDataSource,
          PieceLocalDataSource
        >
    with $Provider<PieceLocalDataSource> {
  PieceLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pieceLocalDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pieceLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<PieceLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PieceLocalDataSource create(Ref ref) {
    return pieceLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PieceLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PieceLocalDataSource>(value),
    );
  }
}

String _$pieceLocalDataSourceHash() =>
    r'b3b0986560d28758a06b82d55b11e7b7917ddb71';

@ProviderFor(readingRepository)
final readingRepositoryProvider = ReadingRepositoryProvider._();

final class ReadingRepositoryProvider
    extends
        $FunctionalProvider<
          ReadingRepository,
          ReadingRepository,
          ReadingRepository
        >
    with $Provider<ReadingRepository> {
  ReadingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readingRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readingRepositoryHash();

  @$internal
  @override
  $ProviderElement<ReadingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReadingRepository create(Ref ref) {
    return readingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadingRepository>(value),
    );
  }
}

String _$readingRepositoryHash() => r'86563da6d68449779e28478909dd5f1e8aea1042';
