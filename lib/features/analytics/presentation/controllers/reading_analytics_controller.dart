/// Reading Analytics controller (docs/40 §30) — LOCAL-FIRST by design. It always
/// builds insights from device reading history (so Continue Reading, Recently Read
/// and Weekly Activity work fully offline) and AUGMENTS them with the backend
/// reader aggregate (streak / reading time / completed / favourite genres +
/// languages) and the bookmarks count. A backend/transport failure degrades
/// gracefully to the local-only view rather than erroring — reading history is the
/// user's own device data.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/reading_history/reading_history_controller.dart';
import '../../../../core/reading_history/reading_history_entry.dart';
import '../../../../core/utils/result.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../domain/entities/reader_analytics.dart';
import '../../domain/value_objects/reading_insights.dart';
import '../providers/analytics_providers.dart';

part 'reading_analytics_controller.g.dart';

@riverpod
Future<ReadingInsights> readingInsights(Ref ref) async {
  // Local history — the always-available base (device data, works offline).
  final List<ReadingHistoryEntry> history = ref
      .watch(readingHistoryStoreProvider)
      .readAll();

  // Backend aggregate — folds to empty on any failure so local still renders.
  final Result<ReaderAnalytics> backendResult = await ref
      .watch(analyticsRepositoryProvider)
      .readerAnalytics();
  final ReaderAnalytics backend = backendResult.fold(
    (ReaderAnalytics v) => v,
    (Object _) => ReaderAnalytics.empty,
  );

  // Bookmarks count — reuse the profile bounded-count endpoint; fold to 0.
  final Result<BoundedCount> bookmarksResult = await ref
      .watch(profileRepositoryProvider)
      .myBookmarkCount();
  final int bookmarks = bookmarksResult.fold(
    (BoundedCount c) => c.count,
    (Object _) => 0,
  );

  return buildReadingInsights(
    backend: backend,
    history: history,
    bookmarksCount: bookmarks,
  );
}
