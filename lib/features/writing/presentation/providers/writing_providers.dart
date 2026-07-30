/// The writing feature's composition root (docs/40 §9). Binds the authoring +
/// taxonomy domain repositories to their data implementations, exposes the local
/// draft store, and constructs the always-on [DraftSyncEngine] (background sync).
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers.dart';
import '../../data/datasources/draft_local_data_source.dart';
import '../../data/datasources/piece_editor_remote_data_source.dart';
import '../../data/repositories/piece_editor_repository_impl.dart';
import '../../data/sync/draft_sync_engine.dart';
import '../../domain/repositories/piece_editor_repository.dart';

part 'writing_providers.g.dart';

@Riverpod(keepAlive: true)
DraftLocalDataSource draftLocalDataSource(Ref ref) =>
    DraftLocalDataSource(ref.watch(draftsBoxProvider));

@Riverpod(keepAlive: true)
PieceEditorRemoteDataSource pieceEditorRemoteDataSource(Ref ref) =>
    PieceEditorRemoteDataSource(ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
PieceEditorRepository pieceEditorRepository(Ref ref) =>
    PieceEditorRepositoryImpl(ref.watch(pieceEditorRemoteDataSourceProvider));

/// The offline-draft sync engine (docs/40 §42). Kept alive for the app's lifetime;
/// registered as a background task on the unified [SyncEngine] (see
/// `app/sync_bootstrap.dart`) so offline drafts drain the moment connectivity
/// returns — on the ONE connectivity signal — even with no editor screen open.
@Riverpod(keepAlive: true)
DraftSyncEngine draftSyncEngine(Ref ref) {
  final DraftSyncEngine engine = DraftSyncEngine(
    repository: ref.watch(pieceEditorRepositoryProvider),
    store: ref.watch(draftLocalDataSourceProvider),
    connectivity: ref.watch(connectivityServiceProvider),
    logger: ref.watch(appLoggerProvider),
  );
  ref.onDispose(engine.dispose);
  return engine;
}

/// Rebuilds whenever the sync engine mutates a draft, so the drafts list and the
/// open editor refresh after background sync — without any feature→feature or
/// data→presentation dependency (the engine exposes only a change counter).
@riverpod
int draftsRevision(Ref ref) {
  final DraftSyncEngine engine = ref.watch(draftSyncEngineProvider);
  void listener() => ref.invalidateSelf();
  engine.revision.addListener(listener);
  ref.onDispose(() => engine.revision.removeListener(listener));
  return engine.revision.value;
}

/// Current cover-upload progress (0.0–1.0), or null when idle — for the editor's
/// cover field progress indicator.
@riverpod
double? coverUploadProgress(Ref ref) {
  final DraftSyncEngine engine = ref.watch(draftSyncEngineProvider);
  void listener() => ref.invalidateSelf();
  engine.coverProgress.addListener(listener);
  ref.onDispose(() => engine.coverProgress.removeListener(listener));
  return engine.coverProgress.value;
}
