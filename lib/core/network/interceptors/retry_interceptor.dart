/// Retry interceptor (docs/40 §13.5).
///
/// Retries **GET** requests up to 2 times with exponential backoff on transport
/// failures and 5xx/503 — never on 4xx, never on mutations. Auth (401) and rate
/// limiting (429) are handled elsewhere and are not retried here. Requests may
/// opt out with `RequestKeys.skipRetry`.
library;

import 'package:dio/dio.dart';

import '../request_keys.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor(this._client, {this.maxRetries = 2});

  final Dio _client;
  final int maxRetries;

  static const List<Duration> _backoff = <Duration>[
    Duration(seconds: 1),
    Duration(seconds: 3),
  ];

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final RequestOptions options = err.requestOptions;
    if (!_shouldRetry(err)) {
      return handler.next(err);
    }

    final int attempt = options.retryCount;
    if (attempt >= maxRetries) {
      return handler.next(err);
    }

    await Future<void>.delayed(_backoff[attempt.clamp(0, _backoff.length - 1)]);
    options.extra[RequestKeys.retryCount] = attempt + 1;
    try {
      final Response<dynamic> response = await _client.fetch<dynamic>(options);
      return handler.resolve(response);
    } on DioException catch (retryErr) {
      return handler.next(retryErr);
    }
  }

  bool _shouldRetry(DioException err) {
    final RequestOptions options = err.requestOptions;
    if (options.method.toUpperCase() != 'GET' || options.skipRetry) {
      return false;
    }

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        final int? status = err.response?.statusCode;
        return status != null && status >= 500;
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.unknown:
        return false;
    }
  }
}
