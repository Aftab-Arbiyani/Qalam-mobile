/// Reading Analytics, fused (docs/40 §30) — the authoritative backend
/// [ReaderAnalytics] (streak / reading time / completed / favourite genres +
/// languages) COMBINED with device-local reading history for the surfaces the
/// frozen `v1` API does not expose: Continue Reading, Recently Read and a Weekly
/// Activity breakdown. Pure value object; [buildReadingInsights] derives the local
/// parts from the reading-history entries with no I/O.
library;

import 'package:flutter/foundation.dart';

import '../../../../core/reading_history/reading_history_entry.dart';
import '../entities/reader_analytics.dart';

/// Reading pressure for one weekday over the trailing week.
@immutable
class WeekdayActivity {
  const WeekdayActivity({
    required this.weekday,
    required this.pieces,
    required this.seconds,
  });

  /// ISO weekday, 1 = Monday … 7 = Sunday.
  final int weekday;

  /// Distinct pieces whose last-read fell on this weekday in the window.
  final int pieces;

  /// Read seconds attributed to this weekday (by each entry's last-read day).
  final int seconds;

  static const List<String> _labels = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  String get shortLabel => _labels[(weekday - 1).clamp(0, 6)];
}

@immutable
class ReadingInsights {
  const ReadingInsights({
    required this.backend,
    required this.continueReading,
    required this.recentlyRead,
    required this.weeklyActivity,
    required this.localLanguages,
    required this.bookmarksCount,
  });

  /// Authoritative cross-device aggregates.
  final ReaderAnalytics backend;

  /// Meaningfully-started, unfinished pieces — the Continue Reading rail.
  final List<ReadingHistoryEntry> continueReading;

  /// Most-recent reads, newest first (bounded).
  final List<ReadingHistoryEntry> recentlyRead;

  /// Seven buckets, Monday→Sunday, for the trailing week.
  final List<WeekdayActivity> weeklyActivity;

  /// Distinct languages read locally (fallback when the backend list is empty).
  final int localLanguages;

  /// Saved bookmarks count (from `/me/bookmarks`).
  final int bookmarksCount;

  static const ReadingInsights empty = ReadingInsights(
    backend: ReaderAnalytics.empty,
    continueReading: <ReadingHistoryEntry>[],
    recentlyRead: <ReadingHistoryEntry>[],
    weeklyActivity: <WeekdayActivity>[],
    localLanguages: 0,
    bookmarksCount: 0,
  );

  bool get hasAnyActivity =>
      backend.piecesRead > 0 ||
      recentlyRead.isNotEmpty ||
      bookmarksCount > 0;
}

/// Derive the local reading insights from history entries + the backend aggregate.
/// [now] is injectable for deterministic tests.
ReadingInsights buildReadingInsights({
  required ReaderAnalytics backend,
  required List<ReadingHistoryEntry> history,
  required int bookmarksCount,
  DateTime? now,
  int continueLimit = 10,
  int recentLimit = 20,
}) {
  final DateTime today = now ?? DateTime.now();
  final DateTime weekStart = DateTime(
    today.year,
    today.month,
    today.day,
  ).subtract(const Duration(days: 6));

  final List<ReadingHistoryEntry> continueReading = history
      .where((ReadingHistoryEntry e) => e.isInProgress)
      .take(continueLimit)
      .toList(growable: false);

  final List<ReadingHistoryEntry> recentlyRead = history
      .take(recentLimit)
      .toList(growable: false);

  // Seven weekday buckets (Mon..Sun) for the trailing week.
  final List<int> pieces = List<int>.filled(7, 0);
  final List<int> seconds = List<int>.filled(7, 0);
  for (final ReadingHistoryEntry e in history) {
    final DateTime at = e.lastReadAt;
    if (at.isBefore(weekStart)) continue;
    final int idx = (at.weekday - 1).clamp(0, 6);
    pieces[idx] += 1;
    seconds[idx] += e.totalReadSeconds;
  }
  final List<WeekdayActivity> weekly = <WeekdayActivity>[
    for (int i = 0; i < 7; i++)
      WeekdayActivity(weekday: i + 1, pieces: pieces[i], seconds: seconds[i]),
  ];

  final Set<String> languages = <String>{
    for (final ReadingHistoryEntry e in history)
      if ((e.languageCode ?? '').isNotEmpty) e.languageCode!,
  };

  return ReadingInsights(
    backend: backend,
    continueReading: continueReading,
    recentlyRead: recentlyRead,
    weeklyActivity: weekly,
    localLanguages: languages.length,
    bookmarksCount: bookmarksCount,
  );
}
