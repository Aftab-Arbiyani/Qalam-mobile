/// The shared feed UI (docs/40 §44 "all feed types reuse a shared feed
/// infrastructure", docs/41 §16, §17). Renders any `AsyncValue<PagedListState<T>>`
/// as skeleton → error → empty → infinite list, with pull-to-refresh everywhere
/// and a trailing load-more loader. Every feed/bookmark surface uses THIS — the
/// only place feed loading/empty/error/pagination UX is expressed.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../shared/domain/error_codes.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/feedback/q_snackbar.dart';
import '../../../../shared/widgets/list/q_paged_list_view.dart';
import '../../../../shared/widgets/list/q_refresh.dart';
import '../../../../shared/widgets/states/q_error_view.dart';
import '../state/paged_list_state.dart';

class PagedFeedView<T> extends StatelessWidget {
  const PagedFeedView({
    required this.state,
    required this.itemBuilder,
    required this.onRefresh,
    required this.onLoadMore,
    required this.empty,
    this.loading,
    this.padding = const EdgeInsets.symmetric(vertical: QSpacing.s2),
    super.key,
  });

  final AsyncValue<PagedListState<T>> state;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;

  /// Shown when the loaded list is empty.
  final Widget empty;

  /// The first-load skeleton; defaults to a simple centered progress area.
  final Widget? loading;

  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return state.when(
      skipLoadingOnRefresh: true,
      skipLoadingOnReload: true,
      loading: () => loading ?? const _DefaultLoading(),
      error: (Object error, StackTrace _) => _refreshable(
        QErrorView(failure: _asFailure(error), onRetry: onRefresh),
      ),
      data: (PagedListState<T> paged) {
        if (paged.isEmpty) return _refreshable(empty);
        return _LoadMoreListener<T>(
          state: paged,
          onLoadMore: onLoadMore,
          child: QPagedListView<T>(
            items: paged.items,
            hasMore: paged.hasMore,
            isLoadingMore: paged.isLoadingMore,
            onLoadMore: onLoadMore,
            onRefresh: onRefresh,
            padding: padding,
            itemBuilder: itemBuilder,
          ),
        );
      },
    );
  }

  Widget _refreshable(Widget child) => QRefresh(
    onRefresh: onRefresh,
    child: LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) =>
          SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: child,
            ),
          ),
    ),
  );

  Failure _asFailure(Object error) => error is Failure
      ? error
      : Failure.unexpected(
          code: ErrorCodes.apiUnexpected,
          message: error.toString(),
        );
}

class _DefaultLoading extends StatelessWidget {
  const _DefaultLoading();

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(32),
      child: CircularProgressIndicator(),
    ),
  );
}

/// Surfaces a subsequent-page failure as a quiet toast without disturbing the
/// already-painted list (docs/41 §17 — a load-more error is not a full error state).
class _LoadMoreListener<T> extends StatefulWidget {
  const _LoadMoreListener({
    required this.state,
    required this.onLoadMore,
    required this.child,
  });

  final PagedListState<T> state;
  final VoidCallback onLoadMore;
  final Widget child;

  @override
  State<_LoadMoreListener<T>> createState() => _LoadMoreListenerState<T>();
}

class _LoadMoreListenerState<T> extends State<_LoadMoreListener<T>> {
  @override
  void didUpdateWidget(_LoadMoreListener<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final Failure? failure = widget.state.loadMoreFailure;
    if (failure != null &&
        oldWidget.state.loadMoreFailure != failure &&
        mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        QSnackbar.show(
          context,
          message: "Couldn't load more just now.",
          variant: QSnackbarVariant.danger,
          actionLabel: 'Retry',
          onAction: widget.onLoadMore,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
