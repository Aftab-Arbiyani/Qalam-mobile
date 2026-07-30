/// Converts a `dio` `DioException` into our typed [ApiException] (docs/40 §13.3,
/// §22.3). This is the "error mapping" boundary of the network layer — the rest
/// of the app never sees a `DioException`.
library;

import 'package:dio/dio.dart';

import '../../shared/api/api_envelope.dart';
import '../../shared/domain/error_codes.dart';
import '../error/api_exception.dart';
import '../utils/typedefs.dart';

/// Parse the `error` object out of a failure envelope, if present.
ApiErrorPayload? parseErrorPayload(Response<dynamic>? response) {
  final Object? data = response?.data;
  if (data is Map && data['success'] == false && data['error'] is Map) {
    return ApiErrorPayload.fromJson(
      Json.from(data['error'] as Map<dynamic, dynamic>),
    );
  }
  return null;
}

ApiException dioExceptionToApiException(DioException e) {
  final int status = e.response?.statusCode ?? 0;
  final String? requestId = e.response?.headers.value('x-request-id');

  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return ApiException(
        code: ErrorCodes.apiTimeout,
        status: 408,
        message: 'The request timed out.',
        requestId: requestId,
      );
    case DioExceptionType.cancel:
      return const ApiException(
        code: ErrorCodes.apiCancelled,
        status: 0,
        message: 'Request cancelled.',
      );
    case DioExceptionType.connectionError:
    case DioExceptionType.unknown:
      return const ApiException(
        code: ErrorCodes.apiNetworkError,
        status: 0,
        message: 'Could not reach the server.',
      );
    case DioExceptionType.badCertificate:
      return const ApiException(
        code: ErrorCodes.apiNetworkError,
        status: 0,
        message: 'Certificate could not be verified.',
      );
    case DioExceptionType.badResponse:
      final ApiErrorPayload? payload = parseErrorPayload(e.response);
      if (payload != null) {
        return ApiException(
          code: payload.code,
          status: status,
          message: payload.message,
          details: payload.details,
          requestId: payload.requestId ?? requestId,
        );
      }
      return ApiException(
        code: ErrorCodes.apiMalformedResponse,
        status: status,
        message: 'Unexpected response from the server (HTTP $status).',
        requestId: requestId,
      );
  }
}
