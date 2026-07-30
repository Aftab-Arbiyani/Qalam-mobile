/// Last-viewed Story Explorer pages (docs 40 §23) — a small disposable mirror in the
/// `cache` box so an explorer view renders instantly / offline while the network
/// refresh runs. Keyed by (storyId, view). Cache is disposable: a parse failure or a
/// schema drift just misses, never crashes.
library;

import 'dart:convert';

import 'package:hive_ce/hive.dart';

import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/story_graph.dart';

class ExplorerCacheStore {
  ExplorerCacheStore(this._box);

  final Box<dynamic> _box;

  String _key(String storyId, String view) => 'ai_explorer:$storyId:$view';

  ExplorerViewResult? read(String storyId, String view) {
    final Object? raw = _box.get(_key(storyId, view));
    if (raw is! String || raw.isEmpty) return null;
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return ExplorerViewResult.fromJson(Json.from(decoded));
    } on Object {
      return null;
    }
  }

  Future<void> write(ExplorerViewResult result) =>
      _box.put(_key(result.storyId, result.view), jsonEncode(result.toJson()));
}
