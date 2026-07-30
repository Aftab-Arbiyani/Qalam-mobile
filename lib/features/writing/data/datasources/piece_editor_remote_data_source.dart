/// Piece-authoring remote data source (docs/40 §17.1). The only place the writing
/// feature touches the wire for authoring. Returns raw envelope `data` maps (the
/// repository merges them onto the local [Draft]) or throws [ApiException]; knows
/// nothing about caching, the outbox, or `Failure`.
library;

import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_paths.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../../shared/api/api_envelope.dart';
import '../../domain/entities/draft_summary.dart';
import '../mappers/piece_write_mappers.dart';

class PieceEditorRemoteDataSource {
  PieceEditorRemoteDataSource(this._api);

  final ApiClient _api;

  /// In-flight cover uploads, keyed by the caller's upload key, so the presentation
  /// layer can abort one when its screen is left (docs/40 §34.3).
  final Map<String, CancelToken> _uploads = <String, CancelToken>{};

  static const int _draftsPageLimit = 20;

  static Json _identity(Json json) => json;

  Future<Json> create(Json body) =>
      _api.post<Json>(ApiPaths.pieces, body: body, decode: _identity);

  Future<Json> update(String id, Json body) =>
      _api.patch<Json>(ApiPaths.pieceById(id), body: body, decode: _identity);

  Future<void> delete(String id) => _api.delete(ApiPaths.pieceById(id));

  /// Publish carries a per-intent [idempotencyKey] so an auto-retry / re-queue is a
  /// safe replay (docs/40 §13.5) — it is the only retriable mutation.
  Future<Json> publish(String id, {required String idempotencyKey}) =>
      _api.post<Json>(
        ApiPaths.piecePublish(id),
        decode: _identity,
        idempotencyKey: idempotencyKey,
      );

  Future<Json> schedule(String id, DateTime scheduledAt) => _api.post<Json>(
    ApiPaths.pieceSchedule(id),
    body: <String, Object?>{
      'scheduledAt': scheduledAt.toUtc().toIso8601String(),
    },
    decode: _identity,
  );

  Future<Json> fetch(String id) =>
      _api.get<Json>(ApiPaths.pieceById(id), decode: _identity);

  Future<CursorPage<DraftSummary>> listDrafts({String? cursor}) =>
      _api.getPage<DraftSummary>(
        ApiPaths.meDrafts,
        query: <String, Object?>{'cursor': ?cursor, 'limit': _draftsPageLimit},
        decodeItem: draftSummaryFromListItem,
      );

  /// Upload the cover at [filePath]; returns the storage key. Reads the file to
  /// bytes here (data layer owns I/O) and streams progress; registers a cancel
  /// token under [uploadKey] for [cancel].
  Future<String> uploadCover(
    String id, {
    required String filePath,
    required String mimeType,
    void Function(double progress)? onProgress,
    String? uploadKey,
  }) async {
    final List<int> bytes = await File(filePath).readAsBytes();
    final String filename = filePath.split(Platform.pathSeparator).last;
    final CancelToken token = CancelToken();
    if (uploadKey != null) _uploads[uploadKey] = token;
    try {
      final Json data = await _api.upload<Json>(
        ApiPaths.pieceCover(id),
        bytes: bytes,
        filename: filename,
        mimeType: mimeType,
        decode: _identity,
        cancelToken: token,
        onSendProgress: (int sent, int total) {
          if (total > 0 && onProgress != null) onProgress(sent / total);
        },
      );
      return data['key'] as String? ?? '';
    } finally {
      if (uploadKey != null) _uploads.remove(uploadKey);
    }
  }

  void cancel(String uploadKey) {
    _uploads.remove(uploadKey)?.cancel('cover-upload-cancelled');
  }
}
