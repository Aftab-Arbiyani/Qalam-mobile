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
    r'2351e42f90c6bb2a99616521e90275637d3e77a6';

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
