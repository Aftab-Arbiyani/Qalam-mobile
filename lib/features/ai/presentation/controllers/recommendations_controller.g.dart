// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendations_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(recommendations)
final recommendationsProvider = RecommendationsFamily._();

final class RecommendationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<RecommendationResponse>,
          RecommendationResponse,
          FutureOr<RecommendationResponse>
        >
    with
        $FutureModifier<RecommendationResponse>,
        $FutureProvider<RecommendationResponse> {
  RecommendationsProvider._({
    required RecommendationsFamily super.from,
    required RecommendationArgs super.argument,
  }) : super(
         retry: null,
         name: r'recommendationsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recommendationsHash();

  @override
  String toString() {
    return r'recommendationsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<RecommendationResponse> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RecommendationResponse> create(Ref ref) {
    final argument = this.argument as RecommendationArgs;
    return recommendations(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RecommendationsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recommendationsHash() => r'c5d943fb7f400bbe08a86c69880be3ae54571753';

final class RecommendationsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<RecommendationResponse>,
          RecommendationArgs
        > {
  RecommendationsFamily._()
    : super(
        retry: null,
        name: r'recommendationsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RecommendationsProvider call(RecommendationArgs args) =>
      RecommendationsProvider._(argument: args, from: this);

  @override
  String toString() => r'recommendationsProvider';
}
