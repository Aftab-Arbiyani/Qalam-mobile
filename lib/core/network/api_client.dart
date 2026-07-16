/// The high-level API client (docs/40 §13.3) — the mobile analogue of the web
/// `lib/api-client.ts`. The ONLY thing data sources call; it unwraps the frozen
/// envelope, applies the query-string conventions, coalesces GETs, detects
/// offline up front, and converts every failure to a typed [ApiException].
///
/// Data sources supply a decoder (`Json → Entity`) so the generic `data` payload
/// is deserialized by the caller — the network layer never knows a DTO.
library;

import 'package:dio/dio.dart';

import '../../shared/api/api_envelope.dart';
import '../../shared/domain/error_codes.dart';
import '../connectivity/connectivity_service.dart';
import '../error/api_exception.dart';
import '../utils/typedefs.dart';
import 'dio_error_converter.dart';
import 'request_deduplicator.dart';
import 'request_keys.dart';

class ApiClient {
  ApiClient({
    required Dio dio,
    required ConnectivityService connectivity,
    RequestDeduplicator? deduplicator,
  }) : _dio = dio,
       _connectivity = connectivity,
       _dedup = deduplicator ?? RequestDeduplicator();

  final Dio _dio;
  final ConnectivityService _connectivity;
  final RequestDeduplicator _dedup;

  // ── Reads ──────────────────────────────────────────────────────────────────

  /// GET returning a single decoded object.
  Future<T> get<T>(
    String path, {
    Json? query,
    required JsonDecoder<T> decode,
    CancelToken? cancelToken,
    bool deduplicate = true,
  }) async {
    final Response<dynamic> response = await _get(
      path,
      query,
      cancelToken,
      deduplicate,
    );
    return decode(_dataAsJson(response));
  }

  /// GET returning a decoded list (non-paginated list endpoints).
  Future<List<T>> getList<T>(
    String path, {
    Json? query,
    required JsonDecoder<T> decodeItem,
    CancelToken? cancelToken,
    bool deduplicate = true,
  }) async {
    final Response<dynamic> response = await _get(
      path,
      query,
      cancelToken,
      deduplicate,
    );
    return _dataAsList(response).map(decodeItem).toList(growable: false);
  }

  /// GET one cursor-paginated page. Reads `meta.pagination` (docs/40 §13.7).
  Future<CursorPage<T>> getPage<T>(
    String path, {
    Json? query,
    required JsonDecoder<T> decodeItem,
    CancelToken? cancelToken,
  }) async {
    final Response<dynamic> response = await _get(
      path,
      query,
      cancelToken,
      false,
    );
    final List<T> items = _dataAsList(
      response,
    ).map(decodeItem).toList(growable: false);
    return CursorPage<T>(items: items, meta: _cursorMeta(response));
  }

  // ── Mutations ───────────────────────────────────────────────────────────────

  Future<T> post<T>(
    String path, {
    Object? body,
    Json? query,
    required JsonDecoder<T> decode,
    CancelToken? cancelToken,
    String? idempotencyKey,
  }) async {
    final Response<dynamic> response = await _execute(
      () => _dio.post<dynamic>(
        path,
        data: body,
        queryParameters: _encodeQuery(query),
        cancelToken: cancelToken,
        options: _idempotency(idempotencyKey),
      ),
    );
    return decode(_dataAsJson(response));
  }

  /// POST with no meaningful body in the response (201/200 action).
  Future<void> postVoid(
    String path, {
    Object? body,
    CancelToken? cancelToken,
    String? idempotencyKey,
  }) async {
    await _execute(
      () => _dio.post<dynamic>(
        path,
        data: body,
        cancelToken: cancelToken,
        options: _idempotency(idempotencyKey),
      ),
    );
  }

  Future<T> patch<T>(
    String path, {
    Object? body,
    required JsonDecoder<T> decode,
    CancelToken? cancelToken,
  }) async {
    final Response<dynamic> response = await _execute(
      () => _dio.patch<dynamic>(path, data: body, cancelToken: cancelToken),
    );
    return decode(_dataAsJson(response));
  }

  /// PATCH with no meaningful body in the response (a 200/204 action, e.g.
  /// mark-read / archive). Mirrors [postVoid] for the PATCH verb.
  Future<void> patchVoid(
    String path, {
    Object? body,
    CancelToken? cancelToken,
  }) async {
    await _execute(
      () => _dio.patch<dynamic>(path, data: body, cancelToken: cancelToken),
    );
  }

