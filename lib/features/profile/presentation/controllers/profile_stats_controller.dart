/// The signed-in user's profile stat tiles (docs/40 §19) — the three counts NOT
/// carried by the profile DTO. Published pieces come straight off
/// `Profile.counts.piecesPublished` (read by the screen); this controller supplies:
///
/// - drafts / bookmarks — bounded first-page counts (`hasMore` → "N+"), since
///   cursor pagination has no total (docs/40 §45);
/// - reading history — the exact local count from [ReadingHistoryStore] (no network,
///   capped at 300 so it never needs a "+").
///
/// Counts fail soft: a failed draft/bookmark fetch yields a null [BoundedCount] so
/// the tile shows "—" rather than erroring the whole screen.
library;

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/reading_history/reading_history_controller.dart';
import '../../../../core/utils/result.dart';
import '../../domain/repositories/profile_repository.dart';
import '../providers/profile_providers.dart';

part 'profile_stats_controller.g.dart';

@immutable
class ProfileStats {
  const ProfileStats({
    this.drafts,
    this.bookmarks,
    required this.readingHistory,
  });

  /// Bounded draft count, or null if the fetch failed.
  final BoundedCount? drafts;

  /// Bounded bookmark count, or null if the fetch failed.
  final BoundedCount? bookmarks;

  /// Exact local reading-history count.
  final int readingHistory;
}

@riverpod
class ProfileStatsController extends _$ProfileStatsController {
  @override
  Future<ProfileStats> build() async {
    final ProfileRepository repo = ref.read(profileRepositoryProvider);
    final int readingHistory = ref
        .read(readingHistoryStoreProvider)
        .readAll()
        .length;
    final Result<BoundedCount> drafts = await repo.myDraftCount();
    final Result<BoundedCount> bookmarks = await repo.myBookmarkCount();
    return ProfileStats(
      drafts: drafts.valueOrNull,
      bookmarks: bookmarks.valueOrNull,
      readingHistory: readingHistory,
    );
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(build);
  }
}
