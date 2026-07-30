// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_analytics_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(readingInsights)
final readingInsightsProvider = ReadingInsightsProvider._();

final class ReadingInsightsProvider
    extends
        $FunctionalProvider<
          AsyncValue<ReadingInsights>,
          ReadingInsights,
          FutureOr<ReadingInsights>
        >
    with $FutureModifier<ReadingInsights>, $FutureProvider<ReadingInsights> {
  ReadingInsightsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readingInsightsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readingInsightsHash();

  @$internal
  @override
  $FutureProviderElement<ReadingInsights> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ReadingInsights> create(Ref ref) {
    return readingInsights(ref);
  }
}

String _$readingInsightsHash() => r'1fce28f2f9adfa7ab93254f0c7c87af6b2bf8ab1';
