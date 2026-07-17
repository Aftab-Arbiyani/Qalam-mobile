// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'creator_analytics_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(writerAnalytics)
final writerAnalyticsProvider = WriterAnalyticsProvider._();

final class WriterAnalyticsProvider
    extends
        $FunctionalProvider<
          AsyncValue<WriterAnalytics>,
          WriterAnalytics,
          FutureOr<WriterAnalytics>
        >
    with $FutureModifier<WriterAnalytics>, $FutureProvider<WriterAnalytics> {
  WriterAnalyticsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'writerAnalyticsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$writerAnalyticsHash();

  @$internal
  @override
  $FutureProviderElement<WriterAnalytics> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<WriterAnalytics> create(Ref ref) {
    return writerAnalytics(ref);
  }
}

String _$writerAnalyticsHash() => r'3380f8a5277ac76b3337f5cb164c32f625591a77';

@ProviderFor(writerGrowth)
final writerGrowthProvider = WriterGrowthProvider._();

final class WriterGrowthProvider
    extends
        $FunctionalProvider<
          AsyncValue<GrowthSeries>,
          GrowthSeries,
          FutureOr<GrowthSeries>
        >
    with $FutureModifier<GrowthSeries>, $FutureProvider<GrowthSeries> {
  WriterGrowthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'writerGrowthProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$writerGrowthHash();

  @$internal
  @override
  $FutureProviderElement<GrowthSeries> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<GrowthSeries> create(Ref ref) {
    return writerGrowth(ref);
  }
}

String _$writerGrowthHash() => r'8a8586bac7a0760953ca7dbec55118d4c4617170';

/// Owner-only per-piece analytics, keyed by piece id.

@ProviderFor(pieceAnalytics)
final pieceAnalyticsProvider = PieceAnalyticsFamily._();

/// Owner-only per-piece analytics, keyed by piece id.

final class PieceAnalyticsProvider
    extends
        $FunctionalProvider<
          AsyncValue<PieceAnalytics>,
          PieceAnalytics,
          FutureOr<PieceAnalytics>
        >
    with $FutureModifier<PieceAnalytics>, $FutureProvider<PieceAnalytics> {
  /// Owner-only per-piece analytics, keyed by piece id.
  PieceAnalyticsProvider._({
    required PieceAnalyticsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'pieceAnalyticsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pieceAnalyticsHash();

  @override
  String toString() {
    return r'pieceAnalyticsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PieceAnalytics> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PieceAnalytics> create(Ref ref) {
    final argument = this.argument as String;
    return pieceAnalytics(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PieceAnalyticsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pieceAnalyticsHash() => r'e1b6fa073de882ab87fb846d8b96443af2e73ff3';

/// Owner-only per-piece analytics, keyed by piece id.

final class PieceAnalyticsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PieceAnalytics>, String> {
  PieceAnalyticsFamily._()
    : super(
        retry: null,
        name: r'pieceAnalyticsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Owner-only per-piece analytics, keyed by piece id.

  PieceAnalyticsProvider call(String pieceId) =>
      PieceAnalyticsProvider._(argument: pieceId, from: this);

  @override
  String toString() => r'pieceAnalyticsProvider';
}
