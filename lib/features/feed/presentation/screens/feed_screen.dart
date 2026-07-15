/// The Home Feed screen (docs/40 §10.2, docs/41 §17). A scrollable tab bar over
/// the six feed surfaces — For You, Following, Trending, Latest, Bookmarks, and
/// Reading History — each backed by the shared feed infrastructure. A compass
/// action opens Discovery. Lands on "For You" (public; works signed-out).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../shared/preferences/app_preferences_controllers.dart';
import '../../../../shared/preferences/default_feed.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/layout/q_scaffold.dart';
import '../../domain/value_objects/feed_query.dart';
import '../widgets/bookmarks_tab.dart';
import '../widgets/history_tab.dart';
import '../widgets/piece_feed_tab.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen>
    with SingleTickerProviderStateMixin {
  static const List<({String label, Widget view})> _tabs =
      <({String label, Widget view})>[
        (label: 'For you', view: PieceFeedTab(tab: FeedTab.forYou)),
        (label: 'Following', view: PieceFeedTab(tab: FeedTab.following)),
        (label: 'Trending', view: PieceFeedTab(tab: FeedTab.trending)),
        (label: 'Latest', view: PieceFeedTab(tab: FeedTab.latest)),
        (label: 'Bookmarks', view: BookmarksTab()),
        (label: 'History', view: HistoryTab()),
      ];

  /// Land on the user's chosen default feed (docs/40 §8.4). Read once at build of
  /// the controller; changing the preference applies on the next launch.
  static int _tabIndexFor(DefaultFeed feed) => switch (feed) {
    DefaultFeed.forYou => 0,
    DefaultFeed.following => 1,
    DefaultFeed.trending => 2,
    DefaultFeed.latest => 3,
  };

  late final TabController _controller = TabController(
    length: _tabs.length,
    initialIndex: _tabIndexFor(ref.read(defaultFeedControllerProvider)),
    vsync: this,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    return QScaffold(
      appBar: QAppBar(
        title: 'Qalam',
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.explore_outlined),
            tooltip: 'Discover',
            onPressed: () => context.push(Routes.discover),
          ),
        ],
        bottom: TabBar(
          controller: _controller,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: tokens.colors.accent,
          unselectedLabelColor: tokens.colors.textSecondary,
          indicatorColor: tokens.colors.accent,
          tabs: <Widget>[
            for (final ({String label, Widget view}) tab in _tabs)
              Tab(text: tab.label),
          ],
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: <Widget>[
          for (final ({String label, Widget view}) tab in _tabs) tab.view,
        ],
      ),
    );
  }
}
