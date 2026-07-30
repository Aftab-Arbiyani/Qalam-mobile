/// Local draft store (docs/40 §23, §26, §42) — the only place the writing feature
/// touches the Hive `drafts` box. The offline-first source of truth for drafts:
/// every create/edit is written here FIRST (instant, offline-capable) and the sync
/// engine reconciles with the server later. Also caches the server drafts list so
/// the drafts screen renders offline.
///
/// Drafts are stored as JSON strings keyed by `localId`; parse failures (from an
/// older on-disk shape) are skipped, never fatal (forward-compatible, like the
/// reading-history store). This box is precious user WORK and is never wiped on a
/// cache-schema bump (docs/40 §26.2).
library;

import 'dart:convert';

import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/draft.dart';
import '../../domain/entities/draft_summary.dart';

class DraftLocalDataSource {
  DraftLocalDataSource(this._box);

  final Box<dynamic> _box;

  static const String _draftPrefix = 'd:';
  static const String _serverListKey = 'server_summaries';

  String _key(String localId) => '$_draftPrefix$localId';

  Draft? read(String localId) => _parseDraft(_box.get(_key(localId)));

  Draft? readByRemoteId(String remoteId) {
    for (final Draft d in all()) {
      if (d.remoteId == remoteId) return d;
    }
    return null;
  }

  Future<void> write(Draft draft) =>
      _box.put(_key(draft.localId), jsonEncode(draft.toJson()));

  Future<void> remove(String localId) => _box.delete(_key(localId));

  /// All local drafts, newest-edited first. Skips unparseable records.
  List<Draft> all() {
    final List<Draft> out = <Draft>[];
    for (final dynamic key in _box.keys) {
      if (key is! String || !key.startsWith(_draftPrefix)) continue;
      final Draft? d = _parseDraft(_box.get(key));
      if (d != null) out.add(d);
    }
    out.sort(
      (Draft a, Draft b) => b.localUpdatedAt.compareTo(a.localUpdatedAt),
    );
    return out;
  }

  /// Drafts with unsynced work, OLDEST edit first — the FIFO order the sync engine
  /// drains so edits land in the order they were made.
  List<Draft> pending() {
    final List<Draft> dirty =
        all().where((Draft d) => d.syncState.isDirty).toList()..sort(
          (Draft a, Draft b) => a.localUpdatedAt.compareTo(b.localUpdatedAt),
        );
    return dirty;
  }

  // ── Server drafts-list cache (offline viewing of the drafts screen) ──────────

  Future<void> writeServerSummaries(List<DraftSummary> summaries) => _box.put(
    _serverListKey,
    jsonEncode(<Map<String, dynamic>>[
      for (final DraftSummary s in summaries) s.toJson(),
    ]),
  );

  List<DraftSummary> serverSummaries() {
    final Object? raw = _box.get(_serverListKey);
    if (raw is! String) return const <DraftSummary>[];
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! List) return const <DraftSummary>[];
      return decoded
          .whereType<Map<dynamic, dynamic>>()
          .map((Map<dynamic, dynamic> m) => DraftSummary.fromJson(Json.from(m)))
          .toList(growable: false);
    } on Object {
      return const <DraftSummary>[];
    }
  }

  Future<void> clear() => _box.clear();

  Draft? _parseDraft(Object? raw) {
    if (raw is! String) return null;
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return Draft.fromJson(Json.from(decoded));
    } on Object {
      return null; // Older/corrupt shape — drop rather than crash.
    }
  }
}
