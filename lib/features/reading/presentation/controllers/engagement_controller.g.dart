// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'engagement_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EngagementController)
final engagementControllerProvider = EngagementControllerFamily._();

final class EngagementControllerProvider
    extends $AsyncNotifierProvider<EngagementController, PieceEngagement> {
  EngagementControllerProvider._({
    required EngagementControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'engagementControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$engagementControllerHash();

  @override
  String toString() {
    return r'engagementControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EngagementController create() => EngagementController();

  @override
  bool operator ==(Object other) {
    return other is EngagementControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$engagementControllerHash() =>
    r'6d1129712007970b4a7c4b28add14936c4b76102';

final class EngagementControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          EngagementController,
          AsyncValue<PieceEngagement>,
          PieceEngagement,
          FutureOr<PieceEngagement>,
          String
        > {
  EngagementControllerFamily._()
    : super(
        retry: null,
        name: r'engagementControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EngagementControllerProvider call(String pieceId) =>
      EngagementControllerProvider._(argument: pieceId, from: this);

  @override
  String toString() => r'engagementControllerProvider';
}

abstract class _$EngagementController extends $AsyncNotifier<PieceEngagement> {
  late final _$args = ref.$arg as String;
  String get pieceId => _$args;

  FutureOr<PieceEngagement> build(String pieceId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PieceEngagement>, PieceEngagement>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PieceEngagement>, PieceEngagement>,
              AsyncValue<PieceEngagement>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
