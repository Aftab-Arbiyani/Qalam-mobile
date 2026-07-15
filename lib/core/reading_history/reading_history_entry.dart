/// A local reading-history record (docs/40 §23, §25, §30.1).
///
/// The frozen `v1` API has NO reading-position / reading-history surface — the
/// backend accepts only fire-and-forget view/read analytics beacons and exposes
/// aggregate reader stats, never a per-piece position or a history list. So the
/// mobile client owns reading history locally (Hive `reading` box): last scroll
/// position (for "Resume" / "Continue Reading"), accumulated read time, and a
/// "Recently Read" timeline. This is device data, not server state.
///
/// The card render fields (title/author/cover/direction) are denormalized here so
/// the history + continue-reading surfaces render offline without re-fetching.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../shared/domain/enums.dart';

part 'reading_history_entry.freezed.dart';
part 'reading_history_entry.g.dart';

@freezed
abstract class ReadingHistoryEntry with _$ReadingHistoryEntry {
  const ReadingHistoryEntry._();

  const factory ReadingHistoryEntry({
    required String pieceId,
    required String title,
    required DateTime lastReadAt,
    @Default('') String authorName,
    String? authorUsername,
    String? slug,
    String? coverImageKey,
    String? languageCode,
    @Default(TextDirectionKind.ltr) TextDirectionKind direction,

    /// Last scroll position as a fraction 0.0–1.0 of the content extent.
    @Default(0) double progress,

    /// Accumulated dwell time across sessions, in seconds.
    @Default(0) int totalReadSeconds,

    /// Whether the reader reached the end (progress ≥ completion threshold).
    @Default(false) bool isCompleted,
  }) = _ReadingHistoryEntry;

  factory ReadingHistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$ReadingHistoryEntryFromJson(json);

  /// Progress clamped to a sane 0–1 for the progress indicator.
  double get clampedProgress => progress.clamp(0.0, 1.0);

  /// A piece worth surfacing under "Continue Reading" — meaningfully started but
  /// not finished (docs/41 §35). Trivial and near-complete positions are excluded.
  bool get isInProgress => !isCompleted && progress > 0.03 && progress < 0.95;

  /// Progress as a whole-percent for semantic labels (~10% steps handled by UI).
  int get progressPercent => (clampedProgress * 100).round();
}
