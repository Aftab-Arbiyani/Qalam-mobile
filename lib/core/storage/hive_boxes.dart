/// Hive setup (docs/40 §26).
///
/// Hive is the non-secret local cache (secrets live in secure storage). M1 stores
/// JSON-serializable values only — no custom `TypeAdapter`s — so a cache-schema
/// bump is a box-clear, never a migration (docs/40 §26.2). Box names are stable.
library;

import 'package:hive_ce_flutter/hive_flutter.dart';

abstract final class HiveBoxes {
  /// Read mirror of server state (feed pages, pieces, profiles, …).
  static const String cache = 'qalam_cache';

  /// Non-secret device preferences (theme mode, reading size, remember-me).
  static const String prefs = 'qalam_prefs';

  /// Local reading history + last-read positions (docs/40 §23, §25). Device
  /// reading data — NOT disposable TTL cache, so it is not cleared on a cache
  /// schema bump; entries that fail to parse are skipped by the store instead.
  static const String reading = 'qalam_reading';

  /// Offline drafts + their sync queue (M4, docs/40 §23, §42). Unsynced user
  /// WORK — the most precious local data — so, like [reading], it is NEVER wiped
  /// on a cache-schema bump; unparseable records are skipped, not fatal.
  static const String drafts = 'qalam_drafts';

  /// Bump when the cached value shapes change so boxes are cleared, not migrated.
  static const int schemaVersion = 1;
  static const String _schemaKey = 'qalam.cache_schema_version';
}

/// Initializes Hive and opens the app's boxes. Called once in `bootstrap`.
class HiveInitializer {
  const HiveInitializer();

  Future<
    ({
      Box<dynamic> cache,
      Box<dynamic> prefs,
      Box<dynamic> reading,
      Box<dynamic> drafts,
    })
  >
  initialize() async {
    await Hive.initFlutter();
    final Box<dynamic> prefs = await Hive.openBox<dynamic>(HiveBoxes.prefs);

    // Clear the cache box on a schema-version bump (cache is disposable). The
    // reading + drafts boxes are user data (not TTL cache) and are never wiped.
    final int storedVersion = (prefs.get(HiveBoxes._schemaKey) as int?) ?? 0;
    if (storedVersion != HiveBoxes.schemaVersion) {
      await Hive.deleteBoxFromDisk(HiveBoxes.cache);
      await prefs.put(HiveBoxes._schemaKey, HiveBoxes.schemaVersion);
    }

    final Box<dynamic> cache = await Hive.openBox<dynamic>(HiveBoxes.cache);
    final Box<dynamic> reading = await Hive.openBox<dynamic>(HiveBoxes.reading);
    final Box<dynamic> drafts = await Hive.openBox<dynamic>(HiveBoxes.drafts);
    return (cache: cache, prefs: prefs, reading: reading, drafts: drafts);
  }
}
