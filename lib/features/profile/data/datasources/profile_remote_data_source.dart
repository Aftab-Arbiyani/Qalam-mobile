/// Profile remote data source (docs/40 §17.1). The only place the profile feature
/// touches the wire. Returns decoded entities / raw pages or throws [ApiException];
/// knows nothing about caching or `Failure`. Uploads mirror the writing feature's
/// cover-upload pattern: bytes read here (data layer owns I/O), progress streamed,
/// and a [CancelToken] registered per upload key so leaving a screen aborts it.
library;

import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_paths.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../../shared/api/api_envelope.dart';
import '../../../../shared/domain/limits.dart';
import '../../domain/entities/profile.dart';
import '../../domain/entities/profile_piece.dart';
import '../mappers/profile_mappers.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._api);

  final ApiClient _api;

  /// In-flight avatar/cover uploads, keyed by the caller's upload key.
  final Map<String, CancelToken> _uploads = <String, CancelToken>{};

  static const int _piecesPageLimit = 20;

  static Json _identity(Json json) => json;

  Future<Profile> getMe() =>
      _api.get<Profile>(ApiPaths.me, decode: profileFromJson);

  Future<Profile> getByUsername(String username) => _api.get<Profile>(
    ApiPaths.userByUsername(username),
    decode: profileFromJson,
  );

  Future<Profile> updateMe(Json body) =>
      _api.patch<Profile>(ApiPaths.me, body: body, decode: profileFromJson);

  Future<CursorPage<ProfilePiece>> publishedPieces({String? cursor}) =>
      _api.getPage<ProfilePiece>(
        ApiPaths.mePieces,
        query: <String, Object?>{
          'status': 'published',
          'cursor': ?cursor,
          'limit': _piecesPageLimit,
        },
        decodeItem: profilePieceFromJson,
      );

  /// One `limit=50` page of drafts — used only for the bounded stat count.
  Future<CursorPage<Json>> draftsCountPage() => _api.getPage<Json>(
    ApiPaths.meDrafts,
    query: <String, Object?>{'limit': Limits.pageSizeMax},
    decodeItem: _identity,
  );

  /// One `limit=50` page of bookmarks — used only for the bounded stat count.
  Future<CursorPage<Json>> bookmarksCountPage() => _api.getPage<Json>(
    ApiPaths.meBookmarks,
    query: <String, Object?>{'limit': Limits.pageSizeMax},
    decodeItem: _identity,
  );

  Future<String> uploadAvatar({
    required String filePath,
    required String mimeType,
    void Function(double progress)? onProgress,
    String? uploadKey,
  }) => _upload(
    ApiPaths.profileAvatar,
    filePath: filePath,
    mimeType: mimeType,
    onProgress: onProgress,
    uploadKey: uploadKey,
  );

  Future<String> uploadCover({
    required String filePath,
    required String mimeType,
    void Function(double progress)? onProgress,
    String? uploadKey,
  }) => _upload(
    ApiPaths.profileCover,
    filePath: filePath,
    mimeType: mimeType,
    onProgress: onProgress,
    uploadKey: uploadKey,
  );

  void cancel(String uploadKey) {
    _uploads.remove(uploadKey)?.cancel('profile-upload-cancelled');
  }

  Future<String> _upload(
    String path, {
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
        path,
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
}
