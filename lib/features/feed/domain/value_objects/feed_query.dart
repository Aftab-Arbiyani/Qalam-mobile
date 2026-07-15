/// Feed identity + filters (docs/40 §6, §13.6). [FeedTab] names the four
/// `PieceSummary` timelines that share the feed infrastructure; [FeedQuery] carries
/// the optional server-side filters those endpoints accept. Filters default to
/// none in M3 (the tabs themselves are the surface); the query is modelled so a
/// future filter bar reuses the same infra with zero change.
library;

import '../../../../core/utils/typedefs.dart';
import '../../../../shared/domain/enums.dart';

/// The four piece-summary feed tabs. Each maps to a route-per-feed endpoint
/// (`/feed/{wire}`). "For You" has no dedicated endpoint in frozen `v1`, so it is
/// backed by the author-diverse `/feed/discover` (documented contract-reality).
enum FeedTab {
  following('following', requiresAuth: true),
  forYou('discover'),
  trending('trending'),
  latest('latest');

  const FeedTab(this.wire, {this.requiresAuth = false});

  /// The `/feed/{wire}` path segment.
  final String wire;

  /// Whether the endpoint requires an authenticated viewer (only `following`).
  final bool requiresAuth;

  /// Data-shaped cache key (docs/40 §25.1).
  String get cacheKey => 'feed:list:$wire';
}

/// Optional server-side feed filters (docs/40 §13.6). Arrays are comma-joined and
/// nulls omitted by the `ApiClient` query encoder.
class FeedQuery {
  const FeedQuery({
    this.sort,
    this.languages = const <String>[],
    this.genre,
    this.tag,
  });

  final FeedSort? sort;
  final List<String> languages;
  final String? genre;
  final String? tag;

  /// The default: no filters.
  static const FeedQuery none = FeedQuery();

  bool get isEmpty =>
      sort == null && languages.isEmpty && genre == null && tag == null;

  /// Declared query params only (docs/40 §13.6) — the encoder omits nulls and
  /// joins the language list.
  Json toParams() => <String, dynamic>{
    if (sort != null) 'sort': sort!.wire,
    if (languages.isNotEmpty) 'language': languages,
    if (genre != null) 'genre': genre,
    if (tag != null) 'tag': tag,
  };

  @override
  bool operator ==(Object other) =>
      other is FeedQuery &&
      other.sort == sort &&
      other.genre == genre &&
      other.tag == tag &&
      _listEquals(other.languages, languages);

  @override
  int get hashCode => Object.hash(sort, genre, tag, Object.hashAll(languages));

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