  Future<void> delete(
    String path, {
    Object? body,
    CancelToken? cancelToken,
  }) async {
    await _execute(
      () => _dio.delete<dynamic>(path, data: body, cancelToken: cancelToken),
    );
  }

  /// Multipart upload of [bytes] under field [field] (docs/40 §34). Streams
  /// [onSendProgress] for the UI, honors [cancelToken] (leaving the screen aborts),
  /// and marks the request to BYPASS the 401→refresh interceptor (§34.2) — a 401
  /// surfaces to the caller, which refreshes via a normal request and retries.
  /// Never sets `Content-Type` beyond the multipart part's own type (the platform
  /// owns the boundary).
  Future<T> upload<T>(
    String path, {
    required List<int> bytes,
    required String filename,
    required JsonDecoder<T> decode,
    String field = 'file',
    String? mimeType,
    void Function(int sent, int total)? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    final FormData form = FormData.fromMap(<String, Object?>{
      field: MultipartFile.fromBytes(
        bytes,
        filename: filename,
        contentType: mimeType == null ? null : DioMediaType.parse(mimeType),
      ),
    });
    final Response<dynamic> response = await _execute(
      () => _dio.post<dynamic>(
        path,
        data: form,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        options: Options(
          extra: <String, Object?>{RequestKeys.skipAuthRefresh: true},
        ),
      ),
    );
    return decode(_dataAsJson(response));
  }

  // ── Internals ────────────────────────────────────────────────────────────────

  Future<Response<dynamic>> _get(
    String path,
    Json? query,
    CancelToken? cancelToken,
    bool deduplicate,
  ) {
    final Map<String, dynamic>? encoded = _encodeQuery(query);
    Future<Response<dynamic>> action() => _execute(
      () => _dio.get<dynamic>(
        path,
        queryParameters: encoded,
        cancelToken: cancelToken,
      ),
    );
    if (!deduplicate) return action();
    return _dedup.run('GET $path?$encoded', action);
  }

  /// Offline pre-check + `DioException` → [ApiException] conversion boundary.
  Future<Response<dynamic>> _execute(
    Future<Response<dynamic>> Function() run,
  ) async {
    if (!_connectivity.isOnline) {
      throw const ApiException(
        code: ErrorCodes.apiOffline,
        status: 0,
        message: "You're offline.",
      );
    }
    try {
      return await run();
    } on DioException catch (e) {
      throw dioExceptionToApiException(e);
    }
  }

  Options _idempotency(String? key) => Options(
    headers: key == null ? null : <String, Object?>{'Idempotency-Key': key},
  );

  /// Apply the backend query conventions (docs/40 §13.6): omit null; join arrays
  /// with commas (OR); booleans as literal strings.
  Map<String, dynamic>? _encodeQuery(Json? query) {
    if (query == null) return null;
    final Map<String, dynamic> out = <String, dynamic>{};
    for (final MapEntry<String, dynamic> e in query.entries) {
      final Object? value = e.value;
      if (value == null) continue;
      if (value is List) {
        if (value.isNotEmpty) out[e.key] = value.join(',');
      } else if (value is bool) {
        out[e.key] = value ? 'true' : 'false';
      } else {
        out[e.key] = value;
      }
    }
    return out.isEmpty ? null : out;
  }

  Json _dataAsJson(Response<dynamic> response) {
    final Object? data = _extractData(response);
    if (data is Map) return Json.from(data);
    throw _malformed(response, 'expected an object');
  }

  List<Json> _dataAsList(Response<dynamic> response) {
    final Object? data = _extractData(response);
    if (data is List) {
      return data
          .whereType<Map<dynamic, dynamic>>()
          .map(Json.from)
          .toList(growable: false);
    }
    throw _malformed(response, 'expected an array');
  }

  Object? _extractData(Response<dynamic> response) {
    if (response.statusCode == 204) return null;
    final Object? body = response.data;
    if (body is Map && body['success'] == true) return body['data'];
    throw _malformed(response, 'missing success envelope');
  }

  CursorMeta _cursorMeta(Response<dynamic> response) {
    final Object? body = response.data;
    final Object? meta = body is Map ? body['meta'] : null;
    final Object? pagination = meta is Map ? meta['pagination'] : null;
    if (pagination is Map) return CursorMeta.fromJson(Json.from(pagination));
    return const CursorMeta();
  }

  ApiException _malformed(Response<dynamic> response, String why) =>
      ApiException(
        code: ErrorCodes.apiMalformedResponse,
        status: response.statusCode ?? 0,
        message: 'Malformed response ($why).',
        requestId: response.headers.value('x-request-id'),
      );
}
