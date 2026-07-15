/// Logging interceptor (docs/40 §13.2, §29).
///
/// Structured, REDACTED request/response/error logging. Headers and bodies are
/// masked (tokens, passwords, emails, OAuth codes) before they ever reach the
/// log. Verbose logging is debug-only; the [AppLogger] level already gates this
/// in release.
library;

import 'package:dio/dio.dart';

import '../../logging/app_logger.dart';
import '../../logging/log_redaction.dart';

class LoggingInterceptor extends Interceptor {
  LoggingInterceptor(this._logger);

  final AppLogger _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.d(
      '→ ${options.method} ${options.uri.path} '
      'headers=${redactHeaders(options.headers)}',
    );
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _logger.d(
      '← ${response.statusCode} ${response.requestOptions.method} '
      '${response.requestOptions.uri.path} '
      'reqId=${response.headers.value('x-request-id') ?? '-'}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.w(
      '✗ ${err.response?.statusCode ?? 0} ${err.requestOptions.method} '
      '${err.requestOptions.uri.path} type=${err.type.name} '
      'reqId=${err.response?.headers.value('x-request-id') ?? '-'}',
    );
    handler.next(err);
  }
}
