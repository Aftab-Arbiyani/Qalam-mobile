/// Reading-history providers (docs/40 §8, §23) — cross-cutting device state read
/// by the feed (History tab, Continue Reading shelf) and written by the reader
/// (on scroll / on exit). Lives in `core` because two features share it and
/// features never import features (docs/40 §7.3, §7.5); its API takes primitives,
/// never a feature entity, so `core` stays feature-free.
///
/// Keep-alive: the timeline must survive navigation between the reader and the
/// feed so a just-read piece appears immediately under Recently Read.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/domain/enums.dart';
import '../di/providers.dart';
import 'reading_history_entry.dart';
import 'reading_history_store.dart';

part 'reading_history_controller.g.dart';

@Riverpod(keepAlive: true)
ReadingHistoryStore readingHistoryStore(Ref ref) =>
    ReadingHistoryStore(ref.watch(readingBoxProvider));

@Riverpod(keepAlive: true)
class ReadingHistoryController extends _$ReadingHistoryController {
  @override
  List<ReadingHistoryEntry> build() =>
      ref.watch(readingHistoryStoreProvider).readAll();

  /// Record a reading session for a piece — merges with any existing entry:
  /// accumulates read time, advances to the latest scroll position, and marks
  /// completion sticky. Card fields are denormalized so the timeline renders
  /// offline. [sessionSeconds] is the dwell to ADD; [progress] is 0–1.
  Future<void> record({
    required String pieceId,
    required String title,
    required double progress,
    String authorName = '',
    String? authorUsername,
    String? slug,
    String? coverImageKey,
    String? languageCode,
    TextDirectionKind direction = TextDirectionKind.ltr,
    int sessionSeconds = 0,
    bool completed = false,
    DateTime? at,
  }) async {
    final ReadingHistoryStore store = ref.read(readingHistoryStoreProvider);
    final ReadingHistoryEntry? existing = store.read(pieceId);
    final bool isCompleted = (existing?.isCompleted ?? false) || completed;

    final ReadingHistoryEntry merged = ReadingHistoryEntry(
      pieceId: pieceId,
      title: title.isNotEmpty ? title : (existing?.title ?? title),
      lastReadAt: (at ?? DateTime.now()).toUtc(),
      authorName: authorName.isNotEmpty
          ? authorName
          : (existing?.authorName ?? ''),
      authorUsername: authorUsername ?? existing?.authorUsername,
      slug: slug ?? existing?.slug,
      coverImageKey: coverImageKey ?? existing?.coverImageKey,
      languageCode: languageCode ?? existing?.languageCode,
      direction: direction,
      progress: isCompleted ? 1.0 : progress.clamp(0.0, 1.0),
      totalReadSeconds:
          (existing?.totalReadSeconds ?? 0) +
          (sessionSeconds < 0 ? 0 : sessionSeconds),
      isCompleted: isCompleted,
    );

    await store.write(merged);
    state = store.readAll();
  }

  /// The saved scroll position (0–1) for [pieceId] — used to resume reading.
  double positionFor(String pieceId) =>
      ref.read(readingHistoryStoreProvider).read(pieceId)?.clampedProgress ?? 0;

  Future<void> remove(String pieceId) async {
    await ref.read(readingHistoryStoreProvider).remove(pieceId);
    state = ref.read(readingHistoryStoreProvider).readAll();
  }

  Future<void> clearAll() async {
    await ref.read(readingHistoryStoreProvider).clear();
    state = <ReadingHistoryEntry>[];
  }
}

/// "Continue Reading" — meaningfully-started, unfinished pieces, newest first.
@riverpod
List<ReadingHistoryEntry> continueReadingList(Ref ref) => ref
    .watch(readingHistoryControllerProvider)
    .where((ReadingHistoryEntry e) => e.isInProgress)
    .toList(growable: false);

/// "Recently Read" — the full timeline, newest first.
@riverpod
List<ReadingHistoryEntry> recentlyReadList(Ref ref) =>
    ref.watch(readingHistoryControllerProvider);
