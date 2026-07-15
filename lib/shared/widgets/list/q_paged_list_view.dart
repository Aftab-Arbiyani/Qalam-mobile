/// Paginated, memory-efficient infinite list (docs/41 §17, docs/40 §36).
///
/// Lazy `ListView.builder` over an already-loaded item list; calls [onLoadMore]
/// when the user nears the end (and once after first layout if the first page
/// underfills the viewport). Renders a trailing loader while fetching. Optional
/// pull-to-refresh. Cursors stay opaque and out of this widget.
library;

import 'package:flutter/material.dart';

import '../loading/q_loading_indicator.dart';
import 'q_refresh.dart';

class QPagedListView<T> extends StatefulWidget {
  const QPagedListView({
    required this.items,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onLoadMore,
    required this.itemBuilder,
    this.onRefresh,
    this.padding,
    this.loadMoreExtent = 400,
    super.key,
  });

  final List<T> items;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function()? onRefresh;
  final EdgeInsets? padding;
  final double loadMoreExtent;

  @override
  State<QPagedListView<T>> createState() => _QPagedListViewState<T>();
}

class _QPagedListViewState<T> extends State<QPagedListView<T>> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeLoadMore());
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - widget.loadMoreExtent) {
      _maybeLoadMore();
    }
  }

  void _maybeLoadMore() {
    if (widget.hasMore && !widget.isLoadingMore) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final int itemCount = widget.items.length + (widget.hasMore ? 1 : 0);
    final Widget list = ListView.builder(
      controller: _controller,
      padding: widget.padding,
      itemCount: itemCount,
      itemBuilder: (BuildContext context, int index) {
        if (index >= widget.items.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: QLoadingIndicator(size: 20),
          );
        }
        return widget.itemBuilder(context, widget.items[index], index);
      },
    );

    if (widget.onRefresh == null) return list;
    return QRefresh(onRefresh: widget.onRefresh!, child: list);
  }
}
