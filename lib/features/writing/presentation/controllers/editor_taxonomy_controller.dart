/// Editor taxonomy providers (docs/40 §8.3) — the language + genre option lists
/// the metadata form reads, exposed as `AsyncValue` (cache-then-network with
/// offline fallback in the repository). Server state, so a repository-backed
/// FutureProvider, not a UI notifier.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/utils/result.dart';
import '../../../../shared/domain/entities/taxonomy.dart';
import '../providers/writing_providers.dart';

part 'editor_taxonomy_controller.g.dart';

@riverpod
Future<List<LanguageRef>> editorLanguages(Ref ref) async {
  final Result<List<LanguageRef>> result = await ref
      .watch(editorTaxonomyRepositoryProvider)
      .languages();
  return result.fold(
    (List<LanguageRef> languages) => languages,
    (Object failure) => throw failure,
  );
}

@riverpod
Future<List<GenreRef>> editorGenres(Ref ref) async {
  final Result<List<GenreRef>> result = await ref
      .watch(editorTaxonomyRepositoryProvider)
      .genres();
  return result.fold(
    (List<GenreRef> genres) => genres,
    (Object failure) => throw failure,
  );
}
