// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmarks_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BookmarksController)
final bookmarksControllerProvider = BookmarksControllerProvider._();

final class BookmarksControllerProvider
    extends
        $AsyncNotifierProvider<
          BookmarksController,
          PagedListState<BookmarkItem>
        > {
  BookmarksControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookmarksControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookmarksControllerHash();

  @$internal
  @override
  BookmarksController create() => BookmarksController();
}

String _$bookmarksControllerHash() =>
    r'2d7d0534d56afcbebf7df166550c0b3430c1c91e';

abstract class _$BookmarksController
    extends $AsyncNotifier<PagedListState<BookmarkItem>> {
  FutureOr<PagedListState<BookmarkItem>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PagedListState<BookmarkItem>>,
              PagedListState<BookmarkItem>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PagedListState<BookmarkItem>>,
                PagedListState<BookmarkItem>
              >,
              AsyncValue<PagedListState<BookmarkItem>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
