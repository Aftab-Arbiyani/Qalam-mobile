/// Authentication interceptor (docs/40 §13.2, §15).
///
/// onRequest: attach the Bearer access token.
/// onError: on `401 + AUTH_TOKEN_EXPIRED` outside the auth corridor, trigger a
/// single-flight refresh and replay the request ONCE; any other 401 → terminal
/// unauthorized. 403 is never touched here.
library;

import 'package:dio/dio.dart';

import '../../../shared/domain/error_codes.dart';
import '../auth_gateway.dart';
import '../dio_error_converter.dart';
import '../request_keys.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._gateway);

  final AuthGateway _gateway;

  /// The client used to replay a request after refresh. Bound after the Dio
  /// instance is created (see dio_client.dart).
  Dio? _client;
  // ignore: use_setters_to_change_properties
  void bindClient(Dio client) => _client = client;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final String? token = _gateway.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final RequestOptions options = err.requestOptions;
    final int? status = err.response?.statusCode;

    final bool eligible =
        status == 401 &&
        !options.isAuthCorridor &&
        !options.isRetryAttempt &&
        !options.skipAuthRefresh;

    if (eligible) {
      final String? code = parseErrorPayload(err.response)?.code;
      if (code == ErrorCodes.authTokenExpired) {
        final bool refreshed = await _gateway.refresh();
        if (refreshed && _client != null) {
          try {
            final Response<dynamic> replay = await _replay(options);
            return handler.resolve(replay);
          } on DioException catch (retryErr) {
            return handler.next(retryErr);
          }
        }
        await _gateway.handleTerminalUnauthorized();
        return handler.next(err);
      }
    }

    // Any other 401 outside the auth corridor is terminal.
    if (status == 401 && !options.isAuthCorridor) {
      await _gateway.handleTerminalUnauthorized();
    }
    handler.next(err);
  }

  Future<Response<dynamic>> _replay(RequestOptions options) {
    options.extra[RequestKeys.isRetry] = true;
    final String? token = _gateway.accessToken;
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    return _client!.fetch<dynamic>(options);
  }
}
