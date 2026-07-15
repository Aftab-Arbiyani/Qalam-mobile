/// Which home-feed tab opens by default (docs/40 §8.4) — a device-local reader
/// preference (the frozen `v1` has no server field for it). Only the four piece
/// feeds are offered as landing tabs; Bookmarks/History are destinations, not
/// defaults. The feed screen maps the choice to its initial tab.
library;

enum DefaultFeed {
  forYou('for_you'),
  following('following'),
  trending('trending'),
  latest('latest');

  const DefaultFeed(this.wire);

  final String wire;

  static DefaultFeed fromWire(
    String? value, {
    DefaultFeed fallback = DefaultFeed.forYou,
  }) => values.firstWhere((e) => e.wire == value, orElse: () => fallback);
}
