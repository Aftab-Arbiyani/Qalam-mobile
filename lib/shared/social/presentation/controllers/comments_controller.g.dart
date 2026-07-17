// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comments_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CommentsController)
final commentsControllerProvider = CommentsControllerFamily._();

final class CommentsControllerProvider
    extends
        $AsyncNotifierProvider<CommentsController, PagedListState<Comment>> {
  CommentsControllerProvider._({
    required CommentsControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'commentsControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$commentsControllerHash();

  @override
  String toString() {
    return r'commentsControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CommentsController create() => CommentsController();

  @override
  bool operator ==(Object other) {
    return other is CommentsControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$commentsControllerHash() =>
    r'027b2f15cf2bd6b5e6bca0c8eaf3e9fdcf24aba8';

final class CommentsControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          CommentsController,
          AsyncValue<PagedListState<Comment>>,
          PagedListState<Comment>,
          FutureOr<PagedListState<Comment>>,
          String
        > {
  CommentsControllerFamily._()
    : super(
        retry: null,
        name: r'commentsControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CommentsControllerProvider call(String pieceId) =>
      CommentsControllerProvider._(argument: pieceId, from: this);

  @override
  String toString() => r'commentsControllerProvider';
}

abstract class _$CommentsController
    extends $AsyncNotifier<PagedListState<Comment>> {
  late final _$args = ref.$arg as String;
  String get pieceId => _$args;

  FutureOr<PagedListState<Comment>> build(String pieceId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PagedListState<Comment>>,
              PagedListState<Comment>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PagedListState<Comment>>,
                PagedListState<Comment>
              >,
              AsyncValue<PagedListState<Comment>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(RepliesController)
final repliesControllerProvider = RepliesControllerFamily._();

final class RepliesControllerProvider
    extends $AsyncNotifierProvider<RepliesController, PagedListState<Comment>> {
  RepliesControllerProvider._({
    required RepliesControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'repliesControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$repliesControllerHash();

  @override
  String toString() {
    return r'repliesControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  RepliesController create() => RepliesController();

  @override
  bool operator ==(Object other) {
    return other is RepliesControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$repliesControllerHash() => r'ebef60f83fdc2653226d6c0838e9302d7e3eff2a';

final class RepliesControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          RepliesController,
          AsyncValue<PagedListState<Comment>>,
          PagedListState<Comment>,
          FutureOr<PagedListState<Comment>>,
          String
        > {
  RepliesControllerFamily._()
    : super(
        retry: null,
        name: r'repliesControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RepliesControllerProvider call(String commentId) =>
      RepliesControllerProvider._(argument: commentId, from: this);

  @override
  String toString() => r'repliesControllerProvider';
}

abstract class _$RepliesController
    extends $AsyncNotifier<PagedListState<Comment>> {
  late final _$args = ref.$arg as String;
  String get commentId => _$args;

  FutureOr<PagedListState<Comment>> build(String commentId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PagedListState<Comment>>,
              PagedListState<Comment>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PagedListState<Comment>>,
                PagedListState<Comment>
              >,
              AsyncValue<PagedListState<Comment>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
