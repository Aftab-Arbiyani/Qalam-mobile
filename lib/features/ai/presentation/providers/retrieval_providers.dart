/// AF4 composition roots — the on-device stores for AI search history, saved searches,
/// and the last-viewed explorer cache. All derive from the core Hive box providers; the
/// repository + remote data source are the AF1 ones (`ai_providers.dart`). Kept alive
/// (stateless + cross-cutting).
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers.dart';
import '../../data/local/ai_search_history_store.dart';
import '../../data/local/explorer_cache_store.dart';
import '../../data/local/saved_searches_store.dart';

part 'retrieval_providers.g.dart';

/// Device-local recent AI-search queries (survives cache-clear + logout).
@Riverpod(keepAlive: true)
AiSearchHistoryStore aiSearchHistoryStore(Ref ref) =>
    AiSearchHistoryStore(ref.watch(prefsBoxProvider));

/// Device-local mirror of the caller's saved searches.
@Riverpod(keepAlive: true)
SavedSearchesStore savedSearchesStore(Ref ref) =>
    SavedSearchesStore(ref.watch(prefsBoxProvider));

/// Disposable last-viewed explorer cache (instant / offline render).
@Riverpod(keepAlive: true)
ExplorerCacheStore explorerCacheStore(Ref ref) =>
    ExplorerCacheStore(ref.watch(cacheBoxProvider));
