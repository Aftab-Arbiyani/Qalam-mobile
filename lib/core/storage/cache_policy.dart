/// Cache freshness tiers (docs/40 §8.3, §25.2) — mirror the web `staleTime`
/// policy so both clients feel the same. A cached entry older than its tier's
/// TTL is *stale* (served for instant paint, then refreshed); older than the
/// hard-expiry multiple it is evictable.
library;

enum CacheTier {
  live(Duration(seconds: 30)),
  identity(Duration(minutes: 1)),
  content(Duration(minutes: 5)),
  taxonomy(Duration(hours: 1));

  const CacheTier(this.ttl);

  final Duration ttl;

  /// Beyond `ttl * hardExpiryMultiplier` the entry is discarded rather than shown.
  static const int hardExpiryMultiplier = 24;

  Duration get hardExpiry => ttl * hardExpiryMultiplier;
}
