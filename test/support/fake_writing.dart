/// Canned writing-feature dependencies for editor/sync tests — no network, no
/// platform channels. Controllable enough to exercise create/update/publish,
/// offline (transient) failures, and conflict detection.
library;

import 'package:qalam_mobile/core/error/failure.dart';
import 'package:qalam_mobile/core/media/cover_image_picker.dart';
import 'package:qalam_mobile/core/utils/result.dart';
import 'package:qalam_mobile/core/utils/typedefs.dart';
import 'package:qalam_mobile/features/writing/domain/entities/draft.dart';
import 'package:qalam_mobile/features/writing/domain/entities/draft_summary.dart';
import 'package:qalam_mobile/features/writing/domain/entities/draft_sync.dart';
import 'package:qalam_mobile/features/writing/domain/repositories/editor_taxonomy_repository.dart';
import 'package:qalam_mobile/features/writing/domain/repositories/piece_editor_repository.dart';
import 'package:qalam_mobile/shared/api/api_envelope.dart';
import 'package:qalam_mobile/shared/domain/entities/taxonomy.dart';
import 'package:qalam_mobile/shared/domain/enums.dart';

class FakePieceEditorRepository implements PieceEditorRepository {
  FakePieceEditorRepository();

  /// When true, every remote call fails transiently (offline).
  bool offline = false;

  /// The `updatedAt` the server reports for a freshly created/updated piece.
  DateTime serverUpdatedAt = DateTime.utc(2026, 7, 15, 10);

  /// The `updatedAt` returned by [fetchDraft] — set it AFTER [serverUpdatedAt] to
  /// simulate a concurrent edit (conflict).
  DateTime? headUpdatedAt;

  int createCalls = 0;
  int updateCalls = 0;
  int publishCalls = 0;
  int scheduleCalls = 0;
  int deleteCalls = 0;
  int coverCalls = 0;
  int nextRemote = 1;

  List<DraftSummary> serverDrafts = <DraftSummary>[];

  Result<T> _offline<T>() =>
      Err<T>(const NetworkFailure(code: 'API_NETWORK_ERROR'));

  @override
  Future<Result<Draft>> createDraft(Draft draft) async {
    createCalls++;
    if (offline) return _offline<Draft>();
    return Ok<Draft>(
      draft.copyWith(
        remoteId: 'srv-${nextRemote++}',
        syncState: DraftSyncState.synced,
        intent: DraftIntent.save,
        remoteUpdatedAt: serverUpdatedAt,
      ),
    );
  }

  @override
  Future<Result<Draft>> updateDraft(Draft draft) async {
    updateCalls++;
    if (offline) return _offline<Draft>();
    return Ok<Draft>(
      draft.copyWith(
        syncState: DraftSyncState.synced,
        remoteUpdatedAt: serverUpdatedAt,
      ),
    );
  }

  @override
  Future<Result<Unit>> deleteDraft(String remoteId) async {
    deleteCalls++;
    if (offline) return _offline<Unit>();
    return const Ok<Unit>(unit);
  }

  @override
  Future<Result<Draft>> publish(Draft draft) async {
    publishCalls++;
    if (offline) return _offline<Draft>();
    return Ok<Draft>(
      draft.copyWith(
        status: PieceStatus.published,
        syncState: DraftSyncState.synced,
        intent: DraftIntent.save,
        remoteUpdatedAt: serverUpdatedAt,
        publishedAt: serverUpdatedAt,
      ),
    );
  }

  @override
  Future<Result<Draft>> schedule(Draft draft, DateTime scheduledAt) async {
    scheduleCalls++;
    if (offline) return _offline<Draft>();
    return Ok<Draft>(
      draft.copyWith(
        status: PieceStatus.scheduled,
        scheduledAt: scheduledAt,
        syncState: DraftSyncState.synced,
        intent: DraftIntent.save,
        remoteUpdatedAt: serverUpdatedAt,
      ),
    );
  }

  @override
  Future<Result<Draft>> fetchDraft(String remoteId) async {
    if (offline) return _offline<Draft>();
    return Ok<Draft>(
      Draft(
        localId: 'srv-$remoteId',
        remoteId: remoteId,
        title: 'Server copy',
        createdAt: DateTime.utc(2026, 7),
        localUpdatedAt: headUpdatedAt ?? serverUpdatedAt,
        remoteUpdatedAt: headUpdatedAt ?? serverUpdatedAt,
      ),
    );
  }

  @override
  Future<Result<CursorPage<DraftSummary>>> listDrafts({String? cursor}) async {
    if (offline) return _offline<CursorPage<DraftSummary>>();
    return Ok<CursorPage<DraftSummary>>(
      CursorPage<DraftSummary>(items: serverDrafts, meta: const CursorMeta()),
    );
  }

  @override
  Future<Result<String>> uploadCover(
    String remoteId, {
    required String filePath,
    UploadProgress? onProgress,
    String? uploadKey,
  }) async {
    coverCalls++;
    if (offline) return _offline<String>();
    onProgress?.call(1);
    return const Ok<String>('pieces/cover.webp');
  }

  @override
  void cancelUpload(String uploadKey) {}
}

class FakeEditorTaxonomyRepository implements EditorTaxonomyRepository {
  FakeEditorTaxonomyRepository({
    List<LanguageRef>? languages,
    List<GenreRef>? genres,
  }) : _languages =
           languages ??
           const <LanguageRef>[
             LanguageRef(
               code: 'ur',
               nativeName: 'اردو',
               direction: TextDirectionKind.rtl,
             ),
             LanguageRef(code: 'hi', nativeName: 'हिन्दी'),
           ],
       _genres =
           genres ??
           const <GenreRef>[
             GenreRef(slug: 'ghazal', name: 'Ghazal'),
             GenreRef(slug: 'story', name: 'Story'),
           ];

  final List<LanguageRef> _languages;
  final List<GenreRef> _genres;

  @override
  Future<Result<List<LanguageRef>>> languages() async =>
      Ok<List<LanguageRef>>(_languages);

  @override
  Future<Result<List<GenreRef>>> genres() async => Ok<List<GenreRef>>(_genres);
}

class FakeCoverImagePicker implements CoverImagePicker {
  FakeCoverImagePicker([this.result]);

  PickedImage? result;

  @override
  Future<PickedImage?> pick(ImageSourceKind source) async => result;
}
