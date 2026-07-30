/// Story Explorer (AF4) — server state for one explorer view over the knowledge graph.
/// Writes the last-viewed page to a disposable cache on success and falls back to it on
/// failure/offline (graceful degradation of cached reads, docs 40 §23). The client only
/// projects/renders graph objects; the backend owns graph structure.
library;

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/story_graph.dart';
import '../../domain/value_objects/retrieval_vocab.dart';
import '../providers/ai_providers.dart';
import '../providers/retrieval_providers.dart';

part 'story_explorer_controller.g.dart';

typedef ExplorerArgs = ({String storyId, ExplorerView view});

@riverpod
Future<ExplorerViewResult> explorerView(Ref ref, ExplorerArgs args) async {
  final Result<ExplorerViewResult> result = await ref
      .watch(aiRepositoryProvider)
      .explorer(args.storyId, args.view.wire);
  switch (result) {
    case Ok<ExplorerViewResult>(:final ExplorerViewResult value):
      // Best-effort cache write — never block the response on disk I/O.
      unawaited(ref.read(explorerCacheStoreProvider).write(value));
      return value;
    case Err<ExplorerViewResult>(:final Failure failure):
      final ExplorerViewResult? cached = ref
          .read(explorerCacheStoreProvider)
          .read(args.storyId, args.view.wire);
      if (cached != null) {
        return cached; // offline / failure fallback to last-viewed
      }
      throw failure;
  }
}
