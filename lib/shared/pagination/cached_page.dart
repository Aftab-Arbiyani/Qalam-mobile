/// A repository read result that carries freshness (docs/40 §16.3, §23.2).
/// Cursor-paginated repositories serve cache-then-network: [isStale] is true when
/// the page was served from the Hive cache (offline or a fetch failure) so the
/// presentation can show the offline/stale banner without any network reasoning of
/// its own. Shared across feed, bookmarks, and profile timelines.
library;

import '../api/api_envelope.dart';

class CachedPage<T> {
  const CachedPage({required this.page, this.isStale = false});

  final CursorPage<T> page;
  final bool isStale;
}
